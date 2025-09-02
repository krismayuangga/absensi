<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'date',
        'clock_in_time',
        'clock_out_time',
        'clock_in_latitude',
        'clock_in_longitude',
        'clock_out_latitude',
        'clock_out_longitude',
        'clock_in_address',
        'clock_out_address',
        'clock_in_photo',
        'clock_out_photo',
        'working_hours',
        'status',
        'notes',
        // Field work fields
        'work_type',
        'activity_description',
        'client_name'
    ];

    protected $casts = [
        'date' => 'date',
        'clock_in_time' => 'datetime',
        'clock_out_time' => 'datetime',
        'clock_in_latitude' => 'float',
        'clock_in_longitude' => 'float',
        'clock_out_latitude' => 'float',
        'clock_out_longitude' => 'float',
        'working_hours' => 'decimal:2'
    ];

    protected $appends = [
        'clock_in_time_formatted',
        'clock_out_time_formatted',
        'working_hours_formatted',
        'clock_in_photo_url',
        'clock_out_photo_url'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Accessor for formatted clock in time
    public function getClockInTimeFormattedAttribute()
    {
        return $this->clock_in_time ? $this->clock_in_time->format('H:i') : null;
    }

    // Accessor for formatted clock out time
    public function getClockOutTimeFormattedAttribute()
    {
        return $this->clock_out_time ? $this->clock_out_time->format('H:i') : null;
    }

    // Accessor for formatted working hours
    public function getWorkingHoursFormattedAttribute()
    {
        if (!$this->working_hours) {
            return null;
        }

        $hours = floor($this->working_hours);
        $minutes = round(($this->working_hours - $hours) * 60);
        
        return sprintf('%d jam %d menit', $hours, $minutes);
    }

    // Accessor for clock in photo URL
    public function getClockInPhotoUrlAttribute()
    {
        return $this->clock_in_photo ? asset('storage/' . $this->clock_in_photo) : null;
    }

    // Accessor for clock out photo URL
    public function getClockOutPhotoUrlAttribute()
    {
        return $this->clock_out_photo ? asset('storage/' . $this->clock_out_photo) : null;
    }

    // Check if user is late
    public function isLate($workStartTime = '09:00')
    {
        if (!$this->clock_in_time) {
            return false;
        }

        $workStart = Carbon::createFromFormat('H:i', $workStartTime);
        $clockIn = Carbon::parse($this->clock_in_time);

        return $clockIn->gt($workStart);
    }

    // Calculate total break time (if needed)
    public function calculateBreakTime()
    {
        // This can be extended later to handle break times
        return 0;
    }

    // Get status in Indonesian
    public function getStatusIndonesian()
    {
        switch ($this->status) {
            case 'present':
                return 'Hadir';
            case 'late':
                return 'Terlambat';
            case 'absent':
                return 'Tidak Hadir';
            case 'sick':
                return 'Sakit';
            case 'leave':
                return 'Cuti';
            default:
                return 'Unknown';
        }
    }

    // Scope for today's attendance
    public function scopeToday($query)
    {
        return $query->whereDate('date', Carbon::today());
    }

    // Scope for this month's attendance
    public function scopeThisMonth($query)
    {
        return $query->whereYear('date', Carbon::now()->year)
                    ->whereMonth('date', Carbon::now()->month);
    }

    // Scope for specific user
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }
}