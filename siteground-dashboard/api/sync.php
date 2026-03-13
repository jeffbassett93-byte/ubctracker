<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-cache, no-store, must-revalidate, max-age=0');
header('Pragma: no-cache');
header('Expires: Thu, 01 Jan 1970 00:00:00 GMT');
header('X-Accel-Expires: 0');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$dataFile = __DIR__ . '/projects.dat';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = file_get_contents('php://input');
    
    if (empty($input)) {
        http_response_code(400);
        echo json_encode(['error' => 'No data received']);
        exit;
    }
    
    $decoded = json_decode($input);
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON: ' . json_last_error_msg()]);
        exit;
    }
    
    $json = json_encode($decoded, JSON_UNESCAPED_UNICODE);
    $written = file_put_contents($dataFile, $json, LOCK_EX);
    
    if ($written !== false) {
        clearstatcache(true, $dataFile);
        echo json_encode([
            'success' => true,
            'message' => 'Projects synced successfully',
            'count' => is_array($decoded) ? count($decoded) : 1,
            'timestamp' => date('c')
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to save data']);
    }
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    clearstatcache(true, $dataFile);
    
    if (file_exists($dataFile) && filesize($dataFile) > 2) {
        echo file_get_contents($dataFile);
    } else {
        echo json_encode([]);
    }
    exit;
}

http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
?>
