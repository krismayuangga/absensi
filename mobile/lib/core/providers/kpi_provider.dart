import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/kpi_service.dart';

class KPIProvider extends ChangeNotifier {
  final KpiService _kpiService = KpiService();

  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // KPI Stats
  int _todayVisits = 0;
  int _weekVisits = 0;
  int _monthVisits = 0;
  double _successRate = 0.0;
  double _potentialValue = 0.0;
  String _formattedPotentialValue = 'Rp 0';
  double _avgPerVisit = 0.0;
  String _formattedAvgPerVisit = 'Rp 0';

  // Analytics data
  Map<String, int> _visitsByPurpose = {
    'prospecting': 0,
    'follow_up': 0,
    'closing': 0,
  };
  List<Map<String, dynamic>> _topClients = [];

  // Visit History
  List<Map<String, dynamic>> _visitHistory = [];
  List<Map<String, dynamic>> _pendingVisits = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  int get todayVisits => _todayVisits;
  int get weekVisits => _weekVisits;
  int get monthVisits => _monthVisits;
  double get successRate => _successRate;
  double get potentialValue => _potentialValue;
  String get formattedPotentialValue => _formattedPotentialValue;
  double get avgPerVisit => _avgPerVisit;
  String get formattedAvgPerVisit => _formattedAvgPerVisit;

  Map<String, int> get visitsByPurpose => _visitsByPurpose;
  List<Map<String, dynamic>> get topClients => _topClients;

  List<Map<String, dynamic>> get visitHistory => _visitHistory;
  List<Map<String, dynamic>> get pendingVisits => _pendingVisits;

  // Load KPI statistics
  Future<void> loadKpiStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _kpiService.getKpiStats();

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;

        // Safe integer parsing
        _todayVisits = _safeParseInt(data['today_visits']);
        _weekVisits = _safeParseInt(data['week_visits']);
        _monthVisits = _safeParseInt(data['month_visits']);

        // Safe double parsing
        _successRate = _safeParseDouble(data['success_rate']);
        _potentialValue = _safeParseDouble(data['potential_value']);
        _avgPerVisit = _safeParseDouble(data['avg_per_visit']);

        // Safe string handling
        _formattedPotentialValue =
            (data['formatted_potential_value'] as String?) ?? 'Rp 0';
        _formattedAvgPerVisit =
            (data['formatted_avg_per_visit'] as String?) ?? 'Rp 0';

        // Parse visits by purpose
        if (data['visits_by_purpose'] != null) {
          final purposeData = data['visits_by_purpose'] as Map<String, dynamic>;
          _visitsByPurpose = {
            'prospecting': _safeParseInt(purposeData['prospecting']),
            'follow_up': _safeParseInt(purposeData['follow_up']),
            'closing': _safeParseInt(purposeData['closing']),
          };
        }

        // Parse visit history
        if (data['visit_history'] != null) {
          _visitHistory =
              (data['visit_history'] as List).cast<Map<String, dynamic>>();
        }

        // Parse top clients
        if (data['top_clients'] != null) {
          _topClients =
              (data['top_clients'] as List).cast<Map<String, dynamic>>();
        }

