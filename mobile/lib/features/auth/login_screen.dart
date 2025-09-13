import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Production ready - no auto-fill credentials
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && authProvider.isAuthenticated) {
        // Navigate to main navigation
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } else {
        // Handle login failure
        if (mounted) {
          final errorMessage = authProvider.errorMessage ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 80.h),

                    // Logo Section
                    Center(
                      child: Column(
                        children: [
                          // Logo with Pure Neon Glow Effect
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Neon glow layers
                              Container(
                                width: 90.w,
                                height: 90.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    // Outer neon glow - bright cyan
                                    BoxShadow(
                                      color: const Color(0xFF00FFFF)
                                          .withOpacity(0.6),
                                      blurRadius: 25,
                                      spreadRadius: 6,
                                    ),
                                    // Middle neon glow - electric blue
                                    BoxShadow(
                                      color: const Color(0xFF0099FF)
                                          .withOpacity(0.8),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                    // Inner bright glow
                                    BoxShadow(
                                      color: const Color(0xFF66DDFF)
                                          .withOpacity(0.9),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              // Logo image
                              Image.asset(
                                'assets/images/ozonelogo.png',
                                width: 70.w,
                                height: 70.w,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),

                          // Welcome Text
                          Text(
                            'Sistem KPI & Absensi',
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Ozone - Kinerja Group',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 60.h),

                    // Login Form Container
                    Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Field
                          Text(
                            'Email',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'admin@test.com',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppTheme.primaryColor,
                                size: 18.sp,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon masukkan email Anda';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Mohon masukkan email yang valid';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16.h),

                          // Password Field
                          Text(
                            'Kata Sandi',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppTheme.primaryColor,
                                size: 18.sp,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textSecondary,
                                  size: 18.sp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mohon masukkan kata sandi Anda';
                              }
                              if (value.length < 6) {
                                return 'Kata sandi minimal 6 karakter';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 20.h),

                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Container(
                                height: 48.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.w,
                                          child:
                                              const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Masuk',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Ozone - Kinerja Labs © 2025 | All Rights Reserved',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Version 1.0.0',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
