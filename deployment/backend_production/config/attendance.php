<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Office Location Configuration  
    |--------------------------------------------------------------------------
    |
    | Configure your office coordinates for geo-fence detection
    | and field work validation
    |
    */

    'office' => [
        'latitude' => -6.270075, // Kemang area - matched with mobile app
        'longitude' => 106.819858, // Kemang area - matched with mobile app
        'radius' => 200, // Office radius in meters (200m = larger safe zone)
        'name' => 'Kantor Pusat',
        'address' => 'Jl. Kemang Dalam III, Jakarta, Indonesia',
    ],

    /*
    |--------------------------------------------------------------------------
    | Field Work Settings
    |--------------------------------------------------------------------------
    |
    | Configuration for field work detection and validation
    |
    */

    'field_work' => [
        'enable_geofence' => true,
        'mandatory_photo' => false, // Make photo optional for easier testing
        'mandatory_description' => true,
        'mandatory_client_name' => false, // Make client name optional
        'min_description_length' => 10,
        'max_travel_speed' => 200, // km/h for teleportation detection
        'gps_precision_limit' => 8, // decimal places for fake GPS detection
    ],

    /*
    |--------------------------------------------------------------------------
    | Anti-Fake GPS Settings
    |--------------------------------------------------------------------------
    |
    | Security measures to prevent GPS manipulation
    |
    */

    'anti_fake_gps' => [
        'enable_teleportation_detection' => true,
        'enable_precision_check' => true,
        'enable_accuracy_validation' => true,
        'min_gps_accuracy' => 50, // meters
        'suspicious_precision_decimals' => 8,
    ],
];
