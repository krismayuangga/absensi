<?php

echo "=== TESTING LEAVE SUBMIT API ===\n\n";

// Test data sama seperti di form
$url = 'http://127.0.0.1:8000/api/v1/leaves/submit';  // Tambahkan v1
$token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvYXBpL2F1dGgvbG9naW4iLCJpYXQiOjE3MjUyODE2MDUsImV4cCI6MTcyNTI4NTIwNSwibmJmIjoxNzI1MjgxNjA1LCJqdGkiOiJyN25xMzhRS0tHdFRrTmlnIiwic3ViIjoiMSIsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.rR6JSlHmGP3YOCKDfAZOXs7PCQGKT5tNwKPfBgBi0bE';

// Data sesuai screenshot
$postData = [
    'type' => 'personal',
    'start_date' => '2025-09-01', // Hari ini (sesuai screenshot)
    'end_date' => '2025-09-02',   // Besok  
    'reason' => 'main ke mall',   // Sesuai screenshot - ini yang kemungkinan error
    'is_half_day' => 'false',
    'half_day_period' => '',
    'emergency_contact' => ''
];

echo "POST Data:\n";
foreach ($postData as $key => $value) {
    echo "  $key: '$value'\n";
}
echo "\n";

// Setup CURL untuk multipart/form-data (seperti FormData di Flutter)
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData); // Sebagai form data, bukan JSON
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Authorization: Bearer ' . $token
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "Response:\n";
echo "HTTP Code: $httpCode\n";
if ($error) {
    echo "CURL Error: $error\n";
} else {
    echo "Response Body:\n";
    $decodedResponse = json_decode($response, true);
    if ($decodedResponse) {
        echo json_encode($decodedResponse, JSON_PRETTY_PRINT) . "\n";
    } else {
        echo $response . "\n";
    }
}
echo "\n";

// Test dengan reason yang lebih panjang
echo "=== TESTING WITH LONGER REASON ===\n";
$postData['reason'] = 'pergi ke mall untuk berbelanja kebutuhan rumah tangga dan bertemu teman';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Authorization: Bearer ' . $token
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response2 = curl_exec($ch);
$httpCode2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Response with longer reason:\n";
echo "HTTP Code: $httpCode2\n";
$decodedResponse2 = json_decode($response2, true);
if ($decodedResponse2) {
    echo json_encode($decodedResponse2, JSON_PRETTY_PRINT) . "\n";
} else {
    echo $response2 . "\n";
}
