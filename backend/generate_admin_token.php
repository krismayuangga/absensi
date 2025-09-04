<?php

// Generate new JWT token for admin user
require_once 'bootstrap/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

echo "Generating new JWT token for admin user...\n";

try {
    $user = User::where('email', 'adminmaster@gmail.com')->first();
    
    if (!$user) {
        echo "❌ Admin user not found\n";
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
        echo "✅ New JWT Token generated:\n";
        echo "$token\n\n";
        
        // Test the token immediately
        echo "Testing new token...\n";
        $payload = auth('api')->setToken($token)->payload();
        echo "Token payload: " . json_encode($payload->toArray(), JSON_PRETTY_PRINT) . "\n";
        
    } else {
        echo "❌ Failed to generate token\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}

?>
