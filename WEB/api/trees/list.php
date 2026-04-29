<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/bootstrap.php';

try {
    requireMethod('GET');

    $pdo = getDatabaseConnection();
    $trees = fetchAllTrees($pdo);

    sendSuccess([
        'trees' => $trees,
        'count' => count($trees),
    ], 'Arbres récupérés.');
} catch (Throwable $exception) {
    sendError('Impossible de récupérer les arbres.', 500, [
        'error' => $exception->getMessage(),
    ]);
}
