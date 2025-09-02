<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AnnouncementComment extends Model
{
    use HasFactory;

    protected $fillable = [
        'announcement_id',
        'user_id',
        'comment',
        'parent_id',
        'is_approved',
    ];

    protected $casts = [
        'is_approved' => 'boolean',
    ];

    // Relationships
    public function announcement(): BelongsTo
    {
        return $this->belongsTo(Announcement::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(AnnouncementComment::class, 'parent_id');
    }

    public function replies(): HasMany
    {
        return $this->hasMany(AnnouncementComment::class, 'parent_id');
    }

    public function likes(): HasMany
    {
        return $this->hasMany(CommentLike::class, 'comment_id');
    }

    // Scopes
    public function scopeApproved($query)
    {
        return $query->where('is_approved', true);
    }

    public function scopeTopLevel($query)
    {
        return $query->whereNull('parent_id');
    }

    // Accessors
    public function getIsLikedByAttribute(): ?bool
    {
        if (!auth()->check()) {
            return null;
        }

        return $this->likes()
            ->where('user_id', auth()->id())
            ->exists();
    }

    // Methods
    public function toggleLike($userId = null): bool
    {
        $userId = $userId ?? auth()->id();
        
        $like = CommentLike::where([
            'comment_id' => $this->id,
            'user_id' => $userId,
        ])->first();

        if ($like) {
            $like->delete();
            $this->decrement('like_count');
            return false; // unliked
        } else {
            CommentLike::create([
                'comment_id' => $this->id,
                'user_id' => $userId,
            ]);
            $this->increment('like_count');
            return true; // liked
        }
    }
}
