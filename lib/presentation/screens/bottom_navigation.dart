import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'leave_screen_employee.dart';
import 'leave_screen_manager.dart';
import 'profile_screen.dart';
import 'team_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;
  String? role;
  String? empID;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    checkEmployeeId();
  }

  Future<void> checkEmployeeId() async {
    var box = await Hive.openBox('authBox');
    setState(() {
      role = box.get('role');
      empID = box.get('employeeId');
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (role == null || empID == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    final isManager = role == 'Manager' || role == 'Super-Admin';

    final List<Widget> pages = isManager
        ? [
            DashboardScreen(empID!),
            LeaveScreenManager(empID!),
            ClockInScreenSecond(empID!),
            TeamScreen(),
            ProfileScreen(empID!)
          ]
        : [
            DashboardScreen(empID!),
            LeaveScreenEmployee(empID!),
            ClockInScreenSecond(empID!),
            ProfileScreen(empID!)
          ];

    final List<String> icons = isManager
        ? [
            'assets/image/home.svg',
            'assets/image/leave.svg',
            'assets/image/attendance.svg',
            'assets/image/team.svg',
            'assets/image/profile.svg'
          ]
        : [
            'assets/image/home.svg',
            'assets/image/leave.svg',
            'assets/image/attendance.svg',
            'assets/image/profile.svg'
          ];

    final List<String> labels = isManager
        ? ['Dashboard', 'Leave', 'Attendance', 'Team', 'Profile']
        : ['Dashboard', 'Leave', 'Attendance', 'Profile'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          pages[_currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(icons.length, (index) {
                      return _buildNavItem(icons[index], labels[index], index, width);
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String icon, String label, int index, double width) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(
          begin: isSelected ? 1.0 : 0.95,
          end: isSelected ? 1.15 : 1.0,
        ),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: width * 0.10,
              height: width * 0.10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF8CD193) : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  color: isSelected ? Colors.white : Colors.white54,
                  height: isSelected ? 22 : 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
