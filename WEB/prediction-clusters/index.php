<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/layout.php';

renderPageStart('Prediction clusters', 'clusters');
?>
<section class="page-heading">
    <div>
        <p class="page-heading__eyebrow">Fonctionnalite 4</p>
        <h2>Prediction des clusters</h2>
        <p>Lance le modele KMeans du dossier IA et colore les arbres sur une carte selon leur cluster.</p>
    </div>
    <div class="page-heading__actions">
        <button id="predict-clusters-button" class="button button--primary" type="button">Predire les clusters</button>
    </div>
</section>

<div id="clusters-alert" class="alert is-hidden" role="alert"></div>

<section class="stats-grid" id="clusters-summary"></section>

<section class="panel">
    <div class="panel__header">
        <h3>Carte des clusters</h3>
        <p>Les couleurs proviennent du modele Python de clustering.</p>
    </div>
    <div id="clusters-map" class="map-canvas"></div>
</section>

<script src="https://cdn.plot.ly/plotly-2.35.2.min.js"></script>
<script type="module" src="/scripts/prediction-clusters.js"></script>
<?php
renderPageEnd();
