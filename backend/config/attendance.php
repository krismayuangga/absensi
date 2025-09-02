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
        'latitude' => -6.200000, // Replace with actual office latitude
        'longitude' => 106.816666, // Replace with actual office longitude
        'radius' => 100, // Office radius in meters (100m = safe zone)
        'name' => 'Kantor Pusat',
        'address' => 'Jakarta, Indonesia',
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
        'mandatory_photo' => true,
        'mandatory_description' => true,
        'mandatory_client_name' => true,
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
