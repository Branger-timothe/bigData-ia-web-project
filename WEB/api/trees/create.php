<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/bootstrap.php';

const FRANCE_MIN_LATITUDE = 41.0;
const FRANCE_MAX_LATITUDE = 51.5;
const FRANCE_MIN_LONGITUDE = -5.5;
const FRANCE_MAX_LONGITUDE = 9.8;

function normalizeString(array $payload, string $key): string
{
    $value = trim((string) ($payload[$key] ?? ''));
    if ($value === '') {
        sendError(sprintf('Le champ "%s" est obligatoire.', $key), 422);
    }

    return $value;
}

function normalizeInteger(array $payload, string $key): int
{
    if (!isset($payload[$key]) || $payload[$key] === '') {
        sendError(sprintf('Le champ "%s" est obligatoire.', $key), 422);
    }

    if (filter_var($payload[$key], FILTER_VALIDATE_INT) === false) {
        sendError(sprintf('Le champ "%s" doit etre un entier.', $key), 422);
    }

    return (int) $payload[$key];
}

function normalizeFloat(array $payload, string $key): float
{
    if (!isset($payload[$key]) || $payload[$key] === '') {
        sendError(sprintf('Le champ "%s" est obligatoire.', $key), 422);
    }

    if (!is_numeric($payload[$key])) {
        sendError(sprintf('Le champ "%s" doit etre numerique.', $key), 422);
    }

    return (float) $payload[$key];
}

function normalizeBoolean(array $payload, string $key): int
{
    if (!array_key_exists($key, $payload)) {
        sendError(sprintf('Le champ "%s" est obligatoire.', $key), 422);
    }

    $value = filter_var($payload[$key], FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
    if ($value === null) {
        sendError(sprintf('Le champ "%s" doit etre un booleen.', $key), 422);
    }

    return $value ? 1 : 0;
}

try {
    requireMethod('POST');

    $payload = getJsonInput();

    $treeId = trim((string) ($payload['id_arbre'] ?? ''));
    if ($treeId === '') {
        $treeId = strtoupper(uniqid('ARB', false));
    }

    $heightTotal = normalizeInteger($payload, 'hauteur_total');
    $heightTrunk = normalizeInteger($payload, 'hauteur_tronc');
    $trunkDiameter = normalizeInteger($payload, 'diametre_tronc');
    $developmentStage = normalizeString($payload, 'stade_developpement');
    $portType = normalizeString($payload, 'type_port');
    $footType = normalizeString($payload, 'type_pied');
    $remarkable = normalizeBoolean($payload, 'remarquable');
    $longitude = normalizeFloat($payload, 'longitude');
    $latitude = normalizeFloat($payload, 'latitude');
    $speciesId = normalizeInteger($payload, 'espece_id');
    $stateId = normalizeInteger($payload, 'etat_id');

    if ($heightTotal < 0 || $heightTrunk < 0 || $trunkDiameter < 0) {
        sendError('Les dimensions doivent etre positives ou nulles.', 422);
    }

    if ($latitude < FRANCE_MIN_LATITUDE || $latitude > FRANCE_MAX_LATITUDE) {
        sendError(
            sprintf(
                'La latitude doit etre comprise entre %.1f et %.1f pour la France metropolitaine.',
                FRANCE_MIN_LATITUDE,
                FRANCE_MAX_LATITUDE
            ),
            422
        );
    }

    if ($longitude < FRANCE_MIN_LONGITUDE || $longitude > FRANCE_MAX_LONGITUDE) {
        sendError(
            sprintf(
                'La longitude doit etre comprise entre %.1f et %.1f pour la France metropolitaine.',
                FRANCE_MIN_LONGITUDE,
                FRANCE_MAX_LONGITUDE
            ),
            422
        );
    }

    $pdo = getDatabaseConnection();

    $speciesExists = $pdo->prepare('SELECT COUNT(*) FROM espece WHERE id = :id');
    $speciesExists->execute(['id' => $speciesId]);
    if ((int) $speciesExists->fetchColumn() === 0) {
        sendError("L'espece fournie est introuvable.", 422);
    }

    $stateExists = $pdo->prepare('SELECT COUNT(*) FROM etat WHERE id = :id');
    $stateExists->execute(['id' => $stateId]);
    if ((int) $stateExists->fetchColumn() === 0) {
        sendError("L'etat fourni est introuvable.", 422);
    }

    $statement = $pdo->prepare(
        'INSERT INTO arbre (
            id_arbre,
            hauteur_total,
            hauteur_tronc,
            diametre_tronc,
            stade_developpement,
            type_port,
            type_pied,
            remarquable,
            longitude,
            latitude,
            espece_id,
            etat_id
        ) VALUES (
            :id_arbre,
            :hauteur_total,
            :hauteur_tronc,
            :diametre_tronc,
            :stade_developpement,
            :type_port,
            :type_pied,
            :remarquable,
            :longitude,
            :latitude,
            :espece_id,
            :etat_id
        )'
    );

    $statement->execute([
        'id_arbre' => $treeId,
        'hauteur_total' => $heightTotal,
        'hauteur_tronc' => $heightTrunk,
        'diametre_tronc' => $trunkDiameter,
        'stade_developpement' => $developmentStage,
        'type_port' => $portType,
        'type_pied' => $footType,
        'remarquable' => $remarkable,
        'longitude' => $longitude,
        'latitude' => $latitude,
        'espece_id' => $speciesId,
        'etat_id' => $stateId,
    ]);

    sendSuccess([
        'id_arbre' => $treeId,
    ], 'Arbre cree.', 201);
} catch (PDOException $exception) {
    sendError("Impossible de creer l'arbre.", 500, [
        'error' => $exception->getMessage(),
    ]);
} catch (Throwable $exception) {
    sendError("Erreur inattendue lors de la creation de l'arbre.", 500, [
        'error' => $exception->getMessage(),
    ]);
}
