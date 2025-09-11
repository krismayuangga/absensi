import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingEmployees = false;
  bool _isLoadingAttendance = false;
  bool _isLoadingLeaves = false;
  String? _errorMessage;

  // Dashboard data
  Map<String, dynamic>? _dashboardStats;
  List<Map<String, dynamic>> _recentActivities = [];

  // Employee data
  List<Map<String, dynamic>> _employees = [];
  int _currentEmployeePage = 1;
  int _totalEmployeePages = 1;
  bool _hasMoreEmployees = true;

  // Attendance data
  List<Map<String, dynamic>> _attendanceRecords = [];
  int _currentAttendancePage = 1;
  int _totalAttendancePages = 1;
  bool _hasMoreAttendance = true;

  // Leave data
  List<Map<String, dynamic>> _leaveRequests = [];
  int _currentLeavePage = 1;
  int _totalLeavePages = 1;
  bool _hasMoreLeaves = true;

  // Master data
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _positions = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingEmployees => _isLoadingEmployees;
  bool get isLoadingAttendance => _isLoadingAttendance;
  bool get isLoadingLeaves => _isLoadingLeaves;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  List<Map<String, dynamic>> get employees => _employees;
  bool get hasMoreEmployees => _hasMoreEmployees;

  List<Map<String, dynamic>> get attendanceRecords => _attendanceRecords;
  bool get hasMoreAttendance => _hasMoreAttendance;

  List<Map<String, dynamic>> get leaveRequests => _leaveRequests;
  bool get hasMoreLeaves => _hasMoreLeaves;

  List<Map<String, dynamic>> get companies => _companies;
  List<Map<String, dynamic>> get departments => _departments;
  List<Map<String, dynamic>> get positions => _positions;

  // KPI Analytics
  Map<String, dynamic>? _kpiAnalytics;
  Map<String, dynamic>? get kpiAnalytics => _kpiAnalytics;

  // Dashboard methods
  Future<void> loadDashboardStats() async {
    print('🔄 ADMIN: Starting loadDashboardStats...');
    _setLoading(true);
    try {
      final result = await _adminService.getDashboardStats();
      print('📊 ADMIN: Dashboard API result: $result');

      if (result['success'] == true) {
        // Update untuk field bahasa Indonesia yang benar
        _dashboardStats = result['data']?['statistik'];

        // Safe parsing for recent activities - bahasa Indonesia
        final activitiesData = result['data']?['aktivitas_terkini'];
        _recentActivities = [];
        if (activitiesData is List) {
          for (var item in activitiesData) {
            if (item is Map<String, dynamic>) {
              _recentActivities.add(item);
            }
          }
        }

        print('✅ ADMIN: Dashboard stats loaded: $_dashboardStats');
        print('✅ ADMIN: Recent activities count: ${_recentActivities.length}');
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Failed to load dashboard stats';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error loading dashboard stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Employee methods
  Future<void> loadEmployees({bool refresh = false, String? search}) async {
    if (refresh) {
      _currentEmployeePage = 1;
      _employees.clear();
      _hasMoreEmployees = true;
    }

    if (!_hasMoreEmployees) return;

    _setLoadingEmployees(true);
    try {
      final result = await _adminService.getEmployees(
        page: _currentEmployeePage,
        search: search,
      );

      if (result['success'] == true) {
        final data = result['data'];

        // Safe parsing for employees data
        final employeesData = data?['data'];
        List<Map<String, dynamic>> newEmployees = [];
        if (employeesData is List) {
          for (var item in employeesData) {
            if (item is Map<String, dynamic>) {
              newEmployees.add(item);
            }
          }
        }

        if (refresh) {
          _employees = newEmployees;
        } else {
          _employees.addAll(newEmployees);
        }

        _currentEmployeePage = data?['halaman_saat_ini'] ?? 1;
        _totalEmployeePages = data?['halaman_terakhir'] ?? 1;
        _hasMoreEmployees = _currentEmployeePage < _totalEmployeePages;

        if (_hasMoreEmployees) {
          _currentEmployeePage++;
        }

        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Failed to load employees';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error loading employees: $e');
    } finally {
      _setLoadingEmployees(false);
    }
  }

  Future<bool> createEmployee(Map<String, dynamic> employeeData) async {
    print('🔄 ADMIN PROVIDER: Starting createEmployee...');
    print('📊 Data received: $employeeData');

    _setLoading(true);
    try {
      final result = await _adminService.createEmployee(employeeData);
      print('📡 Service result: $result');

      if (result['success'] == true) {
        print('✅ Employee created successfully, reloading list...');
        await loadEmployees(refresh: true);
        _errorMessage = null;
        return true;
      } else {
        print('❌ Failed to create employee: ${result['message']}');
        _errorMessage = result['message'] ?? 'Failed to create employee';
        return false;
      }
    } catch (e) {
      print('❌ Exception in createEmployee: $e');
      _errorMessage = 'Error: $e';
      debugPrint('Error creating employee: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmployee(int id, Map<String, dynamic> employeeData) async {
    _setLoading(true);
    try {
      final result = await _adminService.updateEmployee(id, employeeData);

      if (result['success'] == true) {
        await loadEmployees(refresh: true);
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update employee';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error updating employee: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEmployee(int id) async {
    _setLoading(true);
    try {
      final result = await _adminService.deleteEmployee(id);

      if (result['success'] == true) {
        _employees.removeWhere((emp) => emp['id'] == id);
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to delete employee';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error deleting employee: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Attendance methods
  Future<void> loadAttendanceRecords({
    bool refresh = false,
    String? date,
    int? employeeId,
    String? status,
  }) async {
    if (refresh) {
      _currentAttendancePage = 1;
      _attendanceRecords.clear();
      _hasMoreAttendance = true;
    }

    if (!_hasMoreAttendance) return;

    _setLoadingAttendance(true);
    try {
      final result = await _adminService.getAttendanceRecords(
        page: _currentAttendancePage,
        date: date,
        employeeId: employeeId,
        status: status,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final newRecords = List<Map<String, dynamic>>.from(data['data'] ?? []);

        if (refresh) {
          _attendanceRecords = newRecords;
        } else {
          _attendanceRecords.addAll(newRecords);
        }

        _currentAttendancePage = data['current_page'] ?? 1;
        _totalAttendancePages = data['last_page'] ?? 1;
        _hasMoreAttendance = _currentAttendancePage < _totalAttendancePages;

        if (_hasMoreAttendance) {
          _currentAttendancePage++;
        }

        _errorMessage = null;
      } else {
        _errorMessage =
            result['message'] ?? 'Failed to load attendance records';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error loading attendance records: $e');
    } finally {
      _setLoadingAttendance(false);
    }
  }

  // Leave methods
  Future<void> loadLeaveRequests({
    bool refresh = false,
    String? status,
    int? employeeId,
  }) async {
    if (refresh) {
      _currentLeavePage = 1;
      _leaveRequests.clear();
      _hasMoreLeaves = true;
    }

    if (!_hasMoreLeaves) return;

    _setLoadingLeaves(true);
    try {
      final result = await _adminService.getLeaveRequests(
        page: _currentLeavePage,
        status: status,
        employeeId: employeeId,
      );

      if (result['success'] == true) {
        final data = result['data'];
        final newRequests = List<Map<String, dynamic>>.from(data['data'] ?? []);

        if (refresh) {
          _leaveRequests = newRequests;
        } else {
          _leaveRequests.addAll(newRequests);
        }

        _currentLeavePage = data['current_page'] ?? 1;
        _totalLeavePages = data['last_page'] ?? 1;
        _hasMoreLeaves = _currentLeavePage < _totalLeavePages;

        if (_hasMoreLeaves) {
          _currentLeavePage++;
        }

        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Failed to load leave requests';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error loading leave requests: $e');
    } finally {
      _setLoadingLeaves(false);
    }
  }

  Future<bool> updateLeaveStatus(int id, String status,
      {String? adminNotes}) async {
    _setLoading(true);
    try {
      final result =
          await _adminService.updateLeaveStatus(id, status, adminNotes);

      if (result['success'] == true) {
        // Update the leave request in the list
        final index = _leaveRequests.indexWhere((leave) => leave['id'] == id);
        if (index != -1) {
          _leaveRequests[index] = result['data'];
          notifyListeners();
        }
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update leave status';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error updating leave status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Master data methods
  Future<void> loadMasterData() async {
    try {
      print('🔍 Loading master data...');
      final result = await _adminService.getMasterData();
      print('📊 Master data result: $result');

      if (result['success'] == true) {
        final data = result['data'];
        print('📊 Master data content: $data');

        // Safe parsing for companies
        _companies = [];
        final companiesData = data?['companies'];
        print('🏢 Companies data: $companiesData');
        if (companiesData is List) {
          for (var item in companiesData) {
            if (item is Map<String, dynamic>) {
              _companies.add(item);
            }
          }
        }
        print('🏢 Parsed companies: $_companies');

        // Safe parsing for departments
        _departments = [];
        final departmentsData = data?['departments'];
        print('🏬 Departments data: $departmentsData');
        if (departmentsData is List) {
          for (var item in departmentsData) {
            if (item is Map<String, dynamic>) {
              _departments.add(item);
            }
          }
        }
        print('🏬 Parsed departments: $_departments');

        // Safe parsing for positions
        _positions = [];
        final positionsData = data?['positions'];
        print('👥 Positions data: $positionsData');
        if (positionsData is List) {
          for (var item in positionsData) {
            if (item is Map<String, dynamic>) {
              _positions.add(item);
            }
          }
        }
        print('👥 Parsed positions: $_positions');

        _errorMessage = null;
        notifyListeners();
        print(
            '✅ Master data loaded successfully! Companies: ${_companies.length}, Departments: ${_departments.length}, Positions: ${_positions.length}');
      } else {
        print('❌ Failed to load master data: ${result['message']}');
        _errorMessage = result['message'] ?? 'Failed to load master data';
      }
    } catch (e) {
      print('❌ Exception loading master data: $e');
      _errorMessage = 'Error: $e';
      debugPrint('Error loading master data: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingEmployees(bool loading) {
    _isLoadingEmployees = loading;
    notifyListeners();
  }

  void _setLoadingAttendance(bool loading) {
    _isLoadingAttendance = loading;
    notifyListeners();
  }

  void _setLoadingLeaves(bool loading) {
    _isLoadingLeaves = loading;
    notifyListeners();
  }

  /// Get employee by ID with complete data for editing
  Future<Map<String, dynamic>?> getEmployee(int employeeId) async {
    try {
      print('🔍 AdminProvider: Getting employee data for ID: $employeeId');
      final result = await _adminService.getEmployee(employeeId);
      print('📊 AdminProvider: Employee result: $result');

      if (result['success'] == true) {
        final employeeData = result['data'];
        print('📊 AdminProvider: Employee data: $employeeData');
        return employeeData;
      } else {
        _errorMessage = result['message'] ?? 'Failed to get employee data';
        notifyListeners();
        return null;
      }
    } catch (e) {
      print('❌ AdminProvider: Error getting employee: $e');
      _errorMessage = 'Error getting employee: $e';
      notifyListeners();
      return null;
    }
  }

  // Leave approval methods
  Future<bool> approveLeave(int leaveId, String notes) async {
    _setLoading(true);
    try {
      final result = await _adminService.approveLeave(leaveId, notes);

      if (result['success'] == true) {
        await loadLeaveRequests(refresh: true);
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to approve leave';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error approving leave: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectLeave(int leaveId, String notes) async {
    _setLoading(true);
    try {
      final result = await _adminService.rejectLeave(leaveId, notes);

      if (result['success'] == true) {
        await loadLeaveRequests(refresh: true);
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to reject leave';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error rejecting leave: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // KPI Analytics methods
  Future<void> loadKpiAnalytics() async {
    print('🔄 ADMIN: Starting loadKpiAnalytics...');
    _setLoading(true);
    try {
      final result = await _adminService.getKpiAnalytics();
      print('📊 ADMIN: KPI Analytics API result: $result');

      if (result['success'] == true) {
        _kpiAnalytics = result['data'];
        print('✅ ADMIN: KPI analytics loaded successfully');
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Failed to load KPI analytics';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('Error loading KPI analytics: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Attendance Report methods
  Future<Map<String, dynamic>> getDetailedAttendanceReport({
    String? dateRange = 'day',
    String? date,
    String? status,
  }) async {
    try {
      print('🔄 ADMIN: Getting detailed attendance report...');

      final params = <String, dynamic>{};
      if (dateRange != null) params['date_range'] = dateRange;
      if (date != null) params['date'] = date;
      if (status != null) params['status'] = status;

      print('📊 ADMIN: Report params: $params');

      final result = await _adminService.getDetailedAttendanceReport(params);
      print('📊 ADMIN: Report result: $result');

      return result;
    } catch (e) {
      print('❌ Error getting attendance report: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Leave Report methods
  Future<Map<String, dynamic>> getDetailedLeaveReport({
    int? year,
    String? type,
    String? status,
  }) async {
    try {
      print('🔄 ADMIN: Getting detailed leave report...');

      final params = <String, dynamic>{};
      if (year != null) params['year'] = year;
      if (type != null) params['type'] = type;
      if (status != null) params['status'] = status;

      print('📊 ADMIN: Leave report params: $params');

      final result = await _adminService.getDetailedLeaveReport(params);
      print('📊 ADMIN: Leave report result: $result');

      return result;
    } catch (e) {
      print('❌ Error getting leave report: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Export data functionality
  Future<bool> exportData(Map<String, dynamic> params) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔄 ADMIN: Exporting data with params: $params');

      final result = await _adminService.exportData(params);

      if (result['success'] == true) {
        print('✅ ADMIN: Export successful');
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Export failed';
        print('❌ ADMIN: Export failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print('❌ Error exporting data: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
