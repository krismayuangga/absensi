<?php
// check_db.php - Quick database check script

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

try {
    echo "=== DATABASE CONNECTION TEST ===\n";
    
    // Test database connection
    $pdo = DB::connection()->getPdo();
    echo "✅ Database connected successfully\n\n";
    
    echo "=== USERS TABLE ===\n";
    $users = DB::table('users')->get();
    echo "Total users: " . $users->count() . "\n";
    foreach ($users as $user) {
        echo "- ID: {$user->id}, Name: {$user->name}, Email: {$user->email}, Role: {$user->role}\n";
    }
    
    echo "\n=== ATTENDANCES TABLE ===\n";
    $attendances = DB::table('attendances')->count();
    echo "Total attendance records: $attendances\n";
    
    if ($attendances > 0) {
        $recentAttendances = DB::table('attendances')
            ->latest('date')
            ->limit(3)
            ->get();
        
        foreach ($recentAttendances as $attendance) {
            echo "- Date: {$attendance->date}, User ID: {$attendance->user_id}, Clock In: {$attendance->clock_in_time}\n";
        }
    }
    
    echo "\n=== TABLE SCHEMA CHECK ===\n";
    $tables = DB::select('SHOW TABLES');
    echo "Available tables:\n";
    foreach ($tables as $table) {
        $tableName = array_values((array)$table)[0];
        echo "- $tableName\n";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
