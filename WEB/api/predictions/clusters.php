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

function getClusterModelScriptPath(): string
{
    return dirname(__DIR__, 2) . DIRECTORY_SEPARATOR
        . '..' . DIRECTORY_SEPARATOR
        . 'IA' . DIRECTORY_SEPARATOR
        . 'Besoin_Client_1' . DIRECTORY_SEPARATOR
        . 'predict_cluster.py';
}

function getClusterModelWorkingDirectory(): string
{
    return dirname(__DIR__, 2) . DIRECTORY_SEPARATOR
        . '..' . DIRECTORY_SEPARATOR
        . 'IA' . DIRECTORY_SEPARATOR
        . 'Besoin_Client_1';
}

function resolvePythonExecutable(): string
{
    $configuredBinary = getenv('PYTHON_BIN');
    if (is_string($configuredBinary) && trim($configuredBinary) !== '') {
        return trim($configuredBinary);
    }

    $candidates = [
        'C:\\laragon\\bin\\python\\python-3.10\\python.exe',
        'C:\\Python313\\python.exe',
        'C:\\Python312\\python.exe',
        'C:\\Python311\\python.exe',
        'C:\\Python310\\python.exe',
        'python3',
        'python',
        'py',
    ];

    foreach ($candidates as $candidate) {
        if (is_file($candidate) || commandExists($candidate)) {
            return $candidate;
        }
    }

    return 'python3';
}

function commandExists(string $command): bool
{
    if ($command === '') {
        return false;
    }

    $lookupCommand = strtoupper(substr(PHP_OS_FAMILY, 0, 3)) === 'WIN'
        ? 'where ' . escapeshellarg($command) . ' 2>NUL'
        : 'command -v ' . escapeshellarg($command) . ' 2>/dev/null';

    $output = [];
    $exitCode = 1;
    exec($lookupCommand, $output, $exitCode);

    return $exitCode === 0;
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

function runPythonCommand(array $commandParts, ?string $workingDirectory = null): string
{
    $command = implode(' ', $commandParts);
    $descriptors = [
        0 => ['pipe', 'r'],
        1 => ['pipe', 'w'],
        2 => ['pipe', 'w'],
    ];

    $process = proc_open($command, $descriptors, $pipes, $workingDirectory);

    if (!is_resource($process)) {
        throw new RuntimeException('Impossible de demarrer le processus Python.');
    }

    fclose($pipes[0]);
    $stdout = stream_get_contents($pipes[1]);
    $stderr = stream_get_contents($pipes[2]);
    fclose($pipes[1]);
    fclose($pipes[2]);

    $exitCode = proc_close($process);
    $output = normalizeProcessOutput(trim((string) $stdout . PHP_EOL . (string) $stderr));

    if ($exitCode !== 0) {
        throw new RuntimeException($output !== '' ? $output : 'Execution Python echouee.');
    }

    return $output;
}

function predictAgeFromTree(array $tree): int
{
    $scriptPath = getAgeModelScriptPath();
    $modelPath = getAgeModelPath();

    if (!is_file($scriptPath)) {
        throw new RuntimeException(sprintf('Script de prediction d\'age introuvable : %s', $scriptPath));
    }

    if (!is_file($modelPath)) {
        throw new RuntimeException(sprintf('Modele de prediction d\'age introuvable : %s', $modelPath));
    }

    $pythonBinary = resolvePythonExecutable();
    $output = runPythonCommand([
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
    ]);

    if (!preg_match('/([-+]?\d+(?:[.,]\d+)?)/u', $output, $matches)) {
        throw new RuntimeException("Sortie du modele d'age illisible : " . $output);
    }

    return (int) round((float) str_replace(',', '.', $matches[1]));
}

function predictClusterFromTree(array $tree, int $age): array
{
    $scriptPath = getClusterModelScriptPath();
    $workingDirectory = getClusterModelWorkingDirectory();

    if (!is_file($scriptPath)) {
        throw new RuntimeException(sprintf('Script de prediction de cluster introuvable : %s', $scriptPath));
    }

    $pythonBinary = resolvePythonExecutable();
    $output = runPythonCommand([
        escapeshellarg($pythonBinary),
        escapeshellarg($scriptPath),
        '--haut_tot',
        escapeshellarg((string) $tree['hauteur_total']),
        '--tronc_diam',
        escapeshellarg((string) $tree['diametre_tronc']),
        '--age_estim',
        escapeshellarg((string) $age),
    ], $workingDirectory);

    if (!preg_match('/Cluster ID\s*:\s*(\d+)/i', $output, $clusterMatch)) {
        throw new RuntimeException("Sortie du modele de cluster illisible : " . $output);
    }

    $clusterId = (int) $clusterMatch[1];
    $label = preg_match('/Categorie\s*:\s*(.+)/i', $output, $labelMatch)
        ? trim($labelMatch[1])
        : sprintf('Cluster %d', $clusterId);

    return [
        'cluster' => $clusterId,
        'label' => $label,
    ];
}

try {
    requireMethod('POST');

    $pdo = getDatabaseConnection();
    $trees = fetchAllTrees($pdo);

    foreach ($trees as &$tree) {
        $treeId = (string) $tree['id_arbre'];
        $age = $tree['age'];

        if ($age === null) {
            $age = predictAgeFromTree($tree);
            setAgePrediction($treeId, $age);
            $tree['age'] = $age;
        }

        $clusterPrediction = predictClusterFromTree($tree, (int) $age);
        setClusterPrediction($treeId, $clusterPrediction['cluster']);
        $tree['cluster'] = $clusterPrediction['cluster'];
    }
    unset($tree);

    $clusterLabels = [
        0 => 'Petit',
        1 => 'Moyen',
        2 => 'Grand',
    ];

    $summary = [];
    foreach ($clusterLabels as $clusterId => $label) {
        $summary[] = [
            'cluster' => $clusterId,
            'label' => $label,
            'count' => count(array_filter(
                $trees,
                static function (array $tree) use ($clusterId): bool {
                    return (int) ($tree['cluster'] ?? -1) === $clusterId;
                }
            )),
        ];
    }

    sendSuccess([
        'trees' => $trees,
        'summary' => $summary,
        'source' => 'python_model',
    ], 'Clusters calcules.');
} catch (Throwable $exception) {
    sendError('Impossible de calculer les clusters.', 500, [
        'error' => $exception->getMessage(),
    ]);
}
