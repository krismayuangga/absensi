<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Announcement extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'content',
        'excerpt',
        'priority',
        'category',
        'start_date',
        'end_date',
        'is_scheduled',
        'is_active',
        'target_type',
        'target_data',
        'send_notification',
        'notification_sound',
        'notification_sent_at',
        'created_by',
    ];

    protected $casts = [
        'target_data' => 'array',
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'notification_sent_at' => 'datetime',
        'is_scheduled' => 'boolean',
        'is_active' => 'boolean',
        'send_notification' => 'boolean',
        'notification_sound' => 'boolean',
    ];

    // Relationships
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function interactions(): HasMany
    {
        return $this->hasMany(AnnouncementInteraction::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(AnnouncementComment::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopePublished($query)
    {
        return $query->where(function ($q) {
            $q->where('is_scheduled', false)
              ->orWhere(function ($sq) {
                  $sq->where('is_scheduled', true)
                     ->where('start_date', '<=', now())
                     ->where(function ($esq) {
                         $esq->whereNull('end_date')
                            ->orWhere('end_date', '>=', now());
                     });
              });
        });
    }

    public function scopeByPriority($query, $priority)
    {
        return $query->where('priority', $priority);
    }

    public function scopeForUser($query, $user)
    {
        return $query->where(function ($q) use ($user) {
            $q->where('target_type', 'all')
              ->orWhere(function ($sq) use ($user) {
                  $sq->where('target_type', 'department')
                     ->whereJsonContains('target_data', $user->department_id);
              })
              ->orWhere(function ($sq) use ($user) {
                  $sq->where('target_type', 'role')
                     ->whereJsonContains('target_data', $user->role);
              })
              ->orWhere(function ($sq) use ($user) {
                  $sq->where('target_type', 'specific')
                     ->whereJsonContains('target_data', $user->id);
              });
        });
    }

    // Accessors
    public function getPriorityLabelAttribute(): string
    {
        return match ($this->priority) {
            'urgent' => 'Mendesak',
            'high' => 'Tinggi',
            'medium' => 'Sedang',
            'low' => 'Rendah',
            default => 'Sedang',
        };
    }

    public function getPriorityColorAttribute(): string
    {
        return match ($this->priority) {
            'urgent' => 'red',
            'high' => 'orange',
            'medium' => 'blue',
            'low' => 'gray',
            default => 'blue',
        };
    }

    public function getIsLikedByAttribute(): ?bool
    {
        if (!auth()->check()) {
            return null;
        }

        return $this->interactions()
            ->where('user_id', auth()->id())
            ->where('interaction_type', 'like')
            ->exists();
    }

    public function getIsReadByAttribute(): bool
    {
        if (!auth()->check()) {
            return false;
        }

        return $this->interactions()
            ->where('user_id', auth()->id())
            ->where('interaction_type', 'read')
            ->exists();
    }

    // Methods
    public function markAsRead($userId = null): void
    {
        $userId = $userId ?? auth()->id();
        
        AnnouncementInteraction::updateOrCreate([
            'announcement_id' => $this->id,
            'user_id' => $userId,
            'interaction_type' => 'read',
        ]);

        $this->increment('read_count');
    }

    public function toggleLike($userId = null): bool
    {
        $userId = $userId ?? auth()->id();
        
        $interaction = AnnouncementInteraction::where([
            'announcement_id' => $this->id,
            'user_id' => $userId,
            'interaction_type' => 'like',
        ])->first();

        if ($interaction) {
            $interaction->delete();
            $this->decrement('like_count');
            return false; // unliked
        } else {
            AnnouncementInteraction::create([
                'announcement_id' => $this->id,
                'user_id' => $userId,
                'interaction_type' => 'like',
            ]);
            $this->increment('like_count');
            return true; // liked
        }
    }

    public function shouldSendNotification(): bool
    {
        return $this->send_notification && 
               $this->is_active && 
               $this->notification_sent_at === null &&
               ($this->is_scheduled === false || $this->start_date <= now());
    }

    public function getTargetUsers()
    {
        $query = User::query();

        switch ($this->target_type) {
            case 'department':
                $query->whereIn('department_id', $this->target_data ?? []);
                break;
            case 'role':
                $query->whereIn('role', $this->target_data ?? []);
                break;
            case 'specific':
                $query->whereIn('id', $this->target_data ?? []);
                break;
            case 'all':
            default:
                // No additional filtering needed
                break;
        }

        return $query->get();
    }
}
