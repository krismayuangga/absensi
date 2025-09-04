<?php

// Generate new JWT token for admin user
require_once 'bootstrap/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

echo "Generating new JWT token for admin user...\n";

try {
    // Use correct credentials
    $user = User::where('email', 'admin@test.com')->first();
    
    if (!$user) {
        echo "❌ Admin user not found with email: admin@test.com\n";
        echo "Available users:\n";
        $users = User::select('id', 'name', 'email', 'role')->get();
        foreach ($users as $u) {
            echo "  - ID: {$u->id}, Name: {$u->name}, Email: {$u->email}, Role: {$u->role}\n";
        }
        exit;
    }
    
    echo "✅ Admin user found: {$user->name} ({$user->email}) - Role: {$user->role}\n";
    
    // Generate new token
    $token = auth('api')->login($user);
    
    if ($token) {
        echo "\n✅ NEW JWT TOKEN GENERATED:\n";
        echo "================================================\n";
        echo "$token\n";
        echo "================================================\n\n";
        
        // Test the token immediately
        echo "Testing new token...\n";
        try {
            $payload = auth('api')->setToken($token)->payload();
            echo "✅ Token is valid!\n";
            echo "User ID from token: " . $payload->get('sub') . "\n";
            echo "Token expires: " . date('Y-m-d H:i:s', $payload->get('exp')) . "\n";
        } catch (Exception $e) {
            echo "❌ Token validation failed: " . $e->getMessage() . "\n";
        }
        
    } else {
        echo "❌ Failed to generate token\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}

?>
