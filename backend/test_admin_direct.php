<?php

// Test direct HTTP request to admin endpoint
echo "Testing Admin Endpoint Directly...\n\n";

// Test if server is running
$serverUrl = 'http://localhost:8000';
$adminEndpoint = $serverUrl . '/api/v1/admin/dashboard/stats';

echo "Testing server connection...\n";
$context = stream_context_create([
    'http' => [
        'timeout' => 10,
        'ignore_errors' => true
    ]
]);

$serverTest = @file_get_contents($serverUrl, false, $context);
if ($serverTest === false) {
    echo "❌ Server not responding at $serverUrl\n";
    exit;
}

echo "✅ Server is responding\n\n";

// Test admin endpoint with authentication header
echo "Testing admin endpoint: $adminEndpoint\n";

$token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAvYXBpL3YxL2xvZ2luIiwiaWF0IjoxNzM1OTc5MjgwLCJuYmYiOjE3MzU5NzkyODAsImp0aSI6IkpuaEU3RkFhc2hLOWVmRHAiLCJzdWIiOiIxIiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.F72XCe7GfIFlhGOUdoWZf0AhQQZHxFg3VxlYUEqP-oI";

$options = [
    'http' => [
        'header' => [
            'Authorization: Bearer ' . $token,
            'Accept: application/json',
            'Content-Type: application/json'
        ],
        'method' => 'GET',
        'timeout' => 10,
        'ignore_errors' => true
    ]
];

$context = stream_context_create($options);
$response = file_get_contents($adminEndpoint, false, $context);

echo "Response:\n";
echo $response . "\n\n";

if ($response === false) {
    echo "❌ Failed to get response from admin endpoint\n";
} else {
    $responseData = json_decode($response, true);
    if (json_last_error() === JSON_ERROR_NONE) {
        echo "✅ Valid JSON response received:\n";
        print_r($responseData);
    } else {
        echo "⚠️ Non-JSON response - might be error page\n";
        // Only show first 500 characters to avoid spam
        echo "First 500 chars:\n";
        echo substr($response, 0, 500) . "\n";
    }
}

?>
