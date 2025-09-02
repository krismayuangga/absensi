import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';

class LeaveProvider with ChangeNotifier {
  final LeaveService _leaveService = LeaveService();

  // State variables
  LeaveBalance? _leaveBalance;
  List<LeaveModel> _leaveHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  LeaveBalance? get leaveBalance => _leaveBalance;
  List<LeaveModel> get leaveHistory => _leaveHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load leave balance
  Future<void> loadLeaveBalance({int? year}) async {
    _setLoading(true);
    try {
      _leaveBalance = await _leaveService.getLeaveBalance(year: year);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      if (kDebugMode) {
        print('Error loading leave balance: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Submit leave request
  Future<bool> submitLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    bool isHalfDay = false,
    String? halfDayPeriod,
    String? emergencyContact,
    File? attachment,
  }) async {
    _setLoading(true);
    try {
      final leave = await _leaveService.submitLeaveRequest(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        isHalfDay: isHalfDay,
        halfDayPeriod: halfDayPeriod,
        emergencyContact: emergencyContact,
        attachment: attachment,
      );

      // Add to history
      _leaveHistory.insert(0, leave);

      // Update balance
      await loadLeaveBalance();

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      if (kDebugMode) {
        print('Error submitting leave request: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load leave history
  Future<void> loadLeaveHistory({int page = 1, int limit = 10}) async {
    if (page == 1) _setLoading(true);

    try {
      final newLeaves = await _leaveService.getLeaveHistory(
        page: page,
        limit: limit,
      );

      if (page == 1) {
        _leaveHistory = newLeaves;
      } else {
        _leaveHistory.addAll(newLeaves);
      }

      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      if (kDebugMode) {
        print('Error loading leave history: $e');
      }
    } finally {
      if (page == 1) _setLoading(false);
    }
  }

  /// Cancel leave request
  Future<bool> cancelLeaveRequest(int leaveId) async {
    try {
      await _leaveService.cancelLeaveRequest(leaveId);

      // Update local data
      final index = _leaveHistory.indexWhere((leave) => leave.id == leaveId);
      if (index != -1) {
        _leaveHistory[index] = LeaveModel(
          id: _leaveHistory[index].id,
          userId: _leaveHistory[index].userId,
          employeeId: _leaveHistory[index].employeeId,
          type: _leaveHistory[index].type,
          startDate: _leaveHistory[index].startDate,
          endDate: _leaveHistory[index].endDate,
          totalDays: _leaveHistory[index].totalDays,
          reason: _leaveHistory[index].reason,
          attachment: _leaveHistory[index].attachment,
          status: 'cancelled',
          managerNotes: _leaveHistory[index].managerNotes,
          approvedBy: _leaveHistory[index].approvedBy,
          approvedAt: _leaveHistory[index].approvedAt,
          emergencyContact: _leaveHistory[index].emergencyContact,
          isHalfDay: _leaveHistory[index].isHalfDay,
          halfDayPeriod: _leaveHistory[index].halfDayPeriod,
          createdAt: _leaveHistory[index].createdAt,
          updatedAt: DateTime.now(),
          statusColor: '#9E9E9E',
          typeLabel: _leaveHistory[index].typeLabel,
          durationText: _leaveHistory[index].durationText,
        );
      }

      // Update balance
      await loadLeaveBalance();

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      if (kDebugMode) {
        print('Error cancelling leave request: $e');
      }
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadLeaveBalance(),
      loadLeaveHistory(),
    ]);
  }

  /// Get leave type options
  static List<Map<String, String>> getLeaveTypeOptions() {
    return [
      {'value': 'annual', 'label': 'Cuti Tahunan'},
      {'value': 'sick', 'label': 'Sakit'},
      {'value': 'personal', 'label': 'Cuti Pribadi'},
      {'value': 'emergency', 'label': 'Cuti Darurat'},
      {'value': 'maternity', 'label': 'Cuti Melahirkan'},
      {'value': 'paternity', 'label': 'Cuti Ayah'},
    ];
  }

  /// Get status color
  static String getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return '#FF9800';
      case 'approved':
        return '#4CAF50';
      case 'rejected':
        return '#F44336';
      case 'cancelled':
        return '#9E9E9E';
      default:
        return '#757575';
    }
  }

  /// Get status text in Indonesian
  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }
}
