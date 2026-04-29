<?php

declare(strict_types=1);

require_once __DIR__ . '/config/bootstrap.php';

try {
    $pdo = getDatabaseConnection();
    $statement = $pdo->query('SELECT DATABASE() AS database_name');
    $result = $statement->fetch();

    sendSuccess([
        'database' => $result['database_name'] ?? null,
    ], 'Connexion a la base OK');
} catch (Throwable $exception) {
    sendError('Erreur de connexion a la base', 500, [
        'error' => $exception->getMessage(),
    ]);
}
