// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:hrms/core/theme/app_colors.dart';
// import 'package:hrms/presentation/screens/leave_screen_employee.dart';
// import 'package:hrms/presentation/screens/team_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'clockin_screen.dart';
// import 'dashboard_screen.dart';
// import 'leave_screen_manager.dart';
// import 'profile_screen.dart';

// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});

//   @override
//   State<BottomNavigation> createState() => _BottomNavigationState();
// }

// class _BottomNavigationState extends State<BottomNavigation> {
//   int currentPageIndex = 0;
//   String? role;
//   String? empID;

//   @override
//   void initState() {
//     super.initState();
//     checkEmployeeId();
//      SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//   }

//   Future<void> checkEmployeeId() async {
//     var box = await Hive.openBox('authBox');
//     setState(() {
//       role = box.get('role');
//       empID = box.get('employeeId');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(

//       onPopInvoked:(didPop) {
//         // SystemNavigator.pop();
//         exit(0);
//       },
//       child: Scaffold(
//           backgroundColor: AppColor.mainBGColor,
// bottomNavigationBar: ClipRRect(
//   borderRadius: BorderRadius.only(
//     topLeft: Radius.circular(30),
//     topRight: Radius.circular(30),
//   ),
//             child: role == 'Manager'
//                 ? NavigationBar(
//                     shadowColor: Colors.transparent,
//                     backgroundColor: AppColor.mainFGColor,
//                     onDestinationSelected: (int index) {
//                       setState(() {
//                         currentPageIndex = index;
//                       });
//                     },
//                     indicatorColor: Colors.transparent,
//                     selectedIndex: currentPageIndex,
//                     destinations: <Widget>[
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/Home2.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/Home.png',
//                           height: 25,
//                         ),
//                         label: 'Home',
//                       ),
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/Leave.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/Leave2.png',
//                           height: 25,
//                         ),
//                         label: 'Leaves',
//                       ),
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/ClockIn2.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/ClockIn.png',
//                           height: 25,
//                         ),
//                         label: 'Attendance',
//                       ),
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/TeamScreen2.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/TeamScreen.png',
//                           height: 25,
//                         ),
//                         label: 'Team',
//                       ),
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/Profile.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/Profile2.png',
//                           height: 25,
//                         ),
//                         label: 'Profile',
//                       ),
//                     ],
//                   )
//                 : NavigationBar(
//                     shadowColor: Colors.transparent,
//                     backgroundColor: AppColor.mainFGColor,
//                     onDestinationSelected: (int index) {
//                       setState(() {
//                         currentPageIndex = index;
//                       });
//                     },
//                     indicatorColor: Colors.transparent,
//                     selectedIndex: currentPageIndex,
//                     destinations: <Widget>[
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/Home2.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/Home.png',
//                           height: 25,
//                         ),
//                         label: 'Home',
//                       ),
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/Leave.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/Leave2.png',
//                           height: 25,
//                         ),
//                         label: 'Leaves',
//                       ),
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/ClockIn2.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/ClockIn.png',
//                           height: 25,
//                         ),
//                         label: 'Attendance',
//                       ),
//                       NavigationDestination(
//                         selectedIcon: Image.asset(
//                           'assets/image/Profile.png',
//                           height: 25,
//                         ),
//                         icon: Image.asset(
//                           'assets/image/Profile2.png',
//                           height: 25,
//                         ),
//                         label: 'Profile',
//                       ),
//                     ],
//                   ),
//           ),
//           body: role == 'Manager'
//               ? <Widget>[
//                   DashboardScreen(empID!),
//                   LeaveScreenManager(empID!),
//                   ClockInScreenSecond(empID!),
//                   TeamScreen(),
//                   ProfileScreen(empID!)
//                 ][currentPageIndex]
//               : <Widget>[
//                   DashboardScreen(empID!),
//                   LeaveScreenEmployee(empID!),
//                   ClockInScreenSecond(empID!),
//                   ProfileScreen(empID!),
//                 ][currentPageIndex]),
//     );
//   }
// }







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
      bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            selectedFontSize:12.0,
            currentIndex: _selectedIndex,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            items: role == 'Manager' || role == 'Super-Admin'
                ? <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.house_fill,
                        size: 25,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.timelapse,
                        size: 25,
                      ),
                      label: 'Leave',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.timer_fill,
                        size: 25,
                      ),
                      label: 'Attendence',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.person_2_fill,
                        size: 25,
                      ),
                      label: 'Team',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.person_crop_circle_fill,
                        size: 25,
                      ),
                      label: 'Profile',
                    ),
                  ]
                : <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.house_fill,
                        size: 25,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.timelapse,
                        size: 25,
                      ),
                      label: 'Leave',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.timer_fill,
                        size: 25,
                      ),
                      label: 'Attendence',
                    ),
                    BottomNavigationBarItem(
                      backgroundColor: Colors.white,
                      icon: Icon(
                        CupertinoIcons.person_crop_circle_fill,
                        size: 25,
                      ),
                      label: 'Profile',
                    ),
                  ],
            backgroundColor: AppColor.mainFGColor,
            selectedItemColor: AppColor.mainThemeColor,
            unselectedItemColor: const Color.fromARGB(255, 179, 179, 179),
          )),
    );
  }
}
