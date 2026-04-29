<?php

declare(strict_types=1);

require_once __DIR__ . '/includes/layout.php';

renderPageStart('Accueil', 'home');
?>
<section class="hero-card">
    <div class="hero-card__content">
        <p class="hero-card__kicker">Ville de Saint-Quentin</p>
        <h2 class="hero-card__title">Piloter le patrimoine arbore avec une interface simple et exploitable</h2>
        <p class="hero-card__text">
            Cette application permet d'ajouter de nouveaux arbres, de consulter les donnees
            dans un tableau et sur une carte, puis de lancer des predictions fondees sur les
            scripts Python du projet IA.
        </p>
        <div class="hero-card__actions">
            <a class="button button--primary" href="/ajouter-un-arbre/">Ajouter un arbre</a>
            <a class="button button--secondary" href="/visualisation/">Voir la visualisation</a>
        </div>
    </div>
    <div class="hero-card__visual">
        <img
            src="https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1000&h=680&fit=crop"
            alt="Canopée et arbres en lumiere"
        >
    </div>
</section>

<section class="panel-grid">
    <article class="panel">
        <h3>Fonctionnalites</h3>
        <ul class="feature-list">
            <li>Ajout d'arbres avec formulaire connecte a la base</li>
            <li>Visualisation tabulaire et cartographique des arbres</li>
            <li>Prediction du cluster par script Python IA</li>
            <li>Prediction de l'age par modele IA</li>
        </ul>
    </article>
    <article class="panel">
        <h3>Architecture</h3>
        <ul class="feature-list">
            <li>Pages PHP simples avec entete et pied de page communs</li>
            <li>JavaScript natif pour la navigation fonctionnelle et les appels AJAX</li>
            <li>Endpoints PHP JSON pour les operations metier</li>
            <li>Modeles Python appeles cote serveur</li>
        </ul>
    </article>
</section>
<?php
renderPageEnd();
