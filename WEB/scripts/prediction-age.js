import { fetchTrees, formatAge, hideAlert, predictAge, showAlert } from "./api.js";

const tableBody = document.querySelector("#age-table tbody");
const alertBox = document.getElementById("age-alert");
const resultPanel = document.getElementById("age-result-panel");
const resultValue = document.getElementById("age-result-value");
const resultLabel = document.getElementById("age-result-label");
const predictButton = document.getElementById("predict-age-button");
const refreshButton = document.getElementById("age-refresh");

let trees = [];

function renderTable() {
  tableBody.innerHTML = "";

  if (trees.length === 0) {
    const row = document.createElement("tr");
    const cell = document.createElement("td");
    cell.colSpan = 8;
    cell.innerHTML = '<div class="empty-state">Aucun arbre disponible pour la prediction.</div>';
    row.appendChild(cell);
    tableBody.appendChild(row);
    return;
  }

  trees.forEach((tree, index) => {
    const row = document.createElement("tr");

    const radioCell = document.createElement("td");
    const radio = document.createElement("input");
    radio.type = "radio";
    radio.name = "selected-tree";
    radio.value = tree.id_arbre;
    radio.checked = index === 0;
    radioCell.appendChild(radio);
    row.appendChild(radioCell);

    [tree.id_arbre, tree.nomfrancais, tree.stade_developpement, `${tree.diametre_tronc} cm`, `${tree.hauteur_total} m`, `${tree.hauteur_tronc} m`, formatAge(tree.age)]
      .forEach((value) => {
        const cell = document.createElement("td");
        cell.textContent = value;
        row.appendChild(cell);
      });

    tableBody.appendChild(row);
  });
}

function selectedTreeId() {
  const checked = document.querySelector('input[name="selected-tree"]:checked');
  return checked ? checked.value : null;
}

async function loadTrees() {
  hideAlert(alertBox);
  resultPanel.classList.add("is-hidden");

  try {
    trees = await fetchTrees();
    renderTable();
  } catch (error) {
    showAlert(alertBox, error instanceof Error ? error.message : "Impossible de charger les arbres.");
  }
}

async function handlePredict() {
  const treeId = selectedTreeId();

  if (!treeId) {
    showAlert(alertBox, "Selectionne un arbre avant de lancer la prediction.");
    return;
  }

  hideAlert(alertBox);
  predictButton.disabled = true;
  predictButton.textContent = "Calcul en cours...";

  try {
    const data = await predictAge(treeId);
    resultValue.textContent = `${data.predicted_age} ans`;
    resultLabel.textContent = `Categorie : ${data.category}`;
    resultPanel.classList.remove("is-hidden");
    trees = trees.map((tree) => (tree.id_arbre === data.tree.id_arbre ? data.tree : tree));
    renderTable();
  } catch (error) {
    showAlert(alertBox, error instanceof Error ? error.message : "Impossible de calculer l'age.");
  } finally {
    predictButton.disabled = false;
    predictButton.textContent = "Calculer l'age";
  }
}

predictButton?.addEventListener("click", handlePredict);
refreshButton?.addEventListener("click", () => void loadTrees());
void loadTrees();
