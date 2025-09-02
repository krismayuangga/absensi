class AttendanceModel {
  final int id;
  final int userId;
  final DateTime date;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final double? clockInLatitude;
  final double? clockInLongitude;
  final double? clockOutLatitude;
  final double? clockOutLongitude;
  final String? clockInAddress;
  final String? clockOutAddress;
  final String? clockInPhoto;
  final String? clockOutPhoto;
  final double? workingHours;
  final String status;
  final String? notes;
  final String? clockInTimeFormatted;
  final String? clockOutTimeFormatted;
  final String? workingHoursFormatted;
  final String? clockInPhotoUrl;
  final String? clockOutPhotoUrl;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    this.clockInLatitude,
    this.clockInLongitude,
    this.clockOutLatitude,
    this.clockOutLongitude,
    this.clockInAddress,
    this.clockOutAddress,
    this.clockInPhoto,
    this.clockOutPhoto,
    this.workingHours,
    required this.status,
    this.notes,
    this.clockInTimeFormatted,
    this.clockOutTimeFormatted,
    this.workingHoursFormatted,
    this.clockInPhotoUrl,
    this.clockOutPhotoUrl,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      clockInTime: json['clock_in_time'] != null
          ? DateTime.parse(json['clock_in_time'])
          : null,
      clockOutTime: json['clock_out_time'] != null
          ? DateTime.parse(json['clock_out_time'])
          : null,
      clockInLatitude: json['clock_in_latitude'] != null
          ? double.tryParse(json['clock_in_latitude'].toString())
          : null,
      clockInLongitude: json['clock_in_longitude'] != null
          ? double.tryParse(json['clock_in_longitude'].toString())
          : null,
      clockOutLatitude: json['clock_out_latitude'] != null
          ? double.tryParse(json['clock_out_latitude'].toString())
          : null,
      clockOutLongitude: json['clock_out_longitude'] != null
          ? double.tryParse(json['clock_out_longitude'].toString())
          : null,
      clockInAddress: json['clock_in_address'],
      clockOutAddress: json['clock_out_address'],
      clockInPhoto: json['clock_in_photo'],
      clockOutPhoto: json['clock_out_photo'],
      workingHours: json['working_hours'] != null
          ? double.tryParse(json['working_hours'].toString())
          : null,
      status: json['status'] ?? 'present',
      notes: json['notes'],
      clockInTimeFormatted: json['clock_in_time_formatted'],
      clockOutTimeFormatted: json['clock_out_time_formatted'],
      workingHoursFormatted: json['working_hours_formatted'],
      clockInPhotoUrl: json['clock_in_photo_url'],
      clockOutPhotoUrl: json['clock_out_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'clock_in_time': clockInTime?.toIso8601String(),
      'clock_out_time': clockOutTime?.toIso8601String(),
      'clock_in_latitude': clockInLatitude,
      'clock_in_longitude': clockInLongitude,
      'clock_out_latitude': clockOutLatitude,
      'clock_out_longitude': clockOutLongitude,
      'clock_in_address': clockInAddress,
      'clock_out_address': clockOutAddress,
      'clock_in_photo': clockInPhoto,
      'clock_out_photo': clockOutPhoto,
      'working_hours': workingHours,
      'status': status,
      'notes': notes,
    };
  }

  bool get hasClockedIn => clockInTime != null;
  bool get hasClockedOut => clockOutTime != null;
  bool get isComplete => hasClockedIn && hasClockedOut;

  String get statusIndonesian {
    switch (status) {
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

  AttendanceModel copyWith({
    int? id,
    int? userId,
    DateTime? date,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    double? clockInLatitude,
    double? clockInLongitude,
    double? clockOutLatitude,
    double? clockOutLongitude,
    String? clockInAddress,
    String? clockOutAddress,
    String? clockInPhoto,
    String? clockOutPhoto,
    double? workingHours,
    String? status,
    String? notes,
    String? clockInTimeFormatted,
    String? clockOutTimeFormatted,
    String? workingHoursFormatted,
    String? clockInPhotoUrl,
    String? clockOutPhotoUrl,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      clockInLatitude: clockInLatitude ?? this.clockInLatitude,
      clockInLongitude: clockInLongitude ?? this.clockInLongitude,
      clockOutLatitude: clockOutLatitude ?? this.clockOutLatitude,
      clockOutLongitude: clockOutLongitude ?? this.clockOutLongitude,
      clockInAddress: clockInAddress ?? this.clockInAddress,
      clockOutAddress: clockOutAddress ?? this.clockOutAddress,
      clockInPhoto: clockInPhoto ?? this.clockInPhoto,
      clockOutPhoto: clockOutPhoto ?? this.clockOutPhoto,
      workingHours: workingHours ?? this.workingHours,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      clockInTimeFormatted: clockInTimeFormatted ?? this.clockInTimeFormatted,
      clockOutTimeFormatted:
          clockOutTimeFormatted ?? this.clockOutTimeFormatted,
      workingHoursFormatted:
          workingHoursFormatted ?? this.workingHoursFormatted,
      clockInPhotoUrl: clockInPhotoUrl ?? this.clockInPhotoUrl,
      clockOutPhotoUrl: clockOutPhotoUrl ?? this.clockOutPhotoUrl,
    );
  }
}
