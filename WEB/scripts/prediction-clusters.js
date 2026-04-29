import { hideAlert, predictClusters, showAlert } from "./api.js";

const alertBox = document.getElementById("clusters-alert");
const summaryContainer = document.getElementById("clusters-summary");
const mapElement = document.getElementById("clusters-map");
const predictButton = document.getElementById("predict-clusters-button");
const SAINT_QUENTIN = { lat: 49.8489, lon: 3.2870 };
const FRANCE_BOUNDS = {
  minLat: 41.0,
  maxLat: 51.5,
  minLon: -5.5,
  maxLon: 9.8,
};

function isFranceCoordinate(tree) {
  const latitude = Number(tree.latitude);
  const longitude = Number(tree.longitude);

  return (
    Number.isFinite(latitude) &&
    Number.isFinite(longitude) &&
    latitude >= FRANCE_BOUNDS.minLat &&
    latitude <= FRANCE_BOUNDS.maxLat &&
    longitude >= FRANCE_BOUNDS.minLon &&
    longitude <= FRANCE_BOUNDS.maxLon
  );
}

function renderSummary(summary) {
  summaryContainer.innerHTML = "";

  summary.forEach((item) => {
    const card = document.createElement("article");
    card.className = "stat-card";
    card.innerHTML = `
      <p class="stat-card__label">${item.label}</p>
      <p class="stat-card__value">${item.count}</p>
    `;
    summaryContainer.appendChild(card);
  });
}

function renderMap(trees) {
  if (!window.Plotly || !mapElement || trees.length === 0) {
    mapElement.innerHTML = '<div class="empty-state">Aucune carte a afficher pour les clusters.</div>';
    return;
  }

  const mapTrees = trees.filter(isFranceCoordinate);

  if (mapTrees.length === 0) {
    mapElement.innerHTML = '<div class="empty-state">Aucun arbre avec coordonnees valides en France metropolitaine.</div>';
    return;
  }

  const clusterColors = {
    0: "#88b04b",
    1: "#f4a259",
    2: "#5d7bdc",
  };

  const trace = {
    type: "scattermapbox",
    mode: "markers",
    lat: mapTrees.map((tree) => tree.latitude),
    lon: mapTrees.map((tree) => tree.longitude),
    marker: {
      size: mapTrees.map((tree) => Math.max(12, Math.sqrt(tree.diametre_tronc || 0) * 2)),
      color: mapTrees.map((tree) => clusterColors[Number(tree.cluster)] || "#64748b"),
    },
    text: mapTrees.map((tree) => {
      return [
        `<b>${tree.nomfrancais}</b>`,
        `Cluster : ${tree.cluster}`,
        `Age : ${tree.age} ans`,
        `Hauteur : ${tree.hauteur_total} m`,
        `Diametre : ${tree.diametre_tronc} cm`,
      ].join("<br>");
    }),
    hoverinfo: "text",
  };

  const layout = {
    mapbox: {
      style: "open-street-map",
      center: SAINT_QUENTIN,
      zoom: 6.2,
    },
    margin: { t: 0, r: 0, b: 0, l: 0 },
    height: 540,
  };

  window.Plotly.newPlot(mapElement, [trace], layout, {
    responsive: true,
    displayModeBar: true,
    scrollZoom: true,
    displaylogo: false,
  });
}

async function handlePredict() {
  hideAlert(alertBox);
  predictButton.disabled = true;
  predictButton.textContent = "Calcul en cours...";

  try {
    const data = await predictClusters();
    renderSummary(data.summary || []);
    renderMap(data.trees || []);
  } catch (error) {
    showAlert(alertBox, error instanceof Error ? error.message : "Impossible de calculer les clusters.");
  } finally {
    predictButton.disabled = false;
    predictButton.textContent = "Predire les clusters";
  }
}

predictButton?.addEventListener("click", handlePredict);
