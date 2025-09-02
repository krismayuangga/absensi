<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class NotificationQueue extends Model
{
    use HasFactory;

    protected $table = 'notification_queue';

    protected $fillable = [
        'type',
        'reference_id',
        'user_id',
        'title',
        'body',
        'data',
        'send_at',
        'sent_at',
        'status',
        'attempts',
        'error_message',
    ];

    protected $casts = [
        'data' => 'array',
        'send_at' => 'datetime',
        'sent_at' => 'datetime',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeSent($query)
    {
        return $query->where('status', 'sent');
    }

    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }

    public function scopeReadyToSend($query)
    {
        return $query->where('status', 'pending')
                    ->where('send_at', '<=', now());
    }
}
