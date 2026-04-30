import { fetchTreePage, fetchTrees, formatAge, formatCluster, hideAlert, showAlert } from "./api.js";

const tableBody = document.querySelector("#visualisation-table tbody");
const countLabel = document.getElementById("visualisation-count");
const alertBox = document.getElementById("visualisation-alert");
const mapElement = document.getElementById("visualisation-map");
const focusLabel = document.getElementById("visualisation-focus");
const prevPageButton = document.getElementById("visualisation-prev-page");
const nextPageButton = document.getElementById("visualisation-next-page");
const pageInfoLabel = document.getElementById("visualisation-page-info");
const SAINT_QUENTIN = { lat: 49.8489, lon: 3.2870 };
const DEFAULT_ZOOM = 6.2;
const FOCUS_ZOOM = 14;
const PAGE_SIZE = 10;
const FRANCE_BOUNDS = {
  minLat: 41.0,
  maxLat: 51.5,
  minLon: -5.5,
  maxLon: 9.8,
};

let currentMapTrees = [];
let focusedTreeId = null;
let currentPage = 1;
let totalPages = 1;
let totalTreeCount = 0;

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

function canFocusTree(tree) {
  return isFranceCoordinate(tree) && window.Plotly && mapElement;
}

function buildHoverText(tree) {
  return [
    `<b>${tree.nomfrancais}</b>`,
    `ID : ${tree.id_arbre}`,
    `Hauteur totale : ${tree.hauteur_total} m`,
    `Hauteur tronc : ${tree.hauteur_tronc} m`,
    `Diametre : ${tree.diametre_tronc} cm`,
    `Etat : ${tree.etat}`,
  ].join("<br>");
}

function updateFocusLabel(tree) {
  if (!focusLabel) {
    return;
  }

  if (!tree) {
    focusLabel.textContent = "Carte centree sur la vue globale autour de Saint-Quentin.";
    return;
  }

  focusLabel.textContent = `Focus actuel : ${tree.nomfrancais} (${tree.id_arbre}) a ${tree.latitude}, ${tree.longitude}.`;
}

function buildMapData(mapTrees) {
  const baseTrace = {
    type: "scattermapbox",
    mode: "markers",
    lat: mapTrees.map((tree) => Number(tree.latitude)),
    lon: mapTrees.map((tree) => Number(tree.longitude)),
    marker: {
      size: mapTrees.map((tree) => Math.max(12, Math.sqrt(tree.diametre_tronc || 0) * 2)),
      color: mapTrees.map((tree) => (tree.remarquable ? "#9a2f2f" : "#2f6b3a")),
    },
    text: mapTrees.map(buildHoverText),
    hoverinfo: "text",
  };

  const focusedTree = focusedTreeId
    ? mapTrees.find((tree) => tree.id_arbre === focusedTreeId) ?? null
    : null;

  if (!focusedTree) {
    return {
      data: [baseTrace],
      focusedTree: null,
      pointIndex: -1,
    };
  }

  const focusTrace = {
    type: "scattermapbox",
    mode: "markers",
    lat: [Number(focusedTree.latitude)],
    lon: [Number(focusedTree.longitude)],
    marker: {
      size: [26],
      color: ["#f5d142"],
      line: {
        color: "#1f2a1d",
        width: 2,
      },
      symbol: "circle",
    },
    text: [buildHoverText(focusedTree)],
    hoverinfo: "text",
    showlegend: false,
  };

  return {
    data: [baseTrace, focusTrace],
    focusedTree,
    pointIndex: mapTrees.findIndex((tree) => tree.id_arbre === focusedTree.id_arbre),
  };
}

function getMapLayout(focusedTree) {
  return {
    mapbox: {
      style: "open-street-map",
      center: focusedTree
        ? {
            lat: Number(focusedTree.latitude),
            lon: Number(focusedTree.longitude),
          }
        : SAINT_QUENTIN,
      zoom: focusedTree ? FOCUS_ZOOM : DEFAULT_ZOOM,
    },
    margin: { t: 0, r: 0, b: 0, l: 0 },
    height: 520,
  };
}

function openFocusedPopup(pointIndex) {
  if (!window.Plotly || pointIndex < 0) {
    return;
  }

  window.setTimeout(() => {
    try {
      window.Plotly.Fx?.hover?.(mapElement, [{ curveNumber: 0, pointNumber: pointIndex }]);
    } catch (error) {
      console.warn("Impossible d'ouvrir automatiquement l'infobulle Plotly.", error);
    }
  }, 150);
}

function drawMap() {
  if (!window.Plotly || !mapElement || currentMapTrees.length === 0) {
    mapElement.innerHTML = '<div class="empty-state">Aucune carte a afficher pour le moment.</div>';
    updateFocusLabel(null);
    return;
  }

  const { data, focusedTree, pointIndex } = buildMapData(currentMapTrees);
  const layout = getMapLayout(focusedTree);

  window.Plotly.react(mapElement, data, layout, {
    responsive: true,
    displayModeBar: true,
    scrollZoom: true,
    displaylogo: false,
  }).then(() => {
    updateFocusLabel(focusedTree);
    if (focusedTree) {
      openFocusedPopup(pointIndex);
    }
  });
}

