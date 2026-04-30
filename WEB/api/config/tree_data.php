<?php

declare(strict_types=1);

function getPredictionStore(): array
{
    if (!isset($_SESSION['tree_predictions']) || !is_array($_SESSION['tree_predictions'])) {
        $_SESSION['tree_predictions'] = [
            'age' => [],
            'cluster' => [],
        ];
    }

    return $_SESSION['tree_predictions'];
}

function setAgePrediction(string $treeId, int $age): void
{
    $store = getPredictionStore();
    $store['age'][$treeId] = $age;
    $_SESSION['tree_predictions'] = $store;
}

function setClusterPrediction(string $treeId, int $cluster): void
{
    $store = getPredictionStore();
    $store['cluster'][$treeId] = $cluster;
    $_SESSION['tree_predictions'] = $store;
}

function getAgePrediction(string $treeId): ?int
{
    $store = getPredictionStore();
    return isset($store['age'][$treeId]) ? (int) $store['age'][$treeId] : null;
}

function getClusterPrediction(string $treeId): ?int
{
    $store = getPredictionStore();
    return isset($store['cluster'][$treeId]) ? (int) $store['cluster'][$treeId] : null;
}

function mapTreeRow(array $row): array
{
    $treeId = (string) $row['id_arbre'];

    return [
        'id_arbre' => $treeId,
        'nomfrancais' => $row['nomfrancais'],
        'espece_id' => (int) $row['espece_id'],
        'hauteur_total' => (int) $row['hauteur_total'],
        'hauteur_tronc' => (int) $row['hauteur_tronc'],
        'diametre_tronc' => (int) $row['diametre_tronc'],
        'stade_developpement' => $row['stade_developpement'],
        'type_port' => $row['type_port'],
        'type_pied' => $row['type_pied'],
        'remarquable' => (bool) $row['remarquable'],
        'longitude' => (float) $row['longitude'],
        'latitude' => (float) $row['latitude'],
        'etat_id' => (int) $row['etat_id'],
        'etat' => $row['etat'],
        'age' => getAgePrediction($treeId),
        'cluster' => getClusterPrediction($treeId),
    ];
}

function fetchAllTrees(PDO $pdo): array
{
    $statement = $pdo->query(buildTreeSelectQuery() . ' ORDER BY a.id_arbre');

    return array_map('mapTreeRow', $statement->fetchAll());
}

function countTrees(PDO $pdo): int
{
    $statement = $pdo->query('SELECT COUNT(*) FROM arbre');
    return (int) $statement->fetchColumn();
}

function fetchTreesPage(PDO $pdo, int $page, int $limit): array
{
    $offset = max(0, ($page - 1) * $limit);
    $statement = $pdo->prepare(buildTreeSelectQuery() . ' ORDER BY a.id_arbre LIMIT :limit OFFSET :offset');
    $statement->bindValue(':limit', $limit, PDO::PARAM_INT);
    $statement->bindValue(':offset', $offset, PDO::PARAM_INT);
    $statement->execute();

    return array_map('mapTreeRow', $statement->fetchAll());
}

function fetchTreeById(PDO $pdo, string $treeId): ?array
{
    $statement = $pdo->prepare(
        buildTreeSelectQuery() . ' WHERE a.id_arbre = :id_arbre'
    );
    $statement->execute(['id_arbre' => $treeId]);
    $row = $statement->fetch();

    return $row ? mapTreeRow($row) : null;
}

function buildTreeSelectQuery(): string
{
    return 'SELECT
        a.id_arbre,
        a.hauteur_total,
        a.hauteur_tronc,
        a.diametre_tronc,
        a.stade_developpement,
        a.type_port,
        a.type_pied,
        a.remarquable,
        a.longitude,
        a.latitude,
        e.id AS espece_id,
        e.libelle AS nomfrancais,
        et.id AS etat_id,
        et.libelle AS etat
    FROM arbre a
    INNER JOIN espece e ON e.id = a.espece_id
    INNER JOIN etat et ON et.id = a.etat_id';
}
