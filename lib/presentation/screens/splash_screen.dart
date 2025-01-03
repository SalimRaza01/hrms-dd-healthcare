// ignore_for_file: unused_field

import 'package:flutter/services.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'onboarding_screen.dart';
import 'bottom_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final Box _authBox = Hive.box('authBox');
  late Animation<double> _fadeAnim;
  late AnimationController _controller;
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
 SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

        _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

        _animationController = AnimationController(vsync: this);

    Future.delayed(Duration(seconds: 2), () {
 
      _controller.forward().then((_) {

        if (_authBox.get('token') != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigation()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.primaryThemeColor,
                AppColor.secondaryThemeColor2,
              ],
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/image/DDLOGO.png',
              height: 60,
            ),
          ),
        ),
      ),
    );
  }
}
