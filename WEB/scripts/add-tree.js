import { createTree, fetchReferences, hideAlert, showAlert } from "./api.js";

const form = document.getElementById("add-tree-form");
const alertBox = document.getElementById("add-tree-alert");
const submitButton = document.getElementById("add-tree-submit");

function fillSelect(select, values, mapper) {
  select.innerHTML = "";
  values.forEach((value) => {
    const option = document.createElement("option");
    const mapped = mapper(value);
    option.value = mapped.value;
    option.textContent = mapped.label;
    select.appendChild(option);
  });
}

async function loadReferences() {
  try {
    const data = await fetchReferences();
    fillSelect(document.getElementById("espece_id"), data.especes, (item) => ({
      value: String(item.id),
      label: item.libelle,
    }));
    fillSelect(document.getElementById("etat_id"), data.etats, (item) => ({
      value: String(item.id),
      label: item.libelle,
    }));
    fillSelect(document.getElementById("stade_developpement"), data.stades_developpement, (item) => ({
      value: item,
      label: item,
    }));
    fillSelect(document.getElementById("type_port"), data.types_port, (item) => ({
      value: item,
      label: item,
    }));
    fillSelect(document.getElementById("type_pied"), data.types_pied, (item) => ({
      value: item,
      label: item,
    }));
  } catch (error) {
    showAlert(alertBox, error instanceof Error ? error.message : "Impossible de charger les referentiels.");
  }
}

async function handleSubmit(event) {
  event.preventDefault();

  hideAlert(alertBox);

  const formData = new FormData(form);

  const total = Number(formData.get("hauteur_total"));
  const tronc = Number(formData.get("hauteur_tronc"));

  // 🔥 VALIDATION ICI
  if (tronc > total) {
    showAlert(alertBox, "Erreur : la hauteur du tronc ne peut pas être supérieure à la hauteur totale.", "error");
    return;
  }

  submitButton.disabled = true;
  submitButton.textContent = "Enregistrement...";

  const payload = {
    espece_id: Number(formData.get("espece_id")),
    etat_id: Number(formData.get("etat_id")),
    diametre_tronc: Number(formData.get("diametre_tronc")),
    hauteur_total: total,
    hauteur_tronc: tronc,
    latitude: Number(formData.get("latitude")),
    longitude: Number(formData.get("longitude")),
    stade_developpement: String(formData.get("stade_developpement") || ""),
    type_port: String(formData.get("type_port") || ""),
    type_pied: String(formData.get("type_pied") || ""),
    remarquable: document.getElementById("remarquable").checked,
  };

  try {
    const data = await createTree(payload);
    showAlert(alertBox, `Arbre ${data.id_arbre} enregistre avec succes.`, "success");

    form.reset();

    window.setTimeout(() => {
      window.location.href = "/visualisation/";
    }, 1200);

  } catch (error) {
    showAlert(alertBox, error instanceof Error ? error.message : "Erreur serveur");
  } finally {
    submitButton.disabled = false;
    submitButton.textContent = "Enregistrer l'arbre";
  }
}

form?.addEventListener("submit", handleSubmit);
void loadReferences();
