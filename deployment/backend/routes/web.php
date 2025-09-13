<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

Route::get('/', function () {
    return view('welcome');
});

// Temporary API routes via web for testing
Route::prefix('api/v1')->group(function () {
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::get('health', function () {
        return response()->json([
            'success' => true,
            'message' => 'API is working via web routes',
            'timestamp' => now(),
        ]);
    });
});
