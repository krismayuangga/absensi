import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../admin/screens/admin_main_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/theme_settings_screen.dart';

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key});

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreenState();
}

class _ProfileMainScreenState extends State<ProfileMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profileData = profileProvider.userProfile?['data'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40.w,
                          color: theme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        profileData?['name'] ?? 'User Name',
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${profileData?['employee_id'] ?? ''} • ${_getRoleInIndonesian(profileData?['role'])}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Edit Profile Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 16.r),
                            SizedBox(width: 4.w),
                            Text(
                              'Edit Profil',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Personal Information
                _buildSection('Informasi Pribadi', [
                  _buildInfoItem(
                      'Email',
                      profileData?['email'] ?? 'email@company.com',
                      Icons.email),
                  _buildInfoItem(
                      'Nomor HP', profileData?['phone'] ?? '-', Icons.phone),
                  _buildInfoItem('Alamat', profileData?['address'] ?? '-',
                      Icons.location_on),
                  _buildInfoItem(
                      'Tanggal Lahir',
                      _formatDate(profileData?['birth_date']) ?? '-',
                      Icons.cake),
                ]),

                SizedBox(height: 20.h),

                // Work Information
                _buildSection('Informasi Kerja', [
                  _buildInfoItem(
                      'Posisi',
                      profileData?['position'] ?? 'Software Developer',
                      Icons.work),
                  _buildInfoItem(
                      'Departemen',
                      profileData?['department'] ?? 'IT Department',
                      Icons.business),
                  _buildInfoItem(
                      'Tanggal Bergabung',
                      _formatDate(profileData?['join_date']) ?? '-',
                      Icons.calendar_today),
                  _buildInfoItem(
                      'Status',
                      profileData?['is_active'] == true ? 'Aktif' : 'Non-Aktif',
                      Icons.badge),
                ]),

                SizedBox(height: 20.h),

                // Admin Panel Section (Only for Admin Users)
                if (profileData?['role']?.toLowerCase() == 'admin') ...[
                  _buildSection('Panel Admin', [
                    _buildMenuButton('Dashboard Admin', Icons.dashboard, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminMainScreen(),
                        ),
                      );
                    }),
                  ]),
                  SizedBox(height: 20.h),
                ],

                // Account Settings
                _buildSection('Pengaturan Akun', [
                  _buildMenuButton('Ganti Password', Icons.lock, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  }),
                  _buildMenuButton('Notifikasi', Icons.notifications, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationSettingsScreen(),
                      ),
                    );
                  }),
                  _buildMenuButton('Tema', Icons.palette, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemeSettingsScreen(),
                      ),
                    );
                  }),
                ]),

                SizedBox(height: 20.h),

                // Application Info
                _buildSection('Tentang Aplikasi', [
                  _buildInfoItem('Versi', '1.0.0', Icons.info),
                  _buildInfoItem('Build', '2025.09.09', Icons.code),
                  _buildMenuButton('Bantuan & Support', Icons.help, () {
                    _showHelp();
                  }),
                  _buildMenuButton('Kebijakan Perusahaan', Icons.policy, () {
                    _showCompanyPolicy();
                  }),
                ]),

                SizedBox(height: 32.h),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout),
                        SizedBox(width: 8.w),
                        Text(
                          'Keluar Akun',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color ?? theme.primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.cardColor.withOpacity(0.3)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 20.w,
              color: theme.unselectedWidgetColor,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? theme.cardColor.withOpacity(0.3)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.w,
                color: theme.unselectedWidgetColor,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.unselectedWidgetColor,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleInIndonesian(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'manager':
        return 'MANAJER';
      case 'employee':
        return 'KARYAWAN';
      case 'hr':
        return 'SDM';
      default:
        return role?.toUpperCase() ?? 'KARYAWAN';
    }
  }

  String? _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      final DateTime date = DateTime.parse(dateString);
      final List<String> months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Keluar Akun',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Store navigator reference
                final navigator = Navigator.of(context);

                // Close dialog first
                navigator.pop();

                // Perform logout
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);

                try {
                  await authProvider.logout();
                  debugPrint('✅ Logout successful, navigating to login...');
                } catch (e) {
                  debugPrint('❌ Logout error: $e');
                }

                // Navigate to login using global navigator key
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  debugPrint('🔄 Attempting navigation to login...');
                  navigatorKey.currentState?.pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                });
              },
              child: Text(
                'Keluar',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Bantuan & Support',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Butuh bantuan? Hubungi tim IT internal:',
                style: GoogleFonts.inter(fontSize: 14.sp),
              ),
              SizedBox(height: 16.h),
              _buildContactItem(
                  Icons.email, 'Email', 'it-support@perusahaan.com'),
              _buildContactItem(Icons.phone, 'Telepon', 'Ext. 123'),
              _buildContactItem(Icons.chat, 'WhatsApp', '+62 811-2345-6789'),
              SizedBox(height: 16.h),
              Text(
                'FAQ Umum:',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '• Cara absen: Buka tab Beranda > Tap tombol Clock In\n'
                '• Lupa password: Hubungi admin untuk reset\n'
                '• Masalah GPS: Pastikan lokasi aktif dan izin diberikan\n'
                '• Laporan error: Screenshot error dan kirim ke IT',
                style: GoogleFonts.inter(fontSize: 12.sp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showCompanyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Kebijakan Perusahaan',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kebijakan Penggunaan Aplikasi Absensi:',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '1. Kehadiran & Absensi:\n'
                '• Wajib absen tepat waktu sesuai jadwal\n'
                '• Absen hanya di lokasi yang ditentukan\n'
                '• Dilarang titip absen atau manipulasi GPS\n\n'
                '2. Data Pribadi:\n'
                '• Data karyawan dilindungi sesuai UU\n'
                '• Akses data terbatas sesuai jabatan\n'
                '• Wajib menjaga kerahasiaan data\n\n'
                '3. Penggunaan Aplikasi:\n'
                '• Gunakan hanya untuk keperluan kerja\n'
                '• Dilarang berbagi akun dengan orang lain\n'
                '• Laporkan bug atau masalah ke IT\n\n'
                '4. Sanksi:\n'
                '• Pelanggaran akan dikenai sanksi\n'
                '• Sanksi sesuai aturan perusahaan',
                style: GoogleFonts.inter(fontSize: 12.sp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}
