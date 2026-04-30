<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/layout.php';

$basePath = appBasePath();

renderPageStart('Prediction age', 'age');
?>
<section class="page-heading">
    <div>
        <p class="page-heading__eyebrow">Fonctionnalite 5</p>
        <h2>Prediction de l'age</h2>
        <p>Selectionne un arbre, appelle le modele Python d'age et affiche le resultat en direct.</p>
    </div>
</section>

<div id="age-alert" class="alert is-hidden" role="alert"></div>

<section class="panel">
    <div class="panel__header">
        <h3>Choisir un arbre</h3>
        <button id="age-refresh" class="button button--ghost" type="button">Rafraichir la liste</button>
    </div>
    <div class="table-wrap">
        <table class="data-table" id="age-table">
            <thead>
                <tr>
                    <th></th>
                    <th>ID</th>
                    <th>Espece</th>
                    <th>Stade</th>
                    <th>Diametre</th>
                    <th>Haut. totale</th>
                    <th>Haut. tronc</th>
                    <th>Age courant</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
    <div class="form-actions">
        <button id="predict-age-button" class="button button--primary" type="button">Calculer l'age</button>
    </div>
</section>

<section class="panel result-panel is-hidden" id="age-result-panel">
    <div class="result-panel__value" id="age-result-value"></div>
    <p class="result-panel__label" id="age-result-label"></p>
</section>

<script type="module" src="<?= htmlspecialchars($basePath . '/scripts/prediction-age.js', ENT_QUOTES, 'UTF-8') ?>"></script>
<?php
renderPageEnd();
