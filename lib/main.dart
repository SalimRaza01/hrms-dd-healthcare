import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/provider/provider.dart';
import 'package:hrms/core/services.dart/background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/new_onbaording.dart';
import 'package:wiredash/wiredash.dart';
import 'presentation/odoo/odoo_dashboard.dart';
import 'presentation/odoo/view_projects.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/authentication/otp_screen.dart';
import 'presentation/authentication/login_screen.dart';
import 'presentation/authentication/create_new_pass.dart';
import 'presentation/odoo/create_task.dart';
import 'presentation/odoo/task_details.dart';
import 'presentation/screens/apply_leave.dart';
import 'presentation/screens/bottom_navigation.dart';
import 'presentation/screens/attendance_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/holiday_list.dart';
import 'presentation/screens/leave_screen_manager.dart';
import 'presentation/screens/notification_screen.dart';
import 'presentation/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('trackingBox');
  await requestPermissions();
  await initializeNotifications();
  await initializeService();


   runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => LeaveApplied()),
        ChangeNotifierProvider(create: (_) => PunchedIN()),
        ChangeNotifierProvider(create: (_) => PunchHistoryProvider()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> requestPermissions() async {
  await [
    Permission.location,
    Permission.locationAlways,
    Permission.notification,         // For Android 13+   // Required for Android 14+
  ].request();
}


Future<void> initializeNotifications() async {
  const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
  const iosSettings = DarwinInitializationSettings();

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await plugin.initialize(initSettings);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: 'hrms-obpnfi3',
      secret: 'QImrYzABXucoW8hFSIpoH52KRg2dLywl',
      child: MaterialApp(
        themeMode: ThemeMode.light,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
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
          "/createTask": (context) => CreateTask(projectID: 0),
          "/taskDetails": (context) => TaskDetails(taskID: 0),
          "/viewProject": (context) => ViewProjects(
                projectName: '',
                projectID: 0,
                createDate: '',
                alreadyAssignedEmails: [],
              ),
        },
      ),
    );
  }
}
