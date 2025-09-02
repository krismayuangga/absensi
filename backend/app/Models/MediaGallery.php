<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class MediaGallery extends Model
{
    use HasFactory;

    protected $table = 'media_gallery';

    protected $fillable = [
        'title',
        'description',
        'file_name',
        'file_path',
        'file_size',
        'mime_type',
        'file_type',
        'category',
        'tags',
        'is_featured',
        'is_public',
        'target_type',
        'target_data',
        'uploaded_by',
    ];

    protected $casts = [
        'tags' => 'array',
        'target_data' => 'array',
        'is_featured' => 'boolean',
        'is_public' => 'boolean',
    ];

    // Relationships
    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }

    // Scopes
    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('file_type', $type);
    }

    public function scopeForUser($query, $user)
    {
        return $query->where(function ($q) use ($user) {
            $q->where('is_public', true)
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
    public function getFileUrlAttribute(): string
    {
        return Storage::url($this->file_path);
    }

    public function getFormattedSizeAttribute(): string
    {
        $bytes = $this->file_size ?? 0;
        
        if ($bytes === 0) {
            return '0 B';
        }

        $units = ['B', 'KB', 'MB', 'GB'];
        $unitIndex = 0;

        while ($bytes >= 1024 && $unitIndex < count($units) - 1) {
            $bytes /= 1024;
            $unitIndex++;
        }

        return round($bytes, 2) . ' ' . $units[$unitIndex];
    }

    public function getFileTypeIconAttribute(): string
    {
        return match ($this->file_type) {
            'image' => 'image',
            'document' => 'description',
            'video' => 'videocam',
            default => 'insert_drive_file',
        };
    }

    // Methods
    public function incrementView(): void
    {
        $this->increment('view_count');
    }

    public function incrementDownload(): void
    {
        $this->increment('download_count');
    }

    public function canAccess($user): bool
    {
        if ($this->is_public) {
            return true;
        }

        switch ($this->target_type) {
            case 'department':
                return in_array($user->department_id, $this->target_data ?? []);
            case 'role':
                return in_array($user->role, $this->target_data ?? []);
            case 'specific':
                return in_array($user->id, $this->target_data ?? []);
            default:
                return false;
        }
    }
}
