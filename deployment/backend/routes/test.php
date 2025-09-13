<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Test route for debugging
Route::get('test', function () {
    return response()->json([
        'success' => true,
        'message' => 'API test endpoint works!',
        'timestamp' => now(),
    ]);
});

// Simple test route
Route::post('test-login', function (Request $request) {
    return response()->json([
        'success' => true,
        'message' => 'Test login endpoint reached',
        'received_data' => $request->all(),
        'timestamp' => now(),
    ]);
});
