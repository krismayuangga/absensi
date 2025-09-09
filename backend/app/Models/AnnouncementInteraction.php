<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AnnouncementInteraction extends Model
{
    use HasFactory;

    protected $fillable = [
        'announcement_id',
        'user_id',
        'interaction_type',
    ];

    public $timestamps = true; // Enable timestamps
    
    // Override to only use created_at
    const UPDATED_AT = null;

    // Relationships
    public function announcement(): BelongsTo
    {
        return $this->belongsTo(Announcement::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
