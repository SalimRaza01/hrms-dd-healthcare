import 'package:hrms/core/provider/provider.dart';
import 'package:hrms/presentation/odoo/odoo_dashboard.dart';
import 'package:hrms/presentation/odoo/view_projects.dart';
import 'package:hrms/presentation/screens/splash_screen.dart';
import 'core/api/api.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'presentation/authentication/otp_screen.dart';
import 'presentation/authentication/login_screen.dart';
import 'presentation/authentication/create_new_pass.dart';
import 'presentation/odoo/create_task.dart';
import 'presentation/odoo/task_details.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/apply_leave.dart';
import 'presentation/screens/bottom_navigation.dart';
import 'presentation/screens/clockin_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/holiday_list.dart';
import 'presentation/screens/leave_screen_manager.dart';
import 'presentation/screens/notification_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
     
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
         ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => ProjectProvider()),
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
        "/CreateNewPassword": (context) => CreateNewPassword(''),
        "/OTP": (context) => OTPScren(""),
        "/BottomNavigation": (context) => BottomNavigation(),
        "/home": (context) => DashboardScreen(''),
        "/applyLeave": (context) => ApplyLeave(),
        "/profileScreen": (context) => ProfileScreen(''),
        "/clockSecondScreen": (context) => ClockInScreenSecond(''),
        "/leaveSecondScreen": (context) => LeaveScreenManager(''),
        "/holidayList": (context) => HolidayList(),
        "/notificationScreen": (context) => NotificationScreen(),
        "/odooDashbaord": (context) => OdooDashboard(),
        "/createTask": (context) => CreateTask(projectID: 0,),
        "/taskDetails": (context) => TaskDetails(taskID: 0,),
                "/viewProject": (context) => ViewProjects(projectName: '', projectID: 0,),
      },
    );
  }
}
