<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Leave extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'employee_id',
        'type',
        'start_date',
        'end_date',
        'total_days',
        'reason',
        'attachment',
        'status',
        'manager_notes',
        'approved_by',
        'approved_at',
        'emergency_contact',
        'is_half_day',
        'half_day_period'
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'approved_at' => 'datetime',
        'is_half_day' => 'boolean'
    ];

    protected $appends = [
        'start_date_formatted',
        'end_date_formatted',
        'status_color',
        'type_label',
        'duration_text',
        'attachment_url'
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    // Accessors
    public function getStartDateFormattedAttribute()
    {
        return $this->start_date ? $this->start_date->format('d M Y') : null;
    }

    public function getEndDateFormattedAttribute()
    {
        return $this->end_date ? $this->end_date->format('d M Y') : null;
    }

    public function getStatusColorAttribute()
    {
        return match($this->status) {
            'pending' => '#FF9800',
            'approved' => '#4CAF50',
            'rejected' => '#F44336',
            'cancelled' => '#9E9E9E',
            default => '#757575'
        };
    }

    public function getTypeLabelAttribute()
    {
        return match($this->type) {
            'sick' => 'Sakit',
            'annual' => 'Cuti Tahunan',
            'personal' => 'Cuti Pribadi',
            'emergency' => 'Cuti Darurat',
            'maternity' => 'Cuti Melahirkan',
            'paternity' => 'Cuti Ayah',
            default => ucfirst($this->type)
        };
    }

    public function getDurationTextAttribute()
    {
        if ($this->is_half_day) {
            $period = $this->half_day_period === 'morning' ? 'Pagi' : 'Sore';
            return "Setengah Hari ({$period})";
        }
        
        return $this->total_days . ' Hari';
    }

    public function getAttachmentUrlAttribute()
    {
        return $this->attachment ? asset('storage/' . $this->attachment) : null;
    }

    // Helper methods
    public function canBeApproved()
    {
        return $this->status === 'pending';
    }

    public function canBeCancelled()
    {
        return in_array($this->status, ['pending', 'approved']) && $this->start_date->isFuture();
    }

    public function isOverlapping($startDate, $endDate, $excludeId = null)
    {
        $query = static::where('user_id', $this->user_id)
            ->where('status', '!=', 'rejected')
            ->where(function($q) use ($startDate, $endDate) {
                $q->whereBetween('start_date', [$startDate, $endDate])
                  ->orWhereBetween('end_date', [$startDate, $endDate])
                  ->orWhere(function($q2) use ($startDate, $endDate) {
                      $q2->where('start_date', '<=', $startDate)
                         ->where('end_date', '>=', $endDate);
                  });
            });
            
        if ($excludeId) {
            $query->where('id', '!=', $excludeId);
        }
        
        return $query->exists();
    }

    public function calculateTotalDays()
    {
        if ($this->is_half_day) {
            return 0.5;
        }
        
        return $this->start_date->diffInDays($this->end_date) + 1;
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeThisMonth($query)
    {
        return $query->whereYear('start_date', Carbon::now()->year)
                    ->whereMonth('start_date', Carbon::now()->month);
    }

    public function scopeThisYear($query)
    {
        return $query->whereYear('start_date', Carbon::now()->year);
    }

    // Static methods
    public static function getLeaveBalance($userId, $year = null)
    {
        $year = $year ?? Carbon::now()->year;
        
        $totalAnnualLeave = 12; // Default 12 days per year
        $usedLeave = static::where('user_id', $userId)
            ->where('type', 'annual')
            ->where('status', 'approved')
            ->whereYear('start_date', $year)
            ->sum('total_days');
            
        return $totalAnnualLeave - $usedLeave;
    }
}
