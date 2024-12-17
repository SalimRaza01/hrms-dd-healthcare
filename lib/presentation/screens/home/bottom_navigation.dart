
// ignore_for_file: prefer_const_constructors

import 'package:database_app/presentation/screens/home/clockin_screen.dart';
import 'package:database_app/presentation/screens/home/dashboard_screen.dart';
import 'package:database_app/presentation/screens/home/leave_screen.dart';
import 'package:database_app/presentation/screens/home/profile_screen.dart';

import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {


  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentPageIndex = 0;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        // indicatorColor: AppColor.mainThemeColor,
        indicatorColor: Colors.transparent,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Image.asset(
              'assets/image/Home2.png',
              height: 25,
            ),
            icon: Image.asset(
              'assets/image/Home.png',
              height: 25,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              'assets/image/Leave.png',
              height: 25,
            ),
            icon: Image.asset(
              'assets/image/Leave2.png',
              height: 25,
            ),
            label: 'Leaves',
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              'assets/image/ClockIn2.png',
              height: 25,
            ),
            icon: Image.asset(
              'assets/image/ClockIn.png',
              height: 25,
            ),
            label: 'Clock-In',
          ),
          NavigationDestination(
            selectedIcon: Image.asset(
              'assets/image/Profile.png',
              height: 25,
            ),
            icon: Image.asset(
              'assets/image/Profile2.png',
              height: 25,
            ),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        DashboardScreen(),
        LeaveScreen(),
        ClockInScreen(),
        ProfileScreen()
      ][currentPageIndex],
    );
  }
}