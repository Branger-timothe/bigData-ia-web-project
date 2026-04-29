<?php

declare(strict_types=1);

require_once __DIR__ . '/config/bootstrap.php';

try {
    requireMethod('GET');

    $pdo = getDatabaseConnection();

    $species = $pdo->query('SELECT id, libelle FROM espece ORDER BY libelle')->fetchAll();
    $states = $pdo->query('SELECT id, libelle FROM etat ORDER BY libelle')->fetchAll();

    sendSuccess([
        'especes' => $species,
        'etats' => $states,
        'stades_developpement' => ['Jeune', 'Adulte', 'Mature', 'Sénescent'],
        'types_port' => ['Colonnaire', 'Étalé', 'Arrondi', 'Ovoïde', 'Pleureur'],
        'types_pied' => ['Isolé', 'Alignement', 'Parc', 'Forêt'],
    ], 'Référentiels récupérés.');
} catch (Throwable $exception) {
    sendError('Impossible de récupérer les référentiels.', 500, [
        'error' => $exception->getMessage(),
    ]);
}
