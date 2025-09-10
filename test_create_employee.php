<?php

// Test script untuk create employee

$url = 'http://localhost:8000/api/v1/admin/employees';
$token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvYXBpL3YxL2F1dGgvbG9naW4iLCJpYXQiOjE3MzY0ODEzMzMsImV4cCI6MTczNjQ4NDkzMywibmJmIjoxNzM2NDgxMzMzLCJqdGkiOiJBc0J1TnU2M0xhV2NQOE96Iiwic3ViIjoiMSIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.yVzPSdP8hwBVgHl6P3MX6n_-wMpSsGMCT1qczXtFnSg';

$data = [
    'name' => 'Test Employee Baru',
    'email' => 'testbaru@example.com',
    'phone' => '081234567890',
    'employee_code' => 'EMP999',
    'company_id' => 1,
    'department_id' => 2,
    'position_id' => 4,
    'hire_date' => '2025-01-10',
    'salary' => 5000000,
    'password' => 'password123',
    'gender' => 'male',
    'birth_date' => '1990-01-01',
    'address' => 'Jalan Test No 123',
];

$headers = [
    'Authorization: Bearer ' . $token,
    'Content-Type: application/json',
    'Accept: application/json'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "=== CREATE EMPLOYEE TEST ===\n";
echo "HTTP Code: $httpCode\n";
echo "Response: " . $response . "\n";
if ($error) {
    echo "Curl Error: $error\n";
}

// Parse response
$responseData = json_decode($response, true);
if ($responseData) {
    echo "\n=== PARSED RESPONSE ===\n";
    echo "Success: " . ($responseData['success'] ? 'true' : 'false') . "\n";
    echo "Message: " . ($responseData['message'] ?? 'No message') . "\n";
    
    if (isset($responseData['errors'])) {
        echo "Errors: \n";
        print_r($responseData['errors']);
    }
    
    if (isset($responseData['data'])) {
        echo "Data: \n";
        print_r($responseData['data']);
    }
}

?>
