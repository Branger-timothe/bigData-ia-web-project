<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/layout.php';

$basePath = appBasePath();

renderPageStart('Visualisation', 'visualisation');
?>
<section class="page-heading">
    <div>
        <p class="page-heading__eyebrow">Fonctionnalite 3</p>
        <h2>Visualisation des arbres</h2>
        <p>Consulte les arbres stockes dans la base et affiche leur position sur une carte Plotly.</p>
    </div>
    <div class="page-heading__actions">
        <a class="button button--secondary" href="<?= htmlspecialchars($basePath . '/prediction-clusters/', ENT_QUOTES, 'UTF-8') ?>">Predire les clusters</a>
        <a class="button button--secondary" href="<?= htmlspecialchars($basePath . '/prediction-age/', ENT_QUOTES, 'UTF-8') ?>">Predire l'age</a>
    </div>
</section>

<div id="visualisation-alert" class="alert is-hidden" role="alert"></div>

<section class="panel">
    <div class="panel__header">
        <div>
            <h3>Carte interactive</h3>
            <p id="visualisation-focus">Carte centree sur la vue globale autour de Saint-Quentin.</p>
        </div>
        <p id="visualisation-count">Chargement des arbres...</p>
    </div>
    <div id="visualisation-map" class="map-canvas"></div>
</section>

<section class="panel">
    <div class="panel__header">
        <h3>Tableau des arbres</h3>
        <p>Chaque ligne expose les donnees principales, ainsi que les predictions deja calculees.</p>
    </div>
    <div class="table-wrap">
        <table class="data-table" id="visualisation-table">
            <thead>
                <tr>
                    <th>Focus carte</th>
                    <th>ID</th>
                    <th>Espece</th>
                    <th>Diametre</th>
                    <th>Haut. totale</th>
                    <th>Haut. tronc</th>
                    <th>Latitude</th>
                    <th>Longitude</th>
                    <th>Etat</th>
                    <th>Stade</th>
                    <th>Type port</th>
                    <th>Type pied</th>
                    <th>Remarquable</th>
                    <th>Age</th>
                    <th>Cluster</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
    <div class="pagination" aria-label="Pagination du tableau">
        <button type="button" class="button button--ghost" id="visualisation-prev-page">Page precedente</button>
        <p id="visualisation-page-info">Page 1 sur 1</p>
        <button type="button" class="button button--ghost" id="visualisation-next-page">Page suivante</button>
    </div>
</section>

<script src="https://cdn.plot.ly/plotly-2.35.2.min.js"></script>
<script type="module" src="<?= htmlspecialchars($basePath . '/scripts/visualisation.js', ENT_QUOTES, 'UTF-8') ?>"></script>
<?php
renderPageEnd();
