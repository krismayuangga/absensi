import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeProvider.primaryColor,
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
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Mode Section
                _buildSection(
                  'Mode Tema',
                  'Pilih mode tema yang Anda inginkan',
                  [
                    _buildThemeModeOption(
                      'Light Mode',
                      'Tema terang untuk penggunaan sehari-hari',
                      Icons.light_mode,
                      ThemeMode.light,
                      themeProvider,
                    ),
                    _buildThemeModeOption(
                      'Dark Mode',
                      'Tema gelap untuk kenyamanan mata',
                      Icons.dark_mode,
                      ThemeMode.dark,
                      themeProvider,
                    ),
                    _buildThemeModeOption(
                      'Auto (Sistem)',
                      'Ikuti pengaturan sistem perangkat',
                      Icons.auto_mode,
                      ThemeMode.system,
                      themeProvider,
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Color Scheme Section
                _buildSection(
                  'Skema Warna',
                  'Pilih warna utama aplikasi',
                  [
                    _buildColorPalette(themeProvider),
                  ],
                ),

                SizedBox(height: 24.h),

                // Preview Section
                _buildSection(
                  'Preview',
                  'Lihat tampilan dengan tema yang dipilih',
                  [
                    _buildPreviewCard(themeProvider),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 12.h),
        ...children,
      ],
    );
  }

  Widget _buildThemeModeOption(
    String title,
    String description,
    IconData icon,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected
              ? themeProvider.primaryColor
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: themeProvider.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        onTap: () => themeProvider.setThemeMode(mode),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isSelected
                ? themeProvider.primaryColor.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? themeProvider.primaryColor
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 20.sp,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? themeProvider.primaryColor
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Radio<ThemeMode>(
          value: mode,
          groupValue: themeProvider.themeMode,
          onChanged: (value) => themeProvider.setThemeMode(value!),
          activeColor: themeProvider.primaryColor,
        ),
      ),
    );
  }

  Widget _buildColorPalette(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 2.5,
        ),
        itemCount: ThemeProvider.availableColors.length,
        itemBuilder: (context, index) {
          final color = ThemeProvider.availableColors[index];
          final name = ThemeProvider.colorNames[index];
          final isSelected = themeProvider.primaryColor.value == color.value;

          return GestureDetector(
            onTap: () => themeProvider.setPrimaryColor(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      name.split(' ')[0], // Take first word only
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 12.sp,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewCard(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          // Mock App Bar
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: themeProvider.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                Icon(Icons.menu, color: Colors.white, size: 20.sp),
                SizedBox(width: 16.w),
                Text(
                  'Preview Aplikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Mock Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Primary',
                    style: GoogleFonts.inter(fontSize: 12.sp),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeProvider.primaryColor,
                    side: BorderSide(color: themeProvider.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Secondary',
                    style: GoogleFonts.inter(fontSize: 12.sp),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Mock List Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: themeProvider.primaryColor,
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item ${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Description untuk item ${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: themeProvider.primaryColor,
                      size: 20.sp,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
