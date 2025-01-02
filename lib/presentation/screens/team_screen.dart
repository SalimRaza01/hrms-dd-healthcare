import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/screens/team_clockin_screen.dart';
import 'package:hrms/presentation/screens/team_profile.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TeamScreen extends StatefulWidget {
  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late Future<List<EmployeeProfile>> employeeProfiles;

  String searchQuery = "";
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    employeeProfiles = fetchTeamList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.mainBGColor,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              height: height * 0.25,
              width: width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.primaryThemeColor,
                    AppColor.secondaryThemeColor2,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, 10),
                  )
                ],
                color: AppColor.mainThemeColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Team',
                              style: TextStyle(
                                  fontSize: height * 0.025,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Text(
                              'Know Everything About Your Team',
                              style: TextStyle(
                                fontSize: height * 0.018,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/image/team.png',
                        height: height * 0.1,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  // Search Field
                  Container(
                    height: height * 0.05,
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 212, 212, 212),
                          Color.fromARGB(255, 244, 244, 244)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.4],
                        tileMode: TileMode.clamp,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                    child: TextField(
                      expands: false,
                      style: TextStyle(fontSize: 20.0, color: Colors.black54),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        hintText: 'Search Employee',
                        hintStyle: TextStyle(
                            color: Colors.black54, fontSize: height * 0.02),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Employee List
                  FutureBuilder<List<EmployeeProfile>>(
                      future: employeeProfiles,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: Text('Loading'));
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Please check your internet connection, try again'));
                        } else if (!snapshot.hasData) {
                          return Center(child: Text('No data found'));
                        } else {
                          final employees = snapshot.data!;
                          final filteredEmployees = employees
                              .where((employee) => employee.employeeName
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                              .toList();

                          return Expanded(
                            child: ListView.separated(
                              itemCount: filteredEmployees.length,
                              itemBuilder: (context, index) {
                                final employee = filteredEmployees[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      employee.isExpanded =
                                          !employee.isExpanded;
                                    });
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 5,
                                    margin: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Column(
                                        children: [
                                          // Header
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 235, 244, 254),
                                              child: Text(
                                                employee.employeeName[0],
                                                style: TextStyle(
                                                  fontSize: height * 0.022,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              employee.employeeName,
                                              style: TextStyle(
                                                fontSize: height * 0.019,
                                                color: AppColor.mainTextColor2,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              employee.designation,
                                              style: TextStyle(
                                                  fontSize: height * 0.013,
                                                  color: Colors.grey.shade600),
                                            ),
                                          ),
                                          AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 300),
                                            height: employee.isExpanded
                                                ? height * 0.12
                                                : 0,
                                            child: SingleChildScrollView(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              child: Column(
                                                spacing: 2.0,
                                                children: [
                                                  FutureBuilder<LeaveBalance>(
                                                      future: fetchLeaves(
                                                          employee.employeeId),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return SizedBox();
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Center(
                                                              child: Text(
                                                                  'Please check your internect connection'));
                                                        } else if (snapshot
                                                            .hasData) {
                                                          final leave =
                                                              snapshot.data!;

                                                          return SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                leaveWidget(
                                                                    height,
                                                                    width,
                                                                    'Casual',
                                                                    leave
                                                                        .casualLeave),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                leaveWidget(
                                                                    height,
                                                                    width,
                                                                    'Medical',
                                                                    leave
                                                                        .medicalLeave),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                leaveWidget(
                                                                    height,
                                                                    width,
                                                                    'Earned',
                                                                    leave
                                                                        .earnedLeave),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                leaveWidget(
                                                                    height,
                                                                    width,
                                                                    'Maternity',
                                                                    leave
                                                                        .maternityLeave),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                leaveWidget(
                                                                    height,
                                                                    width,
                                                                    'Paternity',
                                                                    leave
                                                                        .paternityLeave),
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                              'No data Found');
                                                        }
                                                      }),
                                                  InkWell(
                                                    onTap: () {
                                                      showCupertinoModalBottomSheet(
                                                        expand: true,
                                                        context: context,
                                                        barrierColor:
                                                            const Color
                                                                .fromARGB(
                                                                130, 0, 0, 0),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (context) =>
                                                            TeamProfile(employee
                                                                .employeeId),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        0)),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 235, 244, 254),
                                                      ),
                                                      width: width,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'Profile',
                                                          style: TextStyle(
                                                              fontSize: height *
                                                                  0.015,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      showCupertinoModalBottomSheet(
                                                        expand: true,
                                                        context: context,
                                                        barrierColor:
                                                            const Color
                                                                .fromARGB(
                                                                130, 0, 0, 0),
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (context) =>
                                                            TeamClockinScreen(
                                                                employee
                                                                    .employeeId),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: width,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        15),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            15)),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 235, 244, 254),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'Attendance',
                                                          style: TextStyle(
                                                              fontSize: height *
                                                                  0.015,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: 10,
                                );
                              },
                            ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  leaveWidget(double height, double width, String leave, String leaveCount) {
    return Container(
      decoration: BoxDecoration(
          color: AppColor.primaryThemeColor,
          borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          children: [
            Text(
              '${leave} - ',
              style: TextStyle(color: Colors.white, fontSize: height * 0.013),
            ),
            Text(
              leaveCount,
              style: TextStyle(color: Colors.white, fontSize: height * 0.015),
            ),
          ],
        ),
      ),
    );
  }
}
