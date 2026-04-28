import os
import pandas as pd
import numpy as np
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering, MeanShift, SpectralClustering
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score
from sklearn.preprocessing import StandardScaler
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# ── Chargement des données ──
file_path = '../../IA1/export_IA.csv'
if not os.path.exists(file_path):
    raise FileNotFoundError(f"Fichier introuvable : {file_path}")

data = pd.read_csv(file_path)
features = data[['haut_tot', 'tronc_diam', 'age_estim']].dropna()

# ── Algorithmes à tester (tous avec 3 clusters quand applicable) ──
algorithms = {
    'K-Means':               KMeans(n_clusters=2, random_state=42),
    'Agglomeratif\n(Ward)':  AgglomerativeClustering(n_clusters=2, linkage='ward'),
    'Agglomeratif\n(Complete)': AgglomerativeClustering(n_clusters=2, linkage='complete'),
    'Agglomeratif\n(Average)':  AgglomerativeClustering(n_clusters=2, linkage='average'),
    'Spectral':              SpectralClustering(n_clusters=2, random_state=42, n_neighbors=10),
}

# ── Calcul des métriques pour chaque algo ──
results = []

print("\n─── Comparaison des algorithmes de clustering ───────────────────────────────")
print(f"{'Algorithme':<25} {'Silhouette':>12} {'Calinski-Harabasz':>20} {'Davies-Bouldin':>16} {'Nb clusters':>12}")
print("─" * 87)

for name, algo in algorithms.items():
    clean_name = name.replace('\n', ' ')
    try:
        labels = algo.fit_predict(features)
        n_clusters = len(set(labels)) - (1 if -1 in labels else 0)

        if n_clusters < 2:
            print(f"{clean_name:<25} {'< 2 clusters trouvés — ignoré':>60}")
            continue

        sil = silhouette_score(features, labels)
        cal = calinski_harabasz_score(features, labels)
        dav = davies_bouldin_score(features, labels)

        results.append({
            'algo':       clean_name,
            'silhouette': sil,
            'calinski':   cal,
            'davies':     dav,
            'n_clusters': n_clusters
        })

        print(f"{clean_name:<25} {sil:>12.4f} {cal:>20.2f} {dav:>16.4f} {n_clusters:>12}")

    except Exception as e:
        print(f"{clean_name:<25} Erreur : {e}")

print("─" * 87)

df_results = pd.DataFrame(results)

# ── Identifier le meilleur algo pour chaque métrique ──
best_sil = df_results.loc[df_results['silhouette'].idxmax(), 'algo']
best_cal = df_results.loc[df_results['calinski'].idxmax(), 'algo']
best_dav = df_results.loc[df_results['davies'].idxmin(), 'algo']

print(f"\n  Meilleur Silhouette      → {best_sil}")
print(f"  Meilleur Calinski-Harabasz → {best_cal}")
print(f"  Meilleur Davies-Bouldin  → {best_dav}\n")

# ── Couleurs par algo ──
colors = ['royalblue', 'green', 'tomato', 'orange', 'purple', 'teal']
algo_colors = {algo: colors[i % len(colors)] for i, algo in enumerate(df_results['algo'])}

# ══════════════════════════════════════════════════════════════
# GRAPHIQUE 1 — Barres comparatives des 3 métriques
# ══════════════════════════════════════════════════════════════
fig1 = make_subplots(
    rows=1, cols=3,
    subplot_titles=(
        "Silhouette ↑ (max = meilleur)",
        "Calinski-Harabasz ↑ (max = meilleur)",
        "Davies-Bouldin ↓ (min = meilleur)"
    )
)

for i, algo in enumerate(df_results['algo']):
    row_data = df_results[df_results['algo'] == algo].iloc[0]
    color = algo_colors[algo]

    fig1.add_trace(go.Bar(
        x=[algo], y=[row_data['silhouette']],
        name=algo, marker_color=color,
        showlegend=(i == 0)
    ), row=1, col=1)

    fig1.add_trace(go.Bar(
        x=[algo], y=[row_data['calinski']],
        name=algo, marker_color=color,
        showlegend=False
    ), row=1, col=2)

    fig1.add_trace(go.Bar(
        x=[algo], y=[row_data['davies']],
        name=algo, marker_color=color,
        showlegend=False
    ), row=1, col=3)

fig1.update_layout(
    title="Comparaison des algorithmes de clustering — Métriques",
    height=500,
    showlegend=False,
    bargap=0.3
)
fig1.update_xaxes(tickangle=-30)
fig1.show()

# ══════════════════════════════════════════════════════════════
# GRAPHIQUE 2 — Radar chart (vue synthétique)
# ══════════════════════════════════════════════════════════════

# Normaliser les métriques entre 0 et 1 pour le radar
# Silhouette et Calinski : plus grand = mieux → normalisation directe
# Davies-Bouldin : plus petit = mieux → on inverse
df_radar = df_results.copy()
df_radar['sil_norm'] = (df_radar['silhouette'] - df_radar['silhouette'].min()) / \
                       (df_radar['silhouette'].max() - df_radar['silhouette'].min() + 1e-9)
df_radar['cal_norm'] = (df_radar['calinski'] - df_radar['calinski'].min()) / \
                       (df_radar['calinski'].max() - df_radar['calinski'].min() + 1e-9)
df_radar['dav_norm'] = 1 - (df_radar['davies'] - df_radar['davies'].min()) / \
                           (df_radar['davies'].max() - df_radar['davies'].min() + 1e-9)

categories = ['Silhouette', 'Calinski-Harabasz', 'Davies-Bouldin (inv.)']

fig2 = go.Figure()

for i, row in df_radar.iterrows():
    values = [row['sil_norm'], row['cal_norm'], row['dav_norm']]
    values += values[:1]  # fermer le polygone
    fig2.add_trace(go.Scatterpolar(
        r=values,
        theta=categories + [categories[0]],
        fill='toself',
        name=row['algo'],
        line=dict(color=algo_colors[row['algo']], width=2),
        opacity=0.6
    ))

fig2.update_layout(
    polar=dict(radialaxis=dict(visible=True, range=[0, 1])),
    title="Radar — Performance globale normalisée par algorithme",
    height=500
)
fig2.show()

# ══════════════════════════════════════════════════════════════
# GRAPHIQUE 3 — Score global (moyenne des 3 métriques normalisées)
# ══════════════════════════════════════════════════════════════
df_radar['score_global'] = (df_radar['sil_norm'] + df_radar['cal_norm'] + df_radar['dav_norm']) / 3
df_radar_sorted = df_radar.sort_values('score_global', ascending=True)

fig3 = go.Figure(go.Bar(
    x=df_radar_sorted['score_global'],
    y=df_radar_sorted['algo'],
    orientation='h',
    marker_color=[algo_colors[a] for a in df_radar_sorted['algo']],
    text=[f"{v:.3f}" for v in df_radar_sorted['score_global']],
    textposition='outside'
))

fig3.update_layout(
    title="Score global normalisé par algorithme (plus haut = meilleur)",
    xaxis_title="Score global (0 → 1)",
    height=400,
    xaxis=dict(range=[0, 1.15])
)
fig3.show()

# ── Conclusion ──
best_overall = df_radar.loc[df_radar['score_global'].idxmax(), 'algo']
print(f"  Meilleur algorithme global → {best_overall}")