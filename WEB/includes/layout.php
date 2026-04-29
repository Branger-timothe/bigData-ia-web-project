<?php

declare(strict_types=1);

function navigationItems(): array
{
    return [
        ['href' => '/index.php', 'label' => 'Accueil', 'key' => 'home'],
        ['href' => '/ajouter-un-arbre/', 'label' => 'Ajouter un arbre', 'key' => 'add-tree'],
        ['href' => '/visualisation/', 'label' => 'Visualisation', 'key' => 'visualisation'],
        ['href' => '/prediction-clusters/', 'label' => 'Prediction clusters', 'key' => 'clusters'],
        ['href' => '/prediction-age/', 'label' => 'Prediction age', 'key' => 'age'],
    ];
}

function renderPageStart(string $title, string $activePage): void
{
    $fullTitle = $title . ' | Gestion du patrimoine arbore';
    ?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($fullTitle, ENT_QUOTES, 'UTF-8') ?></title>
    <link rel="stylesheet" href="/styles/site.css">
</head>
<body>
    <div class="site-shell">
        <header class="site-header">
            <div class="site-header__inner">
                <div class="site-brand">
                    <p class="site-brand__eyebrow">Projet ISEN 2026</p>
                    <h1 class="site-brand__title">Gestion du patrimoine arbore</h1>
                </div>
                <nav class="site-nav" aria-label="Navigation principale">
                    <ul class="site-nav__list">
                        <?php foreach (navigationItems() as $item): ?>
                            <li>
                                <a
                                    class="site-nav__link<?= $item['key'] === $activePage ? ' is-active' : '' ?>"
                                    href="<?= htmlspecialchars($item['href'], ENT_QUOTES, 'UTF-8') ?>"
                                >
                                    <?= htmlspecialchars($item['label'], ENT_QUOTES, 'UTF-8') ?>
                                </a>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                </nav>
            </div>
        </header>
        <main class="site-main">
<?php
}

function renderPageEnd(): void
{
    ?>
        </main>
        <footer class="site-footer">
            <div class="site-footer__inner">
                <p>Timothé Branger , Clément Cottel, Axel Brazeau</p>
            </div>
        </footer>
    </div>
</body>
</html>
<?php
}
