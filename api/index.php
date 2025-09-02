<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Parse the request
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/api', '', $path); // Remove /api prefix

// Router
switch ($method . ' ' . $path) {
    case 'GET /kpi/stats':
        echo json_encode([
            'success' => true,
            'data' => [
                'today_visits' => 3,
                'week_visits' => 15,
                'month_visits' => 47,
                'success_rate' => 72.5,
                'potential_value' => 2500000,
                'formatted_potential_value' => 'Rp 2.500.000'
            ]
        ]);
        break;
        
    case 'POST /kpi/visits':
        // Simulate visit logging
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (empty($input['client_name'])) {
            http_response_code(422);
            echo json_encode([
                'success' => false,
                'message' => 'Client name is required',
                'errors' => ['client_name' => ['The client name field is required.']]
            ]);
        } else {
            echo json_encode([
                'success' => true,
                'message' => 'Kunjungan berhasil dicatat',
                'data' => [
                    'id' => rand(1000, 9999),
                    'client_name' => $input['client_name'],
                    'visit_purpose' => $input['visit_purpose'],
                    'latitude' => $input['latitude'],
                    'longitude' => $input['longitude'],
                    'address' => $input['address'] ?? null,
                    'notes' => $input['notes'] ?? null,
                    'start_time' => $input['start_time'],
                    'created_at' => date('Y-m-d H:i:s')
                ]
            ]);
        }
        break;
        
    case 'GET /kpi/visits':
        // Get visit history
        echo json_encode([
            'success' => true,
            'data' => [
                [
                    'id' => 1,
                    'client_name' => 'PT Maju Jaya',
                    'visit_purpose' => 'prospecting',
                    'status' => 'pending',
                    'created_at' => date('Y-m-d H:i:s', strtotime('-1 day'))
                ],
                [
                    'id' => 2,
                    'client_name' => 'CV Sukses Mandiri',
                    'visit_purpose' => 'closing',
                    'status' => 'success',
                    'created_at' => date('Y-m-d H:i:s', strtotime('-3 days'))
                ]
            ]
        ]);
        break;
        
    case 'GET /kpi/visits/pending':
        // Get pending visits
        echo json_encode([
            'success' => true,
            'data' => [
                [
                    'id' => 1,
                    'client_name' => 'PT Maju Jaya',
                    'visit_purpose' => 'prospecting',
                    'created_at' => date('Y-m-d H:i:s', strtotime('-1 day'))
                ]
            ]
        ]);
        break;
        
    case 'GET /notifications':
        // Get notifications
        echo json_encode([
            'success' => true,
            'data' => [
                [
                    'id' => 1,
                    'type' => 'reminder',
                    'title' => 'Follow-up Reminder',
                    'message' => 'Jangan lupa follow-up klien PT Maju Bersama hari ini',
                    'timestamp' => date('c', strtotime('-2 hours')),
                    'is_read' => false,
                    'priority' => 'high',
                    'action_data' => [
                        'client_name' => 'PT Maju Bersama',
                        'visit_id' => '123'
                    ]
                ],
                [
                    'id' => 2,
                    'type' => 'target',
                    'title' => 'Target Achievement',
                    'message' => 'Selamat! Anda telah mencapai 85% target bulanan',
                    'timestamp' => date('c', strtotime('-5 hours')),
                    'is_read' => false,
                    'priority' => 'medium'
                ]
            ]
        ]);
        break;
        
    case 'POST /notifications':
        // Create notification
        $input = json_decode(file_get_contents('php://input'), true);
        echo json_encode([
            'success' => true,
            'message' => 'Notification created successfully',
            'data' => [
                'id' => rand(1000, 9999),
                'type' => $input['type'],
                'title' => $input['title'],
                'message' => $input['message'],
                'priority' => $input['priority'] ?? 'medium',
                'is_read' => false,
                'timestamp' => date('c'),
                'action_data' => $input['action_data'] ?? null
            ]
        ]);
        break;
        
    case 'POST /notifications/mark-all-read':
        echo json_encode([
            'success' => true,
            'message' => 'All notifications marked as read'
        ]);
        break;
        
    default:
        if (strpos($path, '/notifications/') !== false && $method === 'PATCH') {
            // Update specific notification
            echo json_encode([
                'success' => true,
                'message' => 'Notification updated successfully'
            ]);
        } elseif (strpos($path, '/notifications/') !== false && $method === 'DELETE') {
            // Delete specific notification
            echo json_encode([
                'success' => true,
                'message' => 'Notification deleted successfully'
            ]);
        } else {
            http_response_code(404);
            echo json_encode([
                'success' => false,
                'message' => 'Endpoint not found: ' . $method . ' ' . $path
            ]);
        }
        break;
}
?>
