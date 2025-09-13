<?php
/**
 * Deployment Configuration Check
 * Run this script to verify your production environment setup
 */

echo "=== DEPLOYMENT CONFIGURATION CHECK ===\n\n";

// Check PHP Version
echo "1. PHP Version Check\n";
echo "   Current: " . phpversion() . "\n";
echo "   Required: >= 8.1\n";
if (version_compare(phpversion(), '8.1.0', '>=')) {
    echo "   ✅ PHP version is compatible\n\n";
} else {
    echo "   ❌ PHP version is too old. Please upgrade to PHP 8.1 or higher.\n\n";
}

// Check Required Extensions
echo "2. Required PHP Extensions\n";
$required_extensions = [
    'pdo',
    'pdo_mysql',
    'mbstring',
    'openssl',
    'tokenizer',
    'json',
    'ctype',
    'fileinfo',
    'gd',
    'curl'
];

foreach ($required_extensions as $ext) {
    if (extension_loaded($ext)) {
        echo "   ✅ $ext\n";
    } else {
        echo "   ❌ $ext (missing)\n";
    }
}

echo "\n3. Directory Permissions Check\n";
$directories = [
    'storage/app',
    'storage/framework/cache',
    'storage/framework/sessions',
    'storage/framework/views',
    'storage/logs',
    'bootstrap/cache'
];

foreach ($directories as $dir) {
    if (is_writable($dir)) {
        echo "   ✅ $dir (writable)\n";
    } else {
        echo "   ❌ $dir (not writable)\n";
    }
}

// Check .env file
echo "\n4. Environment Configuration\n";
if (file_exists('.env')) {
    echo "   ✅ .env file exists\n";
    
    // Check critical environment variables
    $env_vars = [
        'APP_KEY',
        'DB_DATABASE',
        'DB_USERNAME', 
        'DB_PASSWORD',
        'JWT_SECRET'
    ];
    
    foreach ($env_vars as $var) {
        if (getenv($var) !== false && !empty(getenv($var))) {
            echo "   ✅ $var is set\n";
        } else {
            echo "   ❌ $var is missing or empty\n";
        }
    }
} else {
    echo "   ❌ .env file is missing\n";
}

// Test Database Connection
echo "\n5. Database Connection Test\n";
try {
    if (file_exists('.env')) {
        // Load environment variables
        $env_content = file_get_contents('.env');
        preg_match('/DB_HOST=(.*)/', $env_content, $host_match);
        preg_match('/DB_DATABASE=(.*)/', $env_content, $db_match);
        preg_match('/DB_USERNAME=(.*)/', $env_content, $user_match);
        preg_match('/DB_PASSWORD=(.*)/', $env_content, $pass_match);
        
        $host = trim($host_match[1] ?? 'localhost');
        $database = trim($db_match[1] ?? '');
        $username = trim($user_match[1] ?? '');
        $password = trim($pass_match[1] ?? '');
        
        if (!empty($database) && !empty($username)) {
            $dsn = "mysql:host=$host;dbname=$database;charset=utf8mb4";
            $pdo = new PDO($dsn, $username, $password, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
            echo "   ✅ Database connection successful\n";
        } else {
            echo "   ❌ Database credentials not properly configured\n";
        }
    }
} catch (Exception $e) {
    echo "   ❌ Database connection failed: " . $e->getMessage() . "\n";
}

echo "\n6. Security Check\n";
// Check if debug mode is disabled in production
if (file_exists('.env')) {
    $env_content = file_get_contents('.env');
    if (strpos($env_content, 'APP_DEBUG=false') !== false) {
        echo "   ✅ Debug mode is disabled\n";
    } else {
        echo "   ⚠️  Debug mode should be disabled in production\n";
    }
    
    if (strpos($env_content, 'APP_ENV=production') !== false) {
        echo "   ✅ Environment is set to production\n";
    } else {
        echo "   ⚠️  Environment should be set to production\n";
    }
}

echo "\n=== DEPLOYMENT CHECK COMPLETE ===\n";
echo "Please fix any issues marked with ❌ before deploying.\n";
?>