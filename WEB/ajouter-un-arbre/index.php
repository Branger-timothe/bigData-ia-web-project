<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/includes/layout.php';

renderPageStart('Ajouter un arbre', 'add-tree');
?>
<section class="page-heading">
    <div>
        <p class="page-heading__eyebrow">Fonctionnalite 2</p>
        <h2>Ajouter un arbre</h2>
        <p>Le formulaire charge les referentiels depuis l'API puis enregistre un nouvel arbre en base.</p>
    </div>
</section>

<section class="panel panel--narrow">
    <div id="add-tree-alert" class="alert is-hidden" role="alert"></div>

    <form id="add-tree-form" class="form-grid">
        <label class="field">
            <span>Espece</span>
            <select id="espece_id" name="espece_id" required></select>
        </label>

        <div class="form-row form-row--triple">
            <label class="field">
                <span>Diametre du tronc (cm)</span>
                <input id="diametre_tronc" name="diametre_tronc" type="number" min="0" step="1" required>
            </label>
            <label class="field">
                <span>Hauteur totale (m)</span>
                <input id="hauteur_total" name="hauteur_total" type="number" min="0" step="1" required>
            </label>
            <label class="field">
                <span>Hauteur du tronc (m)</span>
                <input id="hauteur_tronc" name="hauteur_tronc" type="number" min="0" step="1" required>
            </label>
        </div>

        <div class="form-row">
            <label class="field">
                <span>Latitude</span>
                <input id="latitude" name="latitude" type="number" min="41" max="51.5" step="0.000001" placeholder="49.8489" required>
            </label>
            <label class="field">
                <span>Longitude</span>
                <input id="longitude" name="longitude" type="number" min="-5.5" max="9.8" step="0.000001" placeholder="3.2870" required>
            </label>
        </div>

        <p class="form-hint">
            Coordonnees attendues en degres decimaux pour la France metropolitaine.
            Exemple Saint-Quentin : latitude 49.8489, longitude 3.2870.
        </p>

        <div class="form-row">
            <label class="field">
                <span>Stade de developpement</span>
                <select id="stade_developpement" name="stade_developpement" required></select>
            </label>
            <label class="field">
                <span>Etat</span>
                <select id="etat_id" name="etat_id" required></select>
            </label>
        </div>

        <div class="form-row">
            <label class="field">
                <span>Type de port</span>
                <select id="type_port" name="type_port" required></select>
            </label>
            <label class="field">
                <span>Type de pied</span>
                <select id="type_pied" name="type_pied" required></select>
            </label>
        </div>

        <label class="checkbox-field">
            <input id="remarquable" name="remarquable" type="checkbox">
            <span>Arbre remarquable</span>
        </label>

        <div class="form-actions">
            <button id="add-tree-submit" class="button button--primary" type="submit">Enregistrer l'arbre</button>
            <a class="button button--ghost" href="/visualisation/">Voir les arbres</a>
        </div>
    </form>
</section>

<script type="module" src="/scripts/add-tree.js"></script>
<?php
renderPageEnd();
