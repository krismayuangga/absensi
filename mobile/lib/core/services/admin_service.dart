import 'package:dio/dio.dart';
import '../config/app_config.dart';

class AdminService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  AdminService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Add auth token to headers
  void _addAuthToken() {
    try {
      final authBox = AppConfig.getBox(AppConfig.authBox);
      final token = authBox.get(AppConfig.tokenKey);
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('Auth token not available: $e');
    }
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('🔄 ADMIN SERVICE: Calling dashboard stats API...');
      _addAuthToken();

      final response = await _dio.get('/admin/dashboard/stats');
      print(
          '📊 ADMIN SERVICE: Dashboard response status: ${response.statusCode}');
      print('📊 ADMIN SERVICE: Dashboard response data: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get dashboard stats',
      };
    } catch (e) {
      print('❌ Error getting dashboard stats: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Failed to get dashboard stats',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get employees with pagination and search
  Future<Map<String, dynamic>> getEmployees({
    int page = 1,
    int perPage = 15,
    String? search,
  }) async {
    try {
      _addAuthToken();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response =
          await _dio.get('/admin/employees', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get employees',
      };
    } catch (e) {
      print('❌ Error getting employees: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to get employees',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Create new employee
  Future<Map<String, dynamic>> createEmployee(
      Map<String, dynamic> employeeData) async {
    try {
      print('🔄 ADMIN SERVICE: Creating employee...');
      print('📊 Employee data: $employeeData');

      _addAuthToken();

      final response = await _dio.post('/admin/employees', data: employeeData);

      print('📡 Create employee response status: ${response.statusCode}');
      print('📦 Create employee response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to create employee',
        'errors': response.data['errors'],
      };
    } catch (e) {
      print('❌ Error creating employee: $e');
      if (e is DioException && e.response != null) {
        print('❌ DioException status: ${e.response?.statusCode}');
        print('❌ DioException data: ${e.response?.data}');
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to create employee',
          'errors': e.response?.data['errors'],
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update employee
  Future<Map<String, dynamic>> updateEmployee(
      int id, Map<String, dynamic> employeeData) async {
    try {
      _addAuthToken();

      final response =
          await _dio.put('/admin/employees/$id', data: employeeData);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update employee',
        'errors': response.data['errors'],
      };
    } catch (e) {
      print('❌ Error updating employee: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to update employee',
          'errors': e.response?.data['errors'],
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete employee
  Future<Map<String, dynamic>> deleteEmployee(int id) async {
    try {
      _addAuthToken();

      final response = await _dio.delete('/admin/employees/$id');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to delete employee',
      };
    } catch (e) {
      print('❌ Error deleting employee: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to delete employee',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get attendance records with filtering
  Future<Map<String, dynamic>> getAttendanceRecords({
    int page = 1,
    int perPage = 15,
    String? date,
    int? employeeId,
    String? status,
  }) async {
    try {
      _addAuthToken();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (date != null) queryParams['date'] = date;
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (status != null) queryParams['status'] = status;

      final response =
          await _dio.get('/admin/attendance', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message':
            response.data['message'] ?? 'Failed to get attendance records',
      };
    } catch (e) {
      print('❌ Error getting attendance records: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Failed to get attendance records',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get leave requests with filtering
  Future<Map<String, dynamic>> getLeaveRequests({
    int page = 1,
    int perPage = 15,
    String? status,
    int? employeeId,
  }) async {
    try {
      _addAuthToken();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (status != null) queryParams['status'] = status;
      if (employeeId != null) queryParams['employee_id'] = employeeId;

      final response =
          await _dio.get('/admin/leaves', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get leave requests',
      };
    } catch (e) {
      print('❌ Error getting leave requests: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Failed to get leave requests',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update leave request status
  Future<Map<String, dynamic>> updateLeaveStatus(
      int id, String status, String? adminNotes) async {
    try {
      _addAuthToken();

      final data = {
        'status': status,
        if (adminNotes != null) 'admin_notes': adminNotes,
      };

      final response = await _dio.put('/admin/leaves/$id/status', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update leave status',
        'errors': response.data['errors'],
      };
    } catch (e) {
      print('❌ Error updating leave status: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Failed to update leave status',
          'errors': e.response?.data['errors'],
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get master data (companies, departments, positions)
  Future<Map<String, dynamic>> getMasterData() async {
    try {
      _addAuthToken();

      print('🔍 Calling master data API: /admin/master-data');
      final response = await _dio.get('/admin/master-data');
      print('📊 Master data response status: ${response.statusCode}');
      print('📊 Master data response: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get master data',
      };
    } catch (e) {
      print('❌ Error getting master data: $e');
      if (e is DioException && e.response != null) {
        print('❌ DioException response: ${e.response?.data}');
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to get master data',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get employee by ID with complete data for editing
  Future<Map<String, dynamic>> getEmployee(int employeeId) async {
    try {
      _addAuthToken();

      print('🔍 Fetching employee data for ID: $employeeId');
      final response = await _dio.get('/admin/employees/$employeeId');
      print('📊 Employee response status: ${response.statusCode}');
      print('📊 Employee response: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get employee data',
      };
    } catch (e) {
      print('❌ Error getting employee data: $e');
      if (e is DioException && e.response != null) {
        print('❌ DioException response: ${e.response?.data}');
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Failed to get employee data',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Approve leave request
  Future<Map<String, dynamic>> approveLeave(int leaveId, String notes) async {
    try {
      _addAuthToken();

      final data = {
        'status': 'approved',
        'notes': notes,
      };

      final response =
          await _dio.put('/admin/leaves/$leaveId/status', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Leave approved successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to approve leave',
      };
    } catch (e) {
      print('❌ Error approving leave: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to approve leave',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Reject leave request
  Future<Map<String, dynamic>> rejectLeave(int leaveId, String notes) async {
    try {
      _addAuthToken();

      final data = {
        'status': 'rejected',
        'notes': notes,
      };

      final response =
          await _dio.put('/admin/leaves/$leaveId/status', data: data);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Leave rejected successfully',
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to reject leave',
      };
    } catch (e) {
      print('❌ Error rejecting leave: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to reject leave',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get KPI analytics for all employees
  Future<Map<String, dynamic>> getKpiAnalytics() async {
    try {
      print('🔄 ADMIN SERVICE: Calling KPI analytics API...');
      _addAuthToken();

      final response = await _dio.get('/admin/kpi/analytics');
      print(
          '📊 ADMIN SERVICE: KPI analytics response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get KPI analytics',
      };
    } catch (e) {
      print('❌ Error getting KPI analytics: $e');
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Failed to get KPI analytics',
        };
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
