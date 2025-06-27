// ignore_for_file: unused_field

import 'package:flutter/services.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/presentation/authentication/login_screen.dart';
import 'package:hrms/presentation/screens/new_onbaording.dart';
import 'bottom_navigation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _animationController = AnimationController(vsync: this);

    Future.delayed(Duration(seconds: 2), () {
      _controller.forward().then((_) {
        checkNavigation();
      });
    });
  }

  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print('Invalid token or error decoding: $e');
      return true;
    }
  }

  void checkNavigation() {
    bool isFirstInstall = _authBox.get('FreshInstall') ?? true;
    String? token = _authBox.get('token');

    if (!isFirstInstall) {
      if (token != null) {
        if (isTokenExpired(token)) {
          navigateToLogin();
        } else {
          navigateToHome();
        }
      } else {
        navigateToLogin();
      }
    } else {
      navigateToOnboarding();
    }
  }

  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNavigation()),
    );
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                    SizedBox(height: height * 0.2,),
                Image.asset(
                  'assets/image/DDHRMS.png',
                  height: 100,
                ),
                SizedBox(height: height * 0.1,),
                Column(
                  children: [
                    Text(
                      "POWERED BY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.012,
                      ),
                    ),
                    Text(
                      "D&D Healthcare",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.02,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
