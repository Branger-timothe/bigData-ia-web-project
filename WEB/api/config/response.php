<?php

declare(strict_types=1);

function sendJson(int $statusCode, array $payload): void
{
    http_response_code($statusCode);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

function sendSuccess(array $data = [], string $message = 'OK', int $statusCode = 200): void
{
    sendJson($statusCode, [
        'success' => true,
        'message' => $message,
        'data' => $data,
    ]);
}

function sendError(string $message, int $statusCode = 400, array $details = []): void
{
    $payload = [
        'success' => false,
        'message' => $message,
    ];

    if ($details !== []) {
        $payload['details'] = $details;
    }

    sendJson($statusCode, $payload);
}

function requireMethod(string $expectedMethod): void
{
    $actualMethod = $_SERVER['REQUEST_METHOD'] ?? 'GET';

    if (strtoupper($actualMethod) !== strtoupper($expectedMethod)) {
        sendError(
            sprintf('Méthode HTTP invalide. Attendu: %s', strtoupper($expectedMethod)),
            405
        );
    }
}

function getJsonInput(): array
{
    $rawBody = file_get_contents('php://input');

    if ($rawBody === false || trim($rawBody) === '') {
        return [];
    }

    $decoded = json_decode($rawBody, true);

    if (!is_array($decoded)) {
        sendError('Le corps de la requête doit être un JSON valide.', 400);
    }

    return $decoded;
}
