import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/screens/clockin_screen.dart';
import 'package:hrms/presentation/screens/dashboard_screen.dart';
import 'package:hrms/presentation/screens/leave_screen_employee.dart';
import 'package:hrms/presentation/screens/leave_screen_manager.dart';
import 'package:hrms/presentation/screens/profile_screen.dart';
import 'package:hrms/presentation/screens/team_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  String? role;
  String? empID;

  @override
  void initState() {
    super.initState();
    checkEmployeeId();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> checkEmployeeId() async {
    var box = await Hive.openBox('authBox');
    setState(() {
      role = box.get('role');
      empID = box.get('employeeId');
      print(role);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      body: role == 'Manager' || role == 'Super-Admin'
          ? <Widget>[
              DashboardScreen(empID!),
              LeaveScreenManager(empID!),
              ClockInScreenSecond(empID!),
              TeamScreen(),
              ProfileScreen(empID!)
            ][_selectedIndex]
          : <Widget>[
              DashboardScreen(empID!),
              LeaveScreenEmployee(empID!),
              ClockInScreenSecond(empID!),
              ProfileScreen(empID!),
            ][_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.mainFGColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
        ),
        padding: const EdgeInsets.only(bottom: 30, top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            (role == 'Manager' || role == 'Super-Admin') ? 5 : 4,
            (index) {
              final isSelected = _selectedIndex == index;

              final icons = role == 'Manager' || role == 'Super-Admin'
                  ? [
                      CupertinoIcons.house_fill,
                      CupertinoIcons.timelapse,
                      CupertinoIcons.timer_fill,
                      CupertinoIcons.person_2_fill,
                      CupertinoIcons.person_crop_circle_fill
                    ]
                  : [
                      CupertinoIcons.house_fill,
                      CupertinoIcons.timelapse,
                      CupertinoIcons.timer_fill,
                      CupertinoIcons.person_crop_circle_fill
                    ];

              final labels = role == 'Manager' || role == 'Super-Admin'
                  ? ['Dashboard', 'Leave', 'Attendence', 'Team', 'Profile']
                  : ['Dashboard', 'Leave', 'Attendence', 'Profile'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: isSelected
    ? Column(
        key: ValueKey('label_$index'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labels[index],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColor.mainThemeColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: AppColor.mainThemeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      )
    : Icon(
        icons[index],
        key: ValueKey('icon_$index'),
        color: const Color.fromARGB(255, 179, 179, 179),
        size: 25,
      ),

                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
