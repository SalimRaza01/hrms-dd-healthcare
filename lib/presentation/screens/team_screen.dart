import 'package:flutter/services.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import '../../core/theme/app_colors.dart';
import 'team_clockin_screen.dart';
import 'team_profile.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    employeeProfiles = fetchTeamList();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.mainBGColor,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.newgredient1,
                const Color.fromARGB(52, 124, 157, 174),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 15.0,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    ' My Team',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: height * 0.018, color: Colors.black),
                  ),
                ),
            Container(
  height: height * 0.055,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(32),
color:   const Color.fromARGB(52, 124, 157, 174),
  ),
  child: TextField(
    style: TextStyle(
      fontSize: height * 0.018,
      color: AppColor.mainTextColor2,
    ),
    onChanged: (value) {
      setState(() {
        searchQuery = value;
      });
    },
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: Icon(Icons.search, color: AppColor.mainTextColor2),
      hintText: 'Search Employee',
      hintStyle: TextStyle(
        color: AppColor.mainTextColor2,
        fontSize: height * 0.017,
      ),
      border: InputBorder.none,
    ),
  ),
),

                Expanded(
                  child: FutureBuilder<List<EmployeeProfile>>(
                      future: employeeProfiles,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: AppColor.mainTextColor2,
                              size: height * 0.03,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text('No Data Found'));
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
                                    color: AppColor.mainFGColor,
                                    elevation: 0,
                                    margin: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Column(
                                        children: [
                                          // Header
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                      const Color(0xFF8CD193),
                                              child: Text(
                                                employee.employeeName[0],
                                                style: TextStyle(
                                                  fontSize: height * 0.022,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColor.mainTextColor
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              employee.employeeName,
                                              style: TextStyle(
                                                fontSize: height * 0.019,
                                                color: AppColor.mainTextColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              employee.designation,
                                              style: TextStyle(
                                                  fontSize: height * 0.013,
                                                  color:
                                                      AppColor.mainTextColor2),
                                            ),
                                          ),
                                          AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 300),
                                            height: employee.isExpanded
                                                ? height * 0.12
                                                : 0,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                spacing: 3.0,
                                                children: [
                                                  FutureBuilder<LeaveBalance>(
                                                      future: fetchLeaves(),
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
                                                                  'No Data Found'));
                                                        } else if (snapshot
                                                            .hasData) {
                                                          final leave =
                                                              snapshot.data!;

                                                          return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              leaveWidget(
                                                                  height,
                                                                  width,
                                                                  'Casual',
                                                                  leave
                                                                      .casualLeave),
                                                              leaveWidget(
                                                                  height,
                                                                  width,
                                                                  'Medical',
                                                                  leave
                                                                      .medicalLeave),
                                                              leaveWidget(
                                                                  height,
                                                                  width,
                                                                  'Earned',
                                                                  leave
                                                                      .earnedLeave),
                                                            ],
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
                                                        barrierColor: AppColor
                                                            .mainTextColor2,
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
                                                        color: AppColor
                                                            .mainFGColor,
                                                      ),
                                                      width: width,
                                                      height: height * 0.04,
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
                                                        barrierColor: AppColor
                                                            .mainTextColor2,
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
                                                      height: height * 0.04,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        28),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            28)),
                                                        color: AppColor
                                                            .mainFGColor,
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
                                  height: height * 0.01,
                                );
                              },
                            ),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  leaveWidget(double height, double width, String leave, String leaveCount) {
    return Container(
      width: width / 3.5,
      decoration: BoxDecoration(
          color: const Color(0xFF40738D),
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              leave,
              style: TextStyle(
                  color: AppColor.mainFGColor, fontSize: height * 0.013),
            ),
            Text(
              '-',
              style: TextStyle(
                  color: AppColor.mainFGColor, fontSize: height * 0.013),
            ),
            Text(
              leaveCount,
              style: TextStyle(
                  color: AppColor.mainFGColor, fontSize: height * 0.015),
            ),
          ],
        ),
      ),
    );
  }
}
