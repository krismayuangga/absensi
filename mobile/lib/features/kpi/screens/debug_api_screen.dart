import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/kpi_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/config/app_config.dart';

class DebugApiScreen extends StatefulWidget {
  const DebugApiScreen({super.key});

  @override
  State<DebugApiScreen> createState() => _DebugApiScreenState();
}

class _DebugApiScreenState extends State<DebugApiScreen> {
  final KpiService _kpiService = KpiService();
  final AuthService _authService = AuthService();
  String _debugLog = '';
  bool _isLoading = false;

  void _log(String message) {
    setState(() {
      _debugLog +=
          '${DateTime.now().toLocal().toString().substring(11, 19)}: $message\n';
    });
  }

  Future<void> _testWithLogin() async {
    setState(() {
      _isLoading = true;
      _debugLog = '';
    });

    _log('=== AUTO LOGIN TEST ===');

    try {
      // Try auto-login first
      final loginResult = await _authService.autoLoginForTesting();

      if (loginResult['success']) {
        _log('✓ Login SUCCESS');
        _log('Token received: ${loginResult['token']?.substring(0, 20)}...');
        _log('User: ${loginResult['user']['name']}');

        // Now test KPI Stats
        _log('=== KPI STATS TEST ===');
        final kpiResult = await _kpiService.getKpiStats();
        _log('Response: ${kpiResult.toString()}');

        if (kpiResult['success']) {
          _log('✓ KPI Stats SUCCESS');
          final data = kpiResult['data'];
          _log('Today visits: ${data['today_visits']}');
          _log('Week visits: ${data['week_visits']}');
          _log('Success rate: ${data['success_rate']}%');
        } else {
          _log('✗ KPI Stats FAILED: ${kpiResult['message']}');
        }
      } else {
        _log('✗ Login FAILED: ${loginResult['message']}');
      }
    } catch (e) {
      _log('✗ ERROR: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testSubmitVisit() async {
    setState(() {
      _isLoading = true;
      _debugLog = '';
    });

    _log('=== SUBMIT VISIT TEST ===');

    try {
      // Ensure login first
      if (!_authService.isLoggedIn()) {
        _log('No auth token, attempting login...');
        final loginResult = await _authService.autoLoginForTesting();
        if (!loginResult['success']) {
          _log('✗ Login failed: ${loginResult['message']}');
          return;
        }
        _log('✓ Auto-login successful');
      }

      final result = await _kpiService.logVisit(
        clientName: 'Debug Test Client',
        visitPurpose: 'prospecting',
        latitude: -6.2608,
        longitude: 106.7811,
        address: 'Jakarta Debug Office',
        startTime: DateTime.now(),
        notes: 'Test visit from debug API screen',
      );

      _log('Submit result: ${result.toString()}');

      if (result['success']) {
        _log('✓ Visit submit SUCCESS');
        _log('Visit ID: ${result['data']?['id']}');
      } else {
        _log('✗ Visit submit FAILED: ${result['message']}');
        if (result['errors'] != null) {
          _log('Validation errors: ${result['errors']}');
        }
      }
    } catch (e) {
      _log('✗ ERROR: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Debug API Test',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _debugLog = '';
              });
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Log',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _testWithLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.w),
              ),
              child: Text('Test Login + KPI Stats'),
            ),

            SizedBox(height: 12.h),

            ElevatedButton(
              onPressed: _isLoading ? null : _testSubmitVisit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.w),
              ),
              child: Text('Test Submit Visit'),
            ),

            SizedBox(height: 20.h),

            // Debug Log
            Text(
              'Debug Log:',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 8.h),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugLog.isEmpty
                        ? 'No logs yet. Press a button to test API.'
                        : _debugLog,
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            if (_isLoading)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.purple),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
