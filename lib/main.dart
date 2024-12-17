import 'package:database_app/core/api/api.dart';
import 'package:database_app/presentation/screens/authentication/login_otp.dart';
import 'package:database_app/presentation/screens/authentication/login_screen.dart';
import 'package:database_app/presentation/screens/authentication/login_with_phone.dart';
import 'package:database_app/presentation/screens/authentication/splash_screen.dart';
import 'package:database_app/presentation/screens/home/OnBoarding.dart';
import 'package:database_app/presentation/screens/home/apply_leave.dart';
import 'package:database_app/presentation/screens/home/clockin_screen%20copy.dart';
import 'package:database_app/presentation/screens/home/dashboard_screen.dart';
import 'package:database_app/presentation/screens/home/leave_screen%20copy.dart';
import 'package:database_app/presentation/screens/home/leave_screen.dart';
import 'package:database_app/presentation/screens/home/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/home/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      initialRoute: "/SplashScreen",
      routes: {
        "/SplashScreen": (context) => SplashScreen(),
        "/OnBoarding": (context) => OnboardingScreen(),
        "/Login": (context) => const LoginScreen(),
        "/LoginWithPhone": (context) => LoginWithPhone(),
        "/OTP": (context) => LoginOtp(),
        "/Leave": (context) => LeaveScreen(),
        "/BottomNavigation": (context) => BottomNavigation(),
        "/home": (context) => DashboardScreen(),
        "/applyLeave": (context) => ApplyLeave(),
        "/profileScreen": (context) => ProfileScreen(),
                "/clockSecondScreen": (context) => ClockInScreenSecond(),
        "/leaveSecondScreen": (context) => LeaveScreenSecond()
      },
    );
  }
}