        print('✅ KPI Stats loaded successfully:');
        print('   📊 Month visits: $_monthVisits');
        print('   💯 Success rate: $_successRate%');
        print('   💰 Potential value: $_formattedPotentialValue');
        print('   📈 Visits by purpose: $_visitsByPurpose');
        print('   👥 Visit history count: ${_visitHistory.length}');
      } else {
        _errorMessage = result['message'] as String? ?? 'Gagal memuat data';
        _setDefaultValues();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat statistik KPI: $e';
      _setDefaultValues();
      print('❌ Error loading KPI stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setDefaultValues() {
    _todayVisits = 0;
    _weekVisits = 0;
    _monthVisits = 0;
    _successRate = 0.0;
    _potentialValue = 0.0;
    _formattedPotentialValue = 'Rp 0';
    _avgPerVisit = 0.0;
    _formattedAvgPerVisit = 'Rp 0';
    _visitsByPurpose = {
      'prospecting': 0,
      'follow_up': 0,
      'closing': 0,
    };
    _visitHistory = [];
    _topClients = [];
  }

  // Log new visit
  Future<bool> logVisit({
    required String clientName,
    required String visitPurpose,
    required double latitude,
    required double longitude,
    String? address,
    String? notes,
    XFile? photo,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _kpiService.logVisit(
        clientName: clientName,
        visitPurpose: visitPurpose,
        latitude: latitude,
        longitude: longitude,
        address: address,
        startTime: DateTime.now(),
        notes: notes,
        photo: photo,
      );

      if (result['success']) {
        // Refresh stats after logging
        await loadKpiStats();
        await loadVisitHistory();
        await loadPendingVisits();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal mencatat kunjungan: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Update visit result
  Future<bool> updateVisitResult({
    required int visitId,
    required String status,
    DateTime? endTime,
    double? potentialValue,
    DateTime? nextFollowUp,
    String? nextAction,
    int? probabilityScore,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _kpiService.updateVisitResult(
        visitId: visitId,
        status: status,
        endTime: endTime,
        potentialValue: potentialValue,
        nextFollowUp: nextFollowUp,
        nextAction: nextAction,
        probabilityScore: probabilityScore,
      );

      if (result['success']) {
        // Refresh data after updating
        await loadKpiStats();
        await loadVisitHistory();
        await loadPendingVisits();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal memperbarui hasil: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Load visit history
  Future<void> loadVisitHistory({String period = 'week'}) async {
    try {
      final result = await _kpiService.getVisitHistory(period: period);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        if (data is List) {
          _visitHistory = data.cast<Map<String, dynamic>>();
        } else {
          _visitHistory = [];
        }
      } else {
        _visitHistory = [];
        _errorMessage = result['message'] as String? ?? 'Gagal memuat riwayat';
      }
    } catch (e) {
      _visitHistory = [];
      _errorMessage = 'Gagal memuat riwayat kunjungan: $e';
    }

    notifyListeners();
  }

  // Load pending visits
  Future<void> loadPendingVisits() async {
    try {
      final result = await _kpiService.getPendingVisits();

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        if (data is List) {
          _pendingVisits = data.cast<Map<String, dynamic>>();
        } else {
          _pendingVisits = [];
        }
      } else {
        _pendingVisits = [];
        _errorMessage =
            result['message'] as String? ?? 'Gagal memuat data pending';
      }
    } catch (e) {
      _pendingVisits = [];
      _errorMessage = 'Gagal memuat kunjungan pending: $e';
    }

    notifyListeners();
  }

  // Get formatted success rate
  String getFormattedSuccessRate() {
    return '${_successRate.toStringAsFixed(1)}%';
  }

  // Get visit purpose options in Indonesian
  static List<Map<String, String>> getVisitPurposeOptions() {
    return [
      {'value': 'prospecting', 'label': 'Prospek Baru'},
      {'value': 'follow_up', 'label': 'Tindak Lanjut'},
      {'value': 'closing', 'label': 'Penutupan Deal'},
    ];
  }

  // Get visit purpose label
  static String getVisitPurposeLabel(String value) {
    final options = getVisitPurposeOptions();
    final option = options.firstWhere(
      (opt) => opt['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return option['label']!;
  }

  // Get result status options in Indonesian
  static List<Map<String, String>> getResultStatusOptions() {
    return [
      {'value': 'pending', 'label': 'Menunggu'},
      {'value': 'success', 'label': 'Berhasil'},
      {'value': 'failed', 'label': 'Tidak Berhasil'},
      {'value': 'potential', 'label': 'Potensial'},
    ];
  }

  // Get result status label
  static String getResultStatusLabel(String value) {
    final options = getResultStatusOptions();
    final option = options.firstWhere(
      (opt) => opt['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return option['label']!;
  }

  // Get next action options
  static List<Map<String, String>> getNextActionOptions() {
    return [
      {'value': 'follow_up', 'label': 'Tindak Lanjut'},
      {'value': 'call', 'label': 'Telepon'},
      {'value': 'meeting', 'label': 'Meeting Lanjutan'},
      {'value': 'proposal', 'label': 'Kirim Proposal'},
      {'value': 'presentation', 'label': 'Presentasi'},
      {'value': 'closing', 'label': 'Penutupan Deal'},
      {'value': 'none', 'label': 'Tidak Ada'},
    ];
  }

  // Get status options in Indonesian
  static List<Map<String, String>> getStatusOptions() {
    return [
      {'value': 'success', 'label': 'Berhasil'},
      {'value': 'failed', 'label': 'Tidak Berhasil'},
    ];
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize KPI data
  Future<void> initialize() async {
    await loadKpiStats();
    await loadPendingVisits();
    await loadVisitHistory();
  }

  // Load report data for specific period
  Future<void> loadReportData(String period) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load KPI stats
      await loadKpiStats();

      // Load visit history for the period
      await loadVisitHistory(period: period);

      // Load pending visits
      await loadPendingVisits();
    } catch (e) {
      _errorMessage = 'Gagal memuat data laporan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods for safe type parsing
  int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
