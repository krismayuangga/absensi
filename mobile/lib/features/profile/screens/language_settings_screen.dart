import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/profile_provider.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'id',
      'name': 'Bahasa Indonesia',
      'nativeName': 'Bahasa Indonesia',
      'flag': '🇮🇩',
    },
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    {
      'code': 'ms',
      'name': 'Bahasa Melayu',
      'nativeName': 'Bahasa Melayu',
      'flag': '🇲🇾',
    },
    {
      'code': 'zh',
      'name': 'Chinese',
      'nativeName': '中文',
      'flag': '🇨🇳',
    },
    {
      'code': 'ja',
      'name': 'Japanese',
      'nativeName': '日本語',
      'flag': '🇯🇵',
    },
    {
      'code': 'ko',
      'name': 'Korean',
      'nativeName': '한국어',
      'flag': '🇰🇷',
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
          'Pengaturan Bahasa',
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
                // Info Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 24.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Pilih bahasa yang ingin Anda gunakan di aplikasi ini. Aplikasi akan restart setelah mengubah bahasa.',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Language List
                Container(
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
                    children: _languages.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> language = entry.value;
                      bool isSelected =
                          profileProvider.selectedLanguage == language['code'];

                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Text(
                                  language['flag'],
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                              ),
                            ),
                            title: Text(
                              language['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              language['nativeName'],
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                    size: 24.r,
                                  )
                                : Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.grey.shade400,
                                    size: 24.r,
                                  ),
                            onTap: () => _selectLanguage(language['code']),
                            contentPadding: EdgeInsets.all(16.w),
                          ),
                          if (index < _languages.length - 1)
                            Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                              indent: 72.w,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 24.h),

                // Currently Selected
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bahasa Saat Ini',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getLanguageName(profileProvider.selectedLanguage),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // App Language Features
                Container(
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
                      Text(
                        'Fitur Multi-Bahasa',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildFeatureItem('✓ Interface aplikasi'),
                      _buildFeatureItem('✓ Pesan notifikasi'),
                      _buildFeatureItem('✓ Laporan dan data'),
                      _buildFeatureItem('✓ Format tanggal dan waktu'),
                      _buildFeatureItem('✓ Mata uang dan angka'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    final language = _languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => _languages.first,
    );
    return language['name'];
  }

  void _selectLanguage(String languageCode) {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    if (profileProvider.selectedLanguage == languageCode) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Ubah Bahasa',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Aplikasi akan restart untuk menerapkan bahasa baru. Lanjutkan?',
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
              profileProvider.updateLanguageSetting(languageCode);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Bahasa diubah ke ${_getLanguageName(languageCode)}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );

              // TODO: Implement app restart logic
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            },
            child: Text(
              'Ubah',
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
}
