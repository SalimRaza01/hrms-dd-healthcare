
import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/screens/home/clockin_screen%20copy.dart';
import 'package:database_app/presentation/screens/home/dashboard_screen.dart';
import 'package:database_app/presentation/screens/home/leave_screen%20copy.dart';
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
      backgroundColor: AppColor.mainBGColor,
      bottomNavigationBar: ClipRRect(
         borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30), 
          topRight: Radius.circular(30),
        ),
        child: NavigationBar(
          shadowColor:Colors.transparent,
           
          backgroundColor: Colors.white,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          
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
      ),
      body: <Widget>[
        DashboardScreen(),
        LeaveScreenSecond(),
        ClockInScreenSecond(),
        ProfileScreen()
      ][currentPageIndex],
    );
  }
}
