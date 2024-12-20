
import 'package:database_app/presentation/screens/punch_in_out_screen.dart';

import 'core/api/api.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'presentation/authentication/login_otp.dart';
import 'presentation/authentication/login_screen.dart';
import 'presentation/authentication/login_with_phone.dart';
import 'presentation/screens/OnBoarding.dart';
import 'presentation/screens/apply_leave.dart';
import 'presentation/screens/bottom_navigation.dart';
import 'presentation/screens/clockin_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/holiday_list.dart';
import 'presentation/screens/leave_screen.dart';
import 'presentation/screens/notification_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/splash_screen.dart';

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
        "/BottomNavigation": (context) => BottomNavigation(),
        "/home": (context) => DashboardScreen(),
        "/applyLeave": (context) => ApplyLeave(),
        "/profileScreen": (context) => ProfileScreen(),
        "/clockSecondScreen": (context) => ClockInScreenSecond(),
        "/leaveSecondScreen": (context) => LeaveScreenSecond(),
             "/holidayList": (context) => HolidayList(),
                 "/notificationScreen": (context) => NotificationScreen(),
                    "/punchinout": (context) => PunchInOutScreen()
      },
    );
  }
}
