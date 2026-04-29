<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/bootstrap.php';

function getAgeModelScriptPath(): string
{
    return dirname(__DIR__, 2) . DIRECTORY_SEPARATOR
        . '..' . DIRECTORY_SEPARATOR
        . 'IA' . DIRECTORY_SEPARATOR
        . 'Besoin_Client_2' . DIRECTORY_SEPARATOR
        . 'pkl.py';
}

function getAgeModelPath(): string
{
    return dirname(__DIR__, 2) . DIRECTORY_SEPARATOR
        . '..' . DIRECTORY_SEPARATOR
        . 'IA' . DIRECTORY_SEPARATOR
        . 'Besoin_Client_2' . DIRECTORY_SEPARATOR
        . 'modele_final_prediction_age.pkl';
}

function resolvePythonExecutable(): string
{
    $configuredBinary = getenv('PYTHON_BIN');
    if (is_string($configuredBinary) && trim($configuredBinary) !== '' && is_file(trim($configuredBinary))) {
        return trim($configuredBinary);
    }

    $candidates = [
        'C:\\laragon\\bin\\python\\python-3.10\\python.exe',
        'C:\\Python313\\python.exe',
        'C:\\Python312\\python.exe',
        'C:\\Python311\\python.exe',
        'C:\\Python310\\python.exe',
        'python',
        'py',
    ];

    foreach ($candidates as $candidate) {
        if (is_file($candidate)) {
            return $candidate;
        }
    }

    return 'C:\\laragon\\bin\\python\\python-3.10\\python.exe';
}

function normalizeProcessOutput(string $value): string
{
    if (mb_check_encoding($value, 'UTF-8')) {
        return $value;
    }

    $converted = @iconv('Windows-1252', 'UTF-8//IGNORE', $value);
    if ($converted !== false && $converted !== '') {
        return $converted;
    }

    $converted = @iconv('ISO-8859-1', 'UTF-8//IGNORE', $value);
    if ($converted !== false && $converted !== '') {
        return $converted;
    }

    return preg_replace('/[^\x20-\x7E]/', '', $value) ?? '';
}

function predictAgeFromTree(array $tree): float
{
    $scriptPath = getAgeModelScriptPath();
    $modelPath = getAgeModelPath();

    if (!is_file($scriptPath)) {
        throw new RuntimeException(sprintf('Script de prediction introuvable : %s', $scriptPath));
    }

    if (!is_file($modelPath)) {
        throw new RuntimeException(sprintf('Modele de prediction introuvable : %s', $modelPath));
    }

    $pythonBinary = resolvePythonExecutable();
    $commandParts = [
        escapeshellarg($pythonBinary),
        escapeshellarg($scriptPath),
        '--tronc_diam',
        escapeshellarg((string) $tree['diametre_tronc']),
        '--haut_tot',
        escapeshellarg((string) $tree['hauteur_total']),
        '--haut_tronc',
        escapeshellarg((string) $tree['hauteur_tronc']),
        '--fk_stadedev',
        escapeshellarg(mb_strtolower((string) $tree['stade_developpement'])),
        '--nomfrancais',
        escapeshellarg(mb_strtolower((string) $tree['nomfrancais'])),
        '--modele',
        escapeshellarg($modelPath),
    ];

    $command = implode(' ', $commandParts) . ' 2>&1';
    $outputLines = [];
    $exitCode = 0;

    exec($command, $outputLines, $exitCode);

    if ($exitCode !== 0) {
        $processOutput = normalizeProcessOutput(trim(implode(PHP_EOL, $outputLines)));
        throw new RuntimeException(
            "Echec de l'appel au modele d'age : " . $processOutput
        );
    }

    $output = normalizeProcessOutput(trim(implode(PHP_EOL, $outputLines)));

    if (!preg_match('/([-+]?\d+(?:[.,]\d+)?)/u', $output, $matches)) {
        throw new RuntimeException("Sortie du modele d'age illisible : " . $output);
    }

    return (float) str_replace(',', '.', $matches[1]);
}

function ageCategory(int $age): string
{
    if ($age < 20) {
        return 'Tres jeune';
    }
    if ($age < 50) {
        return 'Jeune';
    }
    if ($age < 80) {
        return 'Adulte';
    }
    if ($age < 120) {
        return 'Mature';
    }

    return 'Tres vieux';
}

try {
    requireMethod('POST');

    $payload = getJsonInput();
    $treeId = trim((string) ($payload['id_arbre'] ?? ''));

    if ($treeId === '') {
        sendError('Le champ "id_arbre" est obligatoire.', 422);
    }

    $pdo = getDatabaseConnection();
    $tree = fetchTreeById($pdo, $treeId);

    if ($tree === null) {
        sendError('Arbre introuvable.', 404);
    }

    $predictedAge = predictAgeFromTree($tree);
    $roundedAge = (int) round($predictedAge);
    setAgePrediction($treeId, $roundedAge);

    $updatedTree = fetchTreeById($pdo, $treeId);

    sendSuccess([
        'tree' => $updatedTree,
        'predicted_age' => $roundedAge,
        'category' => ageCategory($roundedAge),
        'source' => 'python_model',
    ], 'Age predit.');
} catch (Throwable $exception) {
    sendError("Impossible de predire l'age.", 500, [
        'error' => $exception->getMessage(),
    ]);
}
