import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/attendance/attendance_main_screen.dart';
import 'features/kpi/kpi_main_screen.dart';
import 'features/info/info_main_screen.dart';
import 'features/profile/profile_main_screen.dart';
import 'features/admin/admin_main_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

// Global navigation controller
class NavigationController {
  static _MainNavigationState? _navigationState;

  static void register(_MainNavigationState state) {
    _navigationState = state;
  }

  static void changeTab(int index, [bool isAdmin = false]) {
    _navigationState?.changeTab(index, isAdmin);
  }
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> _getScreens(bool isAdmin) {
    final baseScreens = [
      const DashboardScreen(),
      const AttendanceMainScreen(),
      const KPIMainScreen(),
      const InfoMainScreen(),
      const ProfileMainScreen(),
    ];

    if (isAdmin) {
      // Insert admin screen at second position
      baseScreens.insert(1, const AdminMainScreen());
    }

    return baseScreens;
  }

  @override
  void initState() {
    super.initState();
    // Register this state with the navigation controller
    NavigationController.register(this);
  }

  // Method to change tab from external widgets
  void changeTab(int index, bool isAdmin) {
    final screens = _getScreens(isAdmin);
    if (index >= 0 && index < screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isAdmin = user?.isAdmin ?? false;
        final screens = _getScreens(isAdmin);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildNavItems(isAdmin),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildNavItems(bool isAdmin) {
    final items = [
      _buildNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Beranda',
        index: 0,
      ),
    ];

    if (isAdmin) {
      items.add(_buildNavItem(
        icon: Icons.admin_panel_settings_outlined,
        activeIcon: Icons.admin_panel_settings,
        label: 'Admin',
        index: 1,
      ));
      items.addAll([
        _buildNavItem(
          icon: Icons.access_time_outlined,
          activeIcon: Icons.access_time,
          label: 'Absensi',
          index: 2,
        ),
        _buildNavItem(
          icon: Icons.trending_up_outlined,
          activeIcon: Icons.trending_up,
          label: 'KPI',
          index: 3,
        ),
        _buildNavItem(
          icon: Icons.info_outline,
          activeIcon: Icons.info,
          label: 'Info',
          index: 4,
        ),
        _buildNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
          index: 5,
        ),
      ]);
    } else {
      items.addAll([
        _buildNavItem(
          icon: Icons.access_time_outlined,
          activeIcon: Icons.access_time,
          label: 'Absensi',
          index: 1,
        ),
        _buildNavItem(
          icon: Icons.trending_up_outlined,
          activeIcon: Icons.trending_up,
          label: 'KPI',
          index: 2,
        ),
        _buildNavItem(
          icon: Icons.info_outline,
          activeIcon: Icons.info,
          label: 'Info',
          index: 3,
        ),
        _buildNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
          index: 4,
        ),
      ]);
    }

    return items;
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12.w : 8.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade600,
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
