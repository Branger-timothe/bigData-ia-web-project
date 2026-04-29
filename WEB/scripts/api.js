const API_BASE = `${window.location.origin}/api`;

async function parseApiResponse(response) {
  let payload;

  try {
    payload = await response.json();
  } catch (error) {
    throw new Error("Reponse API invalide.");
  }

  if (!response.ok || !payload.success) {
    throw new Error(payload.message || "Erreur API.");
  }

  return payload.data;
}

async function request(path, options = {}) {
  const response = await fetch(`${API_BASE}${path}`, {
    method: options.method || "GET",
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    credentials: "same-origin",
    body: options.body || undefined,
  });

  return parseApiResponse(response);
}

export async function fetchReferences() {
  return request("/references.php");
}

export async function fetchTrees() {
  const data = await request("/trees/list.php");
  return data.trees || [];
}

export async function createTree(payload) {
  return request("/trees/create.php", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function predictAge(treeId) {
  return request("/predictions/age.php", {
    method: "POST",
    body: JSON.stringify({ id_arbre: treeId }),
  });
}

export async function predictClusters() {
  return request("/predictions/clusters.php", {
    method: "POST",
    body: JSON.stringify({}),
  });
}

export function showAlert(element, message, type = "error") {
  if (!element) {
    return;
  }

  element.textContent = message;
  element.className = `alert is-${type}`;
}

export function hideAlert(element) {
  if (!element) {
    return;
  }

  element.textContent = "";
  element.className = "alert is-hidden";
}

export function formatTreeLabel(tree) {
  return `${tree.nomfrancais} · ${tree.hauteur_total} m · ${tree.diametre_tronc} cm`;
}

export function formatAge(age) {
  return age === null || age === undefined ? "Non calcule" : `${age} ans`;
}

export function formatCluster(cluster) {
  return cluster === null || cluster === undefined ? "Non calcule" : `Cluster ${cluster}`;
}
