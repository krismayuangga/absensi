import 'dart:io';
import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _attendanceHistory = [];
  AttendanceStats? _attendanceStats;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AttendanceModel? get todayAttendance => _todayAttendance;
  List<AttendanceModel> get attendanceHistory => _attendanceHistory;
  AttendanceStats? get attendanceStats => _attendanceStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasClockedInToday => _todayAttendance?.hasClockedIn ?? false;
  bool get hasClockedOutToday => _todayAttendance?.hasClockedOut ?? false;

  final AttendanceService _attendanceService = AttendanceService();

  // Load today's attendance
  Future<void> loadTodayAttendance() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _todayAttendance = await _attendanceService.getTodayAttendance();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading today attendance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clock in
  Future<bool> clockIn({
    required double latitude,
    required double longitude,
    String? address,
    File? photo,
    String? workType,
    String? activityDescription,
    String? clientName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final attendance = await _attendanceService.clockIn(
        latitude: latitude,
        longitude: longitude,
        address: address,
        photo: photo,
        workType: workType,
        activityDescription: activityDescription,
        clientName: clientName,
      );

      _todayAttendance = attendance;

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error clocking in: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clock out
  Future<bool> clockOut({
    required double latitude,
    required double longitude,
    String? address,
    File? photo,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final attendance = await _attendanceService.clockOut(
        latitude: latitude,
        longitude: longitude,
        address: address,
        photo: photo,
      );

      _todayAttendance = attendance;

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error clocking out: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load attendance history
  Future<void> loadAttendanceHistory({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        _isLoading = true;
        notifyListeners();
      }

      final history = await _attendanceService.getAttendanceHistory(
        page: page,
        limit: limit,
      );

      if (loadMore) {
        _attendanceHistory.addAll(history);
      } else {
        _attendanceHistory = history;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading attendance history: $e');
    } finally {
      if (!loadMore) {
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  // Load attendance statistics
  Future<void> loadAttendanceStats({
    int? month,
    int? year,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _attendanceStats = await _attendanceService.getAttendanceStats(
        month: month,
        year: year,
      );
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading attendance stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset data
  void reset() {
    _todayAttendance = null;
    _attendanceHistory = [];
    _attendanceStats = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Get formatted clock in time for display
  String getClockInTimeFormatted() {
    if (_todayAttendance?.clockInTimeFormatted != null) {
      return _todayAttendance!.clockInTimeFormatted!;
    }
    return _todayAttendance?.clockInTime?.toString().substring(11, 16) ??
        '--:--';
  }

  // Get formatted clock out time for display
  String getClockOutTimeFormatted() {
    if (_todayAttendance?.clockOutTimeFormatted != null) {
      return _todayAttendance!.clockOutTimeFormatted!;
    }
    return _todayAttendance?.clockOutTime?.toString().substring(11, 16) ??
        '--:--';
  }

  // Get formatted working hours for display
  String getWorkingHoursFormatted() {
    if (_todayAttendance?.workingHoursFormatted != null) {
      return _todayAttendance!.workingHoursFormatted!;
    }
    if (_todayAttendance?.workingHours != null) {
      final hours = _todayAttendance!.workingHours!.floor();
      final minutes = ((_todayAttendance!.workingHours! - hours) * 60).round();
      return '$hours jam $minutes menit';
    }
    return '-- jam';
  }

  // Get attendance status in Indonesian
  String getAttendanceStatusIndonesian() {
    if (_todayAttendance == null) {
      return 'Belum absen masuk';
    }
    if (!_todayAttendance!.hasClockedIn) {
      return 'Belum absen masuk';
    }
    if (!_todayAttendance!.hasClockedOut) {
      return 'Sudah absen masuk';
    }
    return _todayAttendance!.statusIndonesian;
  }
}
