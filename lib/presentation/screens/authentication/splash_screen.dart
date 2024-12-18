import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/screens/home/OnBoarding.dart';
import 'package:database_app/presentation/screens/home/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Box _authBox = Hive.box('authBox');

  @override
  void initState() {
    super.initState();

 
    Future.delayed(Duration(seconds: 2), () {
      final token = _authBox.get('token'); 


      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigation()), 
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    });
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
    );
  }
}
