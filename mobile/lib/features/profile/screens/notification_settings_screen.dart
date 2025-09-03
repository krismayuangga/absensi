import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _attendanceReminders = true;
  bool _leaveNotifications = true;
  bool _kpiUpdates = true;
  bool _systemAnnouncements = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    setState(() {
      _pushNotifications = profileProvider.notificationsEnabled;
    });
  }

  Future<void> _updateNotificationSetting(String setting, bool value) async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    // Update UI immediately
    setState(() {
      switch (setting) {
        case 'push':
          _pushNotifications = value;
          break;
        case 'email':
          _emailNotifications = value;
          break;
        case 'attendance':
          _attendanceReminders = value;
          break;
        case 'leave':
          _leaveNotifications = value;
          break;
        case 'kpi':
          _kpiUpdates = value;
          break;
        case 'announcements':
          _systemAnnouncements = value;
          break;
        case 'sound':
          _soundEnabled = value;
          break;
        case 'vibration':
          _vibrationEnabled = value;
          break;
      }
    });

    // Update backend for push notifications
    if (setting == 'push') {
      final success = await profileProvider.updateNotificationSettings(value);
      if (!success) {
        // Revert if failed
        setState(() {
          _pushNotifications = !value;
        });
        _showErrorSnackBar('Gagal memperbarui pengaturan notifikasi');
      }
    }
  }

  Future<void> _selectTime(String type) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: type == 'start'
          ? TimeOfDay(hour: 22, minute: 0)
          : TimeOfDay(hour: 7, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      final formattedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (type == 'start') {
          _quietHoursStart = formattedTime;
        } else {
          _quietHoursEnd = formattedTime;
        }
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Pengaturan Notifikasi',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // General Notifications
                _buildSection(
                  'Notifikasi Umum',
                  [
                    _buildSwitchTile(
                      'Push Notifications',
                      'Terima notifikasi push di perangkat ini',
                      Icons.notifications,
                      _pushNotifications,
                      (value) => _updateNotificationSetting('push', value),
                      isLoading: profileProvider.isLoading,
                    ),
                    _buildSwitchTile(
                      'Email Notifications',
                      'Terima notifikasi melalui email',
                      Icons.email,
                      _emailNotifications,
                      (value) => _updateNotificationSetting('email', value),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Feature-specific Notifications
                _buildSection(
                  'Notifikasi Fitur',
                  [
                    _buildSwitchTile(
                      'Pengingat Absensi',
                      'Pengingat untuk clock in/out',
                      Icons.access_time,
                      _attendanceReminders,
                      (value) =>
                          _updateNotificationSetting('attendance', value),
                    ),
                    _buildSwitchTile(
                      'Notifikasi Cuti',
                      'Update status permohonan cuti',
                      Icons.event_available,
                      _leaveNotifications,
                      (value) => _updateNotificationSetting('leave', value),
                    ),
                    _buildSwitchTile(
                      'Update KPI',
                      'Pemberitahuan target dan pencapaian',
                      Icons.trending_up,
                      _kpiUpdates,
                      (value) => _updateNotificationSetting('kpi', value),
                    ),
                    _buildSwitchTile(
                      'Pengumuman Sistem',
                      'Pengumuman dari admin dan info media',
                      Icons.campaign,
                      _systemAnnouncements,
                      (value) =>
                          _updateNotificationSetting('announcements', value),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Notification Behavior
                _buildSection(
                  'Perilaku Notifikasi',
                  [
                    _buildSwitchTile(
                      'Suara',
                      'Aktifkan suara notifikasi',
                      Icons.volume_up,
                      _soundEnabled,
                      (value) => _updateNotificationSetting('sound', value),
                    ),
                    _buildSwitchTile(
                      'Getaran',
                      'Aktifkan getaran notifikasi',
                      Icons.vibration,
                      _vibrationEnabled,
                      (value) => _updateNotificationSetting('vibration', value),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Quiet Hours
                _buildSection(
                  'Jam Hening',
                  [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tidak ada notifikasi selama jam hening',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeSelector(
                                  'Mulai',
                                  _quietHoursStart,
                                  () => _selectTime('start'),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildTimeSelector(
                                  'Selesai',
                                  _quietHoursEnd,
                                  () => _selectTime('end'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Test Notification Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () => _sendTestNotification(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send,
                          color: AppTheme.primaryColor,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Kirim Notifikasi Uji Coba',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    bool isLoading = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: value
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          size: 20.w,
          color: value ? AppTheme.primaryColor : Colors.grey.shade600,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: isLoading
          ? SizedBox(
              width: 20.r,
              height: 20.r,
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 2,
              ),
            )
          : Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
      contentPadding: EdgeInsets.all(16.w),
    );
  }

  Widget _buildTimeSelector(String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 20.r,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendTestNotification() {
    // TODO: Implement test notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifikasi uji coba terkirim!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