function focusTree(tree) {
  if (!canFocusTree(tree)) {
    showAlert(alertBox, "Cet arbre n'a pas de coordonnees exploitables en France metropolitaine.");
    return;
  }

  hideAlert(alertBox);
  focusedTreeId = tree.id_arbre;
  mapElement.scrollIntoView({ behavior: "smooth", block: "start" });
  drawMap();
}

function renderMap(trees) {
  if (!window.Plotly || !mapElement || trees.length === 0) {
    mapElement.innerHTML = '<div class="empty-state">Aucune carte a afficher pour le moment.</div>';
    updateFocusLabel(null);
    return;
  }

  currentMapTrees = trees.filter(isFranceCoordinate);

  if (currentMapTrees.length === 0) {
    mapElement.innerHTML = '<div class="empty-state">Aucun arbre avec coordonnees valides en France metropolitaine.</div>';
    updateFocusLabel(null);
    return;
  }

  if (focusedTreeId && !currentMapTrees.some((tree) => tree.id_arbre === focusedTreeId)) {
    focusedTreeId = null;
  }

  drawMap();
}

function appendCell(row, value) {
  const cell = document.createElement("td");
  cell.textContent = value;
  row.appendChild(cell);
}

function appendFocusCell(row, tree) {
  const cell = document.createElement("td");

  if (!isFranceCoordinate(tree)) {
    cell.textContent = "-";
    row.appendChild(cell);
    return;
  }

  const button = document.createElement("button");
  button.type = "button";
  button.className = "table-icon-button";
  button.innerHTML = "&#128065;";
  button.title = `Zoomer sur ${tree.nomfrancais} (${tree.id_arbre})`;
  button.setAttribute("aria-label", `Zoomer sur ${tree.nomfrancais} (${tree.id_arbre})`);
  button.addEventListener("click", () => focusTree(tree));

  cell.appendChild(button);
  row.appendChild(cell);
}

function renderTable(trees) {
  tableBody.innerHTML = "";

  if (trees.length === 0) {
    const row = document.createElement("tr");
    const cell = document.createElement("td");
    cell.colSpan = 15;
    cell.innerHTML = '<div class="empty-state">Aucun arbre disponible.</div>';
    row.appendChild(cell);
    tableBody.appendChild(row);
    return;
  }

  trees.forEach((tree) => {
    const row = document.createElement("tr");
    appendFocusCell(row, tree);
    appendCell(row, tree.id_arbre);
    appendCell(row, tree.nomfrancais);
    appendCell(row, String(tree.diametre_tronc));
    appendCell(row, String(tree.hauteur_total));
    appendCell(row, String(tree.hauteur_tronc));
    appendCell(row, String(tree.latitude));
    appendCell(row, String(tree.longitude));
    appendCell(row, tree.etat);
    appendCell(row, tree.stade_developpement);
    appendCell(row, tree.type_port);
    appendCell(row, tree.type_pied);
    appendCell(row, tree.remarquable ? "Oui" : "Non");
    appendCell(row, formatAge(tree.age));
    appendCell(row, formatCluster(tree.cluster));
    tableBody.appendChild(row);
  });
}

function updatePagination() {
  if (pageInfoLabel) {
    pageInfoLabel.textContent = `Page ${currentPage} sur ${totalPages} (${totalTreeCount} arbre(s))`;
  }

  if (prevPageButton) {
    prevPageButton.disabled = currentPage <= 1;
  }

  if (nextPageButton) {
    nextPageButton.disabled = currentPage >= totalPages;
  }
}

async function loadTablePage(page) {
  const data = await fetchTreePage(page, PAGE_SIZE);
  currentPage = data.page || 1;
  totalPages = data.total_pages || 1;
  totalTreeCount = data.total_count || 0;
  renderTable(data.trees || []);
  updatePagination();
}

async function init() {
  try {
    hideAlert(alertBox);
    const [trees] = await Promise.all([
      fetchTrees(),
      loadTablePage(1),
    ]);
    countLabel.textContent = `${trees.length} arbre(s) charges`;
    renderMap(trees);
  } catch (error) {
    showAlert(alertBox, error instanceof Error ? error.message : "Impossible de charger les arbres.");
    countLabel.textContent = "Erreur de chargement";
  }
}

prevPageButton?.addEventListener("click", () => {
  if (currentPage > 1) {
    void loadTablePage(currentPage - 1);
  }
});

nextPageButton?.addEventListener("click", () => {
  if (currentPage < totalPages) {
    void loadTablePage(currentPage + 1);
  }
});

void init();
