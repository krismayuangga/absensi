<?php

namespace App\Services;

use App\Models\Announcement;
use App\Models\NotificationQueue;
use App\Models\UserDeviceToken;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class PushNotificationService
{
    private $messaging;
    
    public function __construct()
    {
        try {
            $firebase = (new Factory)
                ->withServiceAccount(config('firebase.service_account'))
                ->withDatabaseUri(config('firebase.database_url'));
                
            $this->messaging = $firebase->createMessaging();
        } catch (\Exception $e) {
            Log::error('Firebase initialization failed: ' . $e->getMessage());
        }
    }

    /**
     * Send announcement notification to all target users.
     */
    public function sendAnnouncementNotification(Announcement $announcement): bool
    {
        if (!$announcement->shouldSendNotification()) {
            return false;
        }

        $targetUsers = $announcement->getTargetUsers();
        $successCount = 0;

        foreach ($targetUsers as $user) {
            if ($this->sendToUser($user, $announcement)) {
                $successCount++;
            }
        }

        // Mark notification as sent
        $announcement->update(['notification_sent_at' => now()]);

        Log::info("Announcement notification sent", [
            'announcement_id' => $announcement->id,
            'target_users' => $targetUsers->count(),
            'success_count' => $successCount,
        ]);

        return $successCount > 0;
    }

    /**
     * Send notification to specific user.
     */
    public function sendToUser($user, Announcement $announcement): bool
    {
        $deviceTokens = UserDeviceToken::where('user_id', $user->id)
            ->where('is_active', true)
            ->pluck('device_token')
            ->toArray();

        if (empty($deviceTokens)) {
            return false;
        }

        $title = match ($announcement->priority) {
            'urgent' => '🚨 MENDESAK: ' . $announcement->title,
            'high' => '⚠️ PENTING: ' . $announcement->title,
            default => '📢 ' . $announcement->title,
        };

        $body = $announcement->excerpt ?: 
                \Str::limit(strip_tags($announcement->content), 100);

        // Create notification data
        $notificationData = [
            'type' => 'announcement',
            'announcement_id' => $announcement->id,
            'priority' => $announcement->priority,
            'category' => $announcement->category,
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
        ];

        $success = false;
        
        foreach ($deviceTokens as $token) {
            try {
                $message = CloudMessage::fromArray([
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => $notificationData,
                    'android' => [
                        'priority' => $announcement->priority === 'urgent' ? 'high' : 'normal',
                        'notification' => [
                            'sound' => $announcement->notification_sound ? 'default' : null,
                            'channel_id' => 'announcements',
                            'color' => $this->getPriorityColor($announcement->priority),
                            'icon' => 'ic_notification',
                        ],
                    ],
                    'apns' => [
                        'payload' => [
                            'aps' => [
                                'sound' => $announcement->notification_sound ? 'default' : null,
                                'badge' => 1,
                            ],
                        ],
                    ],
                ]);

                $this->messaging->send($message);
                $success = true;
                
            } catch (\Exception $e) {
                Log::error("Failed to send notification to token: $token", [
                    'error' => $e->getMessage(),
                    'user_id' => $user->id,
                    'announcement_id' => $announcement->id,
                ]);

                // Mark token as inactive if it's invalid
                if (str_contains($e->getMessage(), 'invalid-registration-token')) {
                    UserDeviceToken::where('device_token', $token)
                        ->update(['is_active' => false]);
                }
            }
        }

        // Queue notification record
        NotificationQueue::create([
            'type' => 'announcement',
            'reference_id' => $announcement->id,
            'user_id' => $user->id,
            'title' => $title,
            'body' => $body,
            'data' => json_encode($notificationData),
            'status' => $success ? 'sent' : 'failed',
            'sent_at' => $success ? now() : null,
        ]);

        return $success;
    }

    /**
     * Register user device token.
     */
    public function registerDeviceToken($userId, string $token, string $platform): bool
    {
        try {
            UserDeviceToken::updateOrCreate(
                [
                    'user_id' => $userId,
                    'device_token' => $token,
                ],
                [
                    'platform' => $platform,
                    'is_active' => true,
                    'last_used_at' => now(),
                ]
            );

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to register device token', [
                'user_id' => $userId,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }

    /**
     * Send test notification.
     */
    public function sendTestNotification($userId, string $title, string $body): bool
    {
        $deviceTokens = UserDeviceToken::where('user_id', $userId)
            ->where('is_active', true)
            ->pluck('device_token')
            ->toArray();

        if (empty($deviceTokens)) {
            return false;
        }

        $success = false;

        foreach ($deviceTokens as $token) {
            try {
                $message = CloudMessage::fromArray([
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => [
                        'type' => 'test',
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ],
                ]);

                $this->messaging->send($message);
                $success = true;
                
            } catch (\Exception $e) {
                Log::error("Test notification failed for token: $token", [
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $success;
    }

    /**
     * Get priority color for Android notifications.
     */
    private function getPriorityColor(string $priority): string
    {
        return match ($priority) {
            'urgent' => '#FF5252',    // Red
            'high' => '#FF9800',      // Orange  
            'medium' => '#2196F3',    // Blue
            'low' => '#9E9E9E',       // Gray
            default => '#2196F3',     // Blue
        };
    }

    /**
     * Process queued notifications.
     */
    public function processQueue(): void
    {
        $pendingNotifications = NotificationQueue::where('status', 'pending')
            ->where('send_at', '<=', now())
            ->limit(100)
            ->get();

        foreach ($pendingNotifications as $notification) {
            try {
                // Update status to prevent duplicate processing
                $notification->update(['status' => 'processing']);

                if ($notification->type === 'announcement') {
                    $announcement = Announcement::find($notification->reference_id);
                    if ($announcement) {
                        $user = \App\Models\User::find($notification->user_id);
                        $success = $this->sendToUser($user, $announcement);
                        
                        $notification->update([
                            'status' => $success ? 'sent' : 'failed',
                            'sent_at' => $success ? now() : null,
                            'attempts' => $notification->attempts + 1,
                        ]);
                    }
                }
                
            } catch (\Exception $e) {
                $notification->update([
                    'status' => 'failed',
                    'attempts' => $notification->attempts + 1,
                    'error_message' => $e->getMessage(),
                ]);
                
                Log::error('Failed to process queued notification', [
                    'notification_id' => $notification->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }
    }
}
