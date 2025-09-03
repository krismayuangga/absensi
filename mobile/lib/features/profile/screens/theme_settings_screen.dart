import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  final List<Map<String, dynamic>> _themes = [
    {
      'id': 'light',
      'name': 'Light Mode',
      'description': 'Tema terang untuk penggunaan sehari-hari',
      'icon': Icons.light_mode,
      'primaryColor': Color(0xFF4A9B8E),
      'backgroundColor': Colors.white,
      'textColor': Colors.black87,
    },
    {
      'id': 'dark',
      'name': 'Dark Mode',
      'description': 'Tema gelap untuk kenyamanan mata',
      'icon': Icons.dark_mode,
      'primaryColor': Color(0xFF4A9B8E),
      'backgroundColor': Color(0xFF121212),
      'textColor': Colors.white,
    },
    {
      'id': 'auto',
      'name': 'Auto (Sistem)',
      'description': 'Ikuti pengaturan sistem perangkat',
      'icon': Icons.auto_mode,
      'primaryColor': Color(0xFF4A9B8E),
      'backgroundColor': Colors.grey.shade100,
      'textColor': Colors.black54,
    },
  ];

  final List<Map<String, dynamic>> _colorSchemes = [
    {
      'name': 'Teal (Default)',
      'color': Color(0xFF4A9B8E),
    },
    {
      'name': 'Blue',
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Purple',
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Green',
      'color': Color(0xFF4CAF50),
    },
    {
      'name': 'Orange',
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'Red',
      'color': Color(0xFFF44336),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Pengaturan Tema',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Mode Section
                _buildSection(
                  'Mode Tema',
                  'Pilih tampilan yang nyaman untuk Anda',
                  Column(
                    children: _themes.map((theme) {
                      bool isSelected =
                          profileProvider.selectedTheme == theme['id'];

                      return _buildThemeCard(
                        theme: theme,
                        isSelected: isSelected,
                        onTap: () => _selectTheme(theme['id']),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 24.h),

                // Color Scheme Section
                _buildSection(
                  'Skema Warna',
                  'Pilih warna utama aplikasi',
                  Container(
                    padding: EdgeInsets.all(16.w),
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
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1,
                          ),
                          itemCount: _colorSchemes.length,
                          itemBuilder: (context, index) {
                            final colorScheme = _colorSchemes[index];
                            bool isSelected = AppTheme.primaryColor.value ==
                                colorScheme['color'].value;

                            return GestureDetector(
                              onTap: () =>
                                  _selectColorScheme(colorScheme['color']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme['color'],
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.black, width: 3)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          colorScheme['color'].withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 32.r,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        // Color names
                        Wrap(
                          children: _colorSchemes.map((colorScheme) {
                            bool isSelected = AppTheme.primaryColor.value ==
                                colorScheme['color'].value;

                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              child: Chip(
                                label: Text(
                                  colorScheme['name'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                backgroundColor: isSelected
                                    ? colorScheme['color']
                                    : Colors.grey.shade100,
                                side: isSelected
                                    ? BorderSide.none
                                    : BorderSide(color: Colors.grey.shade300),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Preview Section
                _buildSection(
                  'Pratinjau',
                  'Lihat bagaimana tema akan terlihat',
                  _buildThemePreview(),
                ),

                SizedBox(height: 24.h),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () => _resetTheme(),
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
                          Icons.restore,
                          color: AppTheme.primaryColor,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Reset ke Default',
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

  Widget _buildSection(String title, String description, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        child,
      ],
    );
  }

  Widget _buildThemeCard({
    required Map<String, dynamic> theme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: theme['backgroundColor'],
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(
                  theme['icon'],
                  color: theme['textColor'],
                  size: 24.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      theme['description'],
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 24.r,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock App Bar
          Container(
            width: double.infinity,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'Pratinjau App Bar',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Mock Content
          Text(
            'Contoh Teks Utama',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Ini adalah contoh teks sekunder dalam tema yang dipilih. Teks ini menunjukkan bagaimana konten akan terlihat.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),

          // Mock Button
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'Contoh Tombol',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTheme(String themeId) {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.updateThemeSetting(themeId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tema diubah ke ${_getThemeName(themeId)}'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _selectColorScheme(Color color) {
    // TODO: Implement color scheme change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Skema warna akan segera tersedia!'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  void _resetTheme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Reset Tema',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengatur ulang tema ke pengaturan default?',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              profileProvider.updateThemeSetting('light');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tema berhasil direset ke default'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text(
              'Reset',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(String themeId) {
    final theme = _themes.firstWhere(
      (t) => t['id'] == themeId,
      orElse: () => _themes.first,
    );
    return theme['name'];
  }
}
