<?php

// Test login dengan kredensial yang benar untuk mendapatkan token
echo "Testing login with correct credentials...\n\n";

$loginUrl = 'http://localhost:8000/api/v1/auth/login';
$credentials = [
    'email' => 'admin@test.com',
    'password' => '123456'
];

echo "Login endpoint: $loginUrl\n";
echo "Credentials: " . json_encode($credentials, JSON_PRETTY_PRINT) . "\n\n";

$postData = json_encode($credentials);

$options = [
    'http' => [
        'header' => [
            'Content-Type: application/json',
            'Accept: application/json'
        ],
        'method' => 'POST',
        'content' => $postData,
        'timeout' => 30,
        'ignore_errors' => true
    ]
];

$context = stream_context_create($options);
$response = file_get_contents($loginUrl, false, $context);

echo "Response from login:\n";
if ($response === false) {
    echo "❌ Failed to connect to login endpoint\n";
    print_r(error_get_last());
} else {
    echo $response . "\n\n";
    
    $responseData = json_decode($response, true);
    if (json_last_error() === JSON_ERROR_NONE && isset($responseData['token'])) {
        echo "✅ Login successful!\n";
        $token = $responseData['token'];
        echo "NEW TOKEN:\n";
        echo "================================================\n";
        echo "$token\n";
        echo "================================================\n\n";
        
        // Test admin endpoint with new token
        echo "Testing admin endpoint with new token...\n";
        $adminUrl = 'http://localhost:8000/api/v1/admin/dashboard/stats';
        
        $adminOptions = [
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
        
        $adminContext = stream_context_create($adminOptions);
        $adminResponse = file_get_contents($adminUrl, false, $adminContext);
        
        echo "Admin endpoint response:\n";
        echo $adminResponse . "\n\n";
        
        $adminData = json_decode($adminResponse, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            if (isset($adminData['message']) && $adminData['message'] === 'Unauthenticated.') {
                echo "❌ Still authentication error - middleware issue\n";
            } else {
                echo "✅ Admin endpoint working!\n";
                print_r($adminData);
            }
        } else {
            echo "❌ Non-JSON response from admin endpoint\n";
        }
        
    } else {
        echo "❌ Login failed or invalid response\n";
        if (isset($responseData['error'])) {
            echo "Error: " . $responseData['error'] . "\n";
        }
        if (isset($responseData['message'])) {
            echo "Message: " . $responseData['message'] . "\n";
        }
    }
}

?>
