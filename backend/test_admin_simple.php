<?php

require 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$kernel = $app->make(\Illuminate\Contracts\Http\Kernel::class);

echo "Testing Admin API Endpoints...\n\n";

// Simulate admin login request
$request = Illuminate\Http\Request::create('/api/v1/admin/dashboard/stats', 'GET');
$request->headers->set('Authorization', 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAvYXBpL3YxL2xvZ2luIiwiaWF0IjoxNzM1OTc5MjgwLCJuYmYiOjE3MzU5NzkyODAsImp0aSI6IkpuaEU3RkFhc2hLOWVmRHAiLCJzdWIiOiIxIiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.F72XCe7GfIFlhGOUdoWZf0AhQQZHxFg3VxlYUEqP-oI');

try {
    $response = $kernel->handle($request);
    
    echo "Response Status: " . $response->getStatusCode() . "\n";
    echo "Response Content: " . $response->getContent() . "\n\n";
    
    if ($response->getStatusCode() === 200) {
        echo "✅ Admin dashboard stats endpoint is working!\n";
    } else {
        echo "❌ Admin dashboard stats endpoint failed!\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error occurred: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
