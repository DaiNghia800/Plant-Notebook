import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plant_notebook/common/styles/app_colors.dart';
import 'package:plant_notebook/data/services/app_preferences.dart';
import 'package:plant_notebook/routes/route_constant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    // Đợi 2 giây cho Splash
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final bool hasSeen = await AppPreferences.hasSeenOnboarding();
    if (hasSeen) {
      Navigator.of(context).pushReplacementNamed(loginViewRoute);
    } else {
      Navigator.of(context).pushReplacementNamed(onboardingViewRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFF1F8F6),
              Color(0xFFE1EFE7),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo placeholder
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 40,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.yard_outlined,
                  size: 64,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Sổ tay cây trồng',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF104A1F),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hành trình chăm sóc không gian\nxanh của riêng bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF5C7364),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Bottom Loading
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3E4D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'ĐANG CHUẨN BỊ VƯỜN HOA...',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A9382),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
