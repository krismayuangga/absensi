<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Reset avatar field
DB::table('users')->where('id', 1)->update(['avatar' => null]);

echo "Avatar field reset successfully!\n";