class LeaveModel {
  final int id;
  final int userId;
  final String employeeId;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final double totalDays;
  final String reason;
  final String? attachment;
  final String status;
  final String? managerNotes;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String? emergencyContact;
  final bool isHalfDay;
  final String? halfDayPeriod;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Formatted fields
  final String? startDateFormatted;
  final String? endDateFormatted;
  final String? statusColor;
  final String? typeLabel;
  final String? durationText;
  final String? attachmentUrl;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.attachment,
    required this.status,
    this.managerNotes,
    this.approvedBy,
    this.approvedAt,
    this.emergencyContact,
    required this.isHalfDay,
    this.halfDayPeriod,
    required this.createdAt,
    required this.updatedAt,
    this.startDateFormatted,
    this.endDateFormatted,
    this.statusColor,
    this.typeLabel,
    this.durationText,
    this.attachmentUrl,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      type: json['type'] ?? '',
      startDate: DateTime.parse(
          json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      totalDays: json['total_days'] != null
          ? double.tryParse(json['total_days'].toString()) ?? 0.0
          : 0.0,
      reason: json['reason'] ?? '',
      attachment: json['attachment'],
      status: json['status'] ?? 'pending',
      managerNotes: json['manager_notes'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      emergencyContact: json['emergency_contact'],
      isHalfDay: json['is_half_day'] ?? false,
      halfDayPeriod: json['half_day_period'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      startDateFormatted: json['start_date_formatted'],
      endDateFormatted: json['end_date_formatted'],
      statusColor: json['status_color'],
      typeLabel: json['type_label'],
      durationText: json['duration_text'],
      attachmentUrl: json['attachment_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_id': employeeId,
      'type': type,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'total_days': totalDays,
      'reason': reason,
      'attachment': attachment,
      'status': status,
      'manager_notes': managerNotes,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'emergency_contact': emergencyContact,
      'is_half_day': isHalfDay,
      'half_day_period': halfDayPeriod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  bool get canBeCancelled {
    return (isPending || isApproved) && startDate.isAfter(DateTime.now());
  }
}

class LeaveBalance {
  final int year;
  final int totalAnnualLeave;
  final double usedLeave;
  final double remainingLeave;
  final int pendingRequests;

  LeaveBalance({
    required this.year,
    required this.totalAnnualLeave,
    required this.usedLeave,
    required this.remainingLeave,
    required this.pendingRequests,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      year: json['year'] ?? DateTime.now().year,
      totalAnnualLeave: json['total_annual_leave'] ?? 12,
      usedLeave: json['used_leave'] != null
          ? double.tryParse(json['used_leave'].toString()) ?? 0.0
          : 0.0,
      remainingLeave: json['remaining_leave'] != null
          ? double.tryParse(json['remaining_leave'].toString()) ?? 0.0
          : 0.0,
      pendingRequests: json['pending_requests'] ?? 0,
    );
  }
}
