import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/attendance_provider.dart';
import 'core/providers/kpi_provider.dart';
import 'core/providers/leave_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/info_media_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/admin_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await AppConfig.initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => AttendanceProvider()),
            ChangeNotifierProvider(create: (_) => KPIProvider()),
            ChangeNotifierProvider(create: (_) => LeaveProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => InfoMediaProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => AdminProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Attendance & KPI',
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                debugShowCheckedModeBanner: false,
                home: const SplashScreen(),
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/main': (context) => const MainNavigation(),
                  '/dashboard': (context) => const DashboardScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }
}
