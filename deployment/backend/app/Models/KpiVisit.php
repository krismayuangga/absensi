<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KpiVisit extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'client_name',
        'visit_purpose',
        'latitude',
        'longitude',
        'address',
        'start_time',
        'end_time',
        'notes',
        'photo_path',
        'status',
        'potential_value',
        'next_follow_up',
        'next_action',
        'probability_score',
        'result_updated_at',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'next_follow_up' => 'date',
        'result_updated_at' => 'datetime',
        'potential_value' => 'decimal:2',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'probability_score' => 'integer',
    ];

    /**
     * Get the user that owns the visit.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get visit duration in minutes.
     */
    public function getDurationInMinutes(): ?int
    {
        if (!$this->end_time || !$this->start_time) {
            return null;
        }

        return $this->start_time->diffInMinutes($this->end_time);
    }

    /**
     * Get formatted visit purpose in Indonesian.
     */
    public function getVisitPurposeIndonesian(): string
    {
        return match ($this->visit_purpose) {
            'prospecting' => 'Prospek Baru',
            'follow_up' => 'Tindak Lanjut',
            'closing' => 'Penutupan Deal',
            default => 'Tidak Diketahui',
        };
    }

    /**
     * Get formatted status in Indonesian.
     */
    public function getStatusIndonesian(): string
    {
        return match ($this->status) {
            'pending' => 'Menunggu Hasil',
            'success' => 'Berhasil',
            'failed' => 'Tidak Berhasil',
            default => 'Tidak Diketahui',
        };
    }

    /**
     * Get formatted potential value.
     */
    public function getFormattedPotentialValue(): string
    {
        if (!$this->potential_value) {
            return 'Belum Ditentukan';
        }

        return 'Rp ' . number_format($this->potential_value, 0, ',', '.');
    }

    /**
     * Scope for today's visits.
     */
    public function scopeToday($query)
    {
        return $query->whereDate('start_time', today());
    }

    /**
     * Scope for this week's visits.
     */
    public function scopeThisWeek($query)
    {
        return $query->whereBetween('start_time', [
            now()->startOfWeek(),
            now()->endOfWeek()
        ]);
    }

    /**
     * Scope for this month's visits.
     */
    public function scopeThisMonth($query)
    {
        return $query->whereMonth('start_time', now()->month)
                    ->whereYear('start_time', now()->year);
    }

    /**
     * Scope for successful visits.
     */
    public function scopeSuccessful($query)
    {
        return $query->where('status', 'success');
    }
}
