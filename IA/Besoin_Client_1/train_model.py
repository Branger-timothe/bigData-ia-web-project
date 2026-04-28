import os

import joblib
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score
import plotly.express as px
from pyproj import Transformer
import plotly.graph_objects as go
from plotly.subplots import make_subplots
transformer = Transformer.from_crs("EPSG:3949", "EPSG:4326", always_xy=True)



# Charger les données
file_path = '../Data/export_IA.csv'
if not os.path.exists(file_path):
    raise FileNotFoundError(f"Le fichier spécifié n'existe pas: {file_path}")

data = pd.read_csv(file_path)
etats_a_supprimer = ['Mort', 'Abattu', 'A abattre']
data = data[~data['fk_arb_etat'].isin(etats_a_supprimer)]
data_filtered = data[['Y', 'X', 'haut_tot', 'tronc_diam','age_estim']].copy()
# Liste des états à supprimer


# Conversion X/Y -> longitude/latitude (Y et X inversés)
lon, lat = transformer.transform(
    data_filtered['X'].values,
    data_filtered['Y'].values
)

data_filtered['longitude'] = lon
data_filtered['latitude'] = lat

# Clustering K-Means
data_scaled = data[['haut_tot', 'tronc_diam', 'age_estim']]

kmeans = KMeans(n_clusters=3, random_state=42)
data_filtered['cluster'] = kmeans.fit_predict(data_scaled)
joblib.dump(kmeans, 'kmeans_model.pkl')
# Mapper les clusters à des catégories
cluster_map = {0: 'Petit', 1: 'Moyen', 2: 'Grand'}
data_filtered['taille'] = data_filtered['cluster'].map(cluster_map)

cluster_range = range(2, 4)
silhouette_scores = []
calinski_harabasz_scores = []
davies_bouldin_scores = []
for n_clusters in cluster_range:
    kmeans_temp = KMeans(n_clusters=n_clusters, random_state=42)
    labels = kmeans_temp.fit_predict(data_scaled)
    silhouette_scores.append(silhouette_score(data_scaled, labels))
    calinski_harabasz_scores.append(calinski_harabasz_score(data_scaled, labels))
    davies_bouldin_scores.append(davies_bouldin_score(data_scaled, labels))

print("\n─── Résultats des métriques de clustering ───────────────────")
print(f"{'Clusters':<12} {'Silhouette':>12} {'Calinski-Harabasz':>20} {'Davies-Bouldin':>16}")
print("─" * 62)
for n, sil, cal, dav in zip(cluster_range, silhouette_scores, calinski_harabasz_scores, davies_bouldin_scores):
    print(f"{n:<12} {sil:>12.4f} {cal:>20.2f} {dav:>16.4f}")
print("─" * 62)


fig_metrics = make_subplots(rows=1, cols=3, subplot_titles=(
    "Silhouette  (max = meilleur)",
    "Calinski-Harabasz (max = meilleur)",
    "Davies-Bouldin  (min = meilleur)"
))

k_values = list(cluster_range)

fig_metrics.add_trace(go.Scatter(
    x=k_values, y=silhouette_scores,
    mode='lines+markers', name='Silhouette',
    line=dict(color='royalblue', width=2),
    marker=dict(size=8)
), row=1, col=1)

fig_metrics.add_trace(go.Scatter(
    x=k_values, y=calinski_harabasz_scores,
    mode='lines+markers', name='Calinski-Harabasz',
    line=dict(color='green', width=2),
    marker=dict(size=8)
), row=1, col=2)

fig_metrics.add_trace(go.Scatter(
    x=k_values, y=davies_bouldin_scores,
    mode='lines+markers', name='Davies-Bouldin',
    line=dict(color='tomato', width=2),
    marker=dict(size=8)
), row=1, col=3)

# ── Méthode du coude ──
inertias = []
k_range = range(2, 6)

for k in k_range:
    kmeans_temp = KMeans(n_clusters=k, random_state=42)
    kmeans_temp.fit(data_scaled)
    inertias.append(kmeans_temp.inertia_)

fig_coude = go.Figure()
fig_coude.add_trace(go.Scatter(
    x=list(k_range),
    y=inertias,
    mode='lines+markers',
    line=dict(color='royalblue', width=2),
    marker=dict(size=8)
))

# Ligne verticale sur k=3
fig_coude.add_vline(
    x=3,
    line_dash="dash",
    line_color="orange",
    annotation_text="k=3 choisi",
    annotation_position="top right"
)

fig_coude.update_layout(
    title="Méthode du coude",
    xaxis_title="Nombre de clusters (k)",
    yaxis_title="Inertie (intra-cluster)",
    height=450
)
fig_coude.show()

# Ligne verticale pour k=3 choisi
for col in range(1, 4):
    fig_metrics.add_vline(
        x=3, line_dash="dash",
        line_color="orange",
        annotation_text="k=3 choisi",
        annotation_position="top right",
        row=1, col=col
    )

fig_metrics.update_xaxes(title_text="Nombre de clusters (k)", dtick=1)
fig_metrics.update_layout(
    title="Comparaison des métriques selon le nombre de clusters",
    showlegend=False,
    height=400
)

fig_metrics.show()

# Carte avec Plotly
fig = px.scatter_map(
    data_filtered,
    lat='latitude',
    lon='longitude',
    color='taille',
    color_discrete_map={
        'Petit': 'palegreen',
        'Moyen': 'limegreen',
        'Grand': 'forestgreen'
    },
    size='haut_tot',
    hover_data={
        'haut_tot': True,
        'tronc_diam': True,
        'age_estim': True,
        'taille': True,
        'latitude': False,
        'longitude': False
    },
    hover_name='taille',
    zoom=13,
    title="Carte des arbres par taille"
)
fig.show()