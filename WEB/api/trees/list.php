<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/config/bootstrap.php';

try {
    requireMethod('GET');

    $pdo = getDatabaseConnection();
    $page = isset($_GET['page']) ? max(1, (int) $_GET['page']) : null;
    $limit = isset($_GET['limit']) ? max(1, min(100, (int) $_GET['limit'])) : null;

    if ($page !== null || $limit !== null) {
        $page = $page ?? 1;
        $limit = $limit ?? 10;
        $totalCount = countTrees($pdo);
        $totalPages = max(1, (int) ceil($totalCount / $limit));
        $page = min($page, $totalPages);
        $trees = fetchTreesPage($pdo, $page, $limit);

        sendSuccess([
            'trees' => $trees,
            'count' => count($trees),
            'total_count' => $totalCount,
            'page' => $page,
            'limit' => $limit,
            'total_pages' => $totalPages,
        ], 'Arbres rÃ©cupÃ©rÃ©s.');
    }

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
