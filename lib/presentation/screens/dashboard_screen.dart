// ignore_for_file: sort_child_properties_last, prefer_final_fields

import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/presentation/odoo/odoo_dashboard.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

import 'holiday_list.dart';
import 'notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String empID;
  const DashboardScreen(this.empID);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<HolidayModel>> holidayList;
  late Future<List<EmployeeOnLeave>> employeeOnLeaveList;
  late String? empID;
  String? empName;
  String? empDesign;
  String? empGender;
  DateTime today = DateTime.now();



  @override
  void initState() {
    super.initState();
    checkEmployeeId();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    holidayList = fetchHolidayList();
    employeeOnLeaveList = fetchEmployeeOnLeave();
  }

  Future<void> checkEmployeeId() async {
    var box = await Hive.openBox('authBox');
    setState(() {
      empDesign = box.get('employeeDesign');
      empName = box.get('employeeName');
      empGender = box.get('gender');
      print(box.get('token'));
    });

    print('Stored Employee ID: $empName');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.mainFGColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: CircleAvatar(
              child: Image.asset(
                empGender == 'Male'
                    ? 'assets/image/MaleAvatar.png'
                    : 'assets/image/FemaleAvatar.png',
                height: height * 0.045,
              ),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                empName != null ? empName! : '',
                style: TextStyle(
                    fontSize: height * 0.017,
                    color: AppColor.mainTextColor,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                empDesign != null ? empDesign! : '',
                style: TextStyle(
                  fontSize: height * 0.013,
                  color: AppColor.mainTextColor2,
                ),
              )
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()));
              },
              icon: Icon(
                Icons.notifications_rounded,
                color: AppColor.mainThemeColor,
                size: height * 0.035,
              ),
            ),
          ],
        ),
        backgroundColor: AppColor.mainBGColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    FutureBuilder<ShiftTimeModel>(
                        future: fetchShiftTime(widget.empID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _shimmerEffectshiftTime(height, width);
                          } else if (snapshot.hasError) {
                            return Card(
                              color: AppColor.mainFGColor,
                              elevation: 4,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: Text('No Data Found')),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final shift = snapshot.data!;

                            return Card(
                                color: AppColor.mainFGColor,
                                elevation: 4,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadowColor: Colors.black.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Shift Time',
                                        style: TextStyle(
                                            fontSize: height * 0.015,
                                            color: AppColor.mainTextColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${shift.startTime} AM ',
                                            style: TextStyle(
                                              fontSize: height * 0.015,
                                              color:
                                                  Color.fromARGB(141, 0, 0, 0),
                                            ),
                                          ),
                                          Text(
                                            '- ',
                                            style: TextStyle(
                                              fontSize: height * 0.015,
                                              color:
                                                  Color.fromARGB(141, 0, 0, 0),
                                            ),
                                          ),
                                          Text(
                                            '${shift.endTime} PM',
                                            style: TextStyle(
                                              fontSize: height * 0.015,
                                              color:
                                                  Color.fromARGB(141, 0, 0, 0),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ));
                          } else {
                            return Text('No data Found');
                          }
                        }),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OdooDashboard()));
                      },
                      child: Container(
                          width: width,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColor.primaryThemeColor,
                                  AppColor.mainThemeColor,
                                ],
                              ),
                              border: Border.all(
                                  color: const Color.fromARGB(14, 0, 0, 0)),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_outlined,
                                      color: AppColor.mainFGColor,
                                      size: height * 0.022,
                                    ),
                                    SizedBox(
                                      width: width * 0.02,
                                    ),
                                    Text(
                                      'View Task Dashbaord',
                                      style: TextStyle(
                                          fontSize: height * 0.015,
                                          color: AppColor.mainFGColor,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: AppColor.mainFGColor,
                                  size: height * 0.018,
                                ),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Card(
                      color: AppColor.mainFGColor,
                      elevation: 4,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: CalendarTimeline(
                          height: height * 0.075,
                          dayNameFontSize: 10,
                          fontSize: 18,
                          showYears: false,
                          initialDate: today,
                          firstDate: today.subtract(Duration(days: 30)),
                          lastDate: today.add(Duration(days: 30)),
                          onDateSelected: (date) => print(date),
                          leftMargin: 0,
                          monthColor: Colors.blueGrey,
                          dayColor: Colors.blueGrey,
                          activeDayColor: Colors.amberAccent,
                          activeBackgroundDayColor: AppColor.mainThemeColor,
                          locale: 'en_ISO',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    SizedBox(
                      width: width,
                      child: Card(
                        color: AppColor.mainFGColor,
                        elevation: 4,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'On Leave Today',
                              style: TextStyle(
                                    fontSize: height * 0.015,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              FutureBuilder<List<EmployeeOnLeave>>(
                                  future: employeeOnLeaveList,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('No Employee is On Leave'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                          child:
                                              Text('No Employee is On Leave'));
                                    } else {
                                      List<EmployeeOnLeave> items =
                                          snapshot.data!;

                                      return SizedBox(
                                        width: width,
                                        height: height * 0.07,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            final item = items[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 235, 244, 254),
                                                    child: Text(
                                                      item.employeeName[0],
                                                      style: TextStyle(
                                                        fontSize: height * 0.018,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.002,
                                                  ),
                                                  Text(
                                                    '${item.employeeName.substring(0, item.employeeName.indexOf(' '))} ',
                                                    style: TextStyle(
                                                        fontSize:
                                                            height * 0.013,
                                                        color: AppColor
                                                            .mainTextColor,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  })
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    SizedBox(
                      width: width,
                      child: Card(
                        color: AppColor.mainFGColor,
                        elevation: 4,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Leave Balance',
                                style: TextStyle(
                                    fontSize: height * 0.015,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              FutureBuilder<LeaveBalance>(
                                  future: fetchLeaves(widget.empID),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _shimmerEffectForLeaveBalance(
                                          height, width);
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('No Data Found'));
                                    } else if (snapshot.hasData) {
                                      final leave = snapshot.data!;

                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            leaveWidget(height, width, 'Casual',
                                                leave.casualLeave),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            leaveWidget(height, width,
                                                'Medical', leave.medicalLeave),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            leaveWidget(height, width, 'Earned',
                                                leave.earnedLeave),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            leaveWidget(
                                                height,
                                                width,
                                                'Maternity',
                                                leave.maternityLeave),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            leaveWidget(
                                                height,
                                                width,
                                                'Paternity',
                                                leave.paternityLeave),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Text('No data Found');
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Card(
                      color: AppColor.mainFGColor,
                      elevation: 4,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upcoming Holiday',
                           style: TextStyle(
                                    fontSize: height * 0.015,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            FutureBuilder<List<HolidayModel>>(
                              future: holidayList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('No Holiday List Found'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text('No Holiday available.'));
                                } else {
                                  List<HolidayModel> items = snapshot.data!;

                                  HolidayModel item = items[0];

                                  final newDate =
                                      DateTime.parse(item.holidayDate);

                                  print(newDate.day < DateTime.now().day);

                                  return InkWell(
                                    onTap: () => showCupertinoModalBottomSheet(
                                      expand: true,
                                      context: context,
                                      barrierColor:
                                          const Color.fromARGB(130, 0, 0, 0),
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => HolidayList(),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColor.mainThemeColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 4,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      DateFormat('dd')
                                                          .format(newDate)
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: height * 0.02,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor.mainFGColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('EEE')
                                                          .format(newDate)
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.014,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColor.mainFGColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 20),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: width / 2,
                                                    child: Text(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      item.holidayName,
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.015,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColor
                                                              .mainTextColor),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Text(
                                                    DateFormat('MMMM')
                                                        .format(newDate)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize:
                                                            height * 0.014,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor
                                                            .mainTextColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColor.mainTextColor,
                                        )
                                      ],
                                    ),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Card(
                      color: AppColor.mainFGColor,
                      elevation: 4,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today Task',
                           style: TextStyle(
                                    fontSize: height * 0.015,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: height * 0.005,
                            ),
                            Text(
                              'The tasks assigned to you for today',
                              style: TextStyle(
                                fontSize: height * 0.012,
                                color: AppColor.mainTextColor2,
                              ),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Center(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.asset(
                                      'assets/image/Frame.png',
                                      height: height * 0.08,
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Center(
                              child: Text(
                                'No Tasks Assigned',
                                style: TextStyle(
                                    fontSize: height * 0.015,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Text(
                              'It looks like you don’t have any tasks assigned to you right now. Don’t worry, this space will be updated as new tasks become available.',
                              style: TextStyle(
                                fontSize: height * 0.012,
                                color: AppColor.mainTextColor2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Card(
                    //   color: AppColor.mainFGColor,
                    //   elevation: 4,
                    //   margin: EdgeInsets.all(0),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    //   shadowColor: Colors.black.withOpacity(0.1),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(10),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           'Today Task ',
                    //           style: TextStyle(
                    //               fontSize: height * 0.018,
                    //               color: AppColor.mainTextColor,
                    //               fontWeight: FontWeight.w500),
                    //         ),
                    //         SizedBox(
                    //           height: 3,
                    //         ),
                    //         Text(
                    //           'The tasks assigned to you for today',
                    //           style: TextStyle(
                    //             fontSize: height * 0.015,
                    //             color: Color.fromARGB(141, 0, 0, 0),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: height * 0.01,
                    //         ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       border: Border.all(
                    //           color: const Color.fromARGB(14, 0, 0, 0)),
                    //       color: AppColor.mainBGColor,
                    //       borderRadius: BorderRadius.circular(10)),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 10, vertical: 12),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             Icon(
                    // Icons.circle_outlined,
                    // color: AppColor.primaryThemeColor,
                    // size: height * 0.022,
                    //             ),
                    //             SizedBox(
                    //               width: 5,
                    //             ),
                    //             Text(
                    //               'Complete HRMS UI',
                    //               style: TextStyle(
                    //                   fontSize: height * 0.018,
                    //                   color: AppColor.mainTextColor,
                    //                   fontWeight: FontWeight.w500),
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(
                    //           height: height * 0.015,
                    //         ),
                    //         Row(
                    //           crossAxisAlignment:
                    //               CrossAxisAlignment.start,
                    //           children: [
                    //             TaskWidgets(
                    //               height: height,
                    //               icon: Icons.timelapse_rounded,
                    //               text: 'In Progress',
                    //               color: const Color.fromARGB(
                    //                   86, 158, 158, 158),
                    //               textcolor: const Color.fromARGB(
                    //                   158, 0, 0, 0),
                    //             ),
                    //             SizedBox(
                    //               width: 10,
                    //             ),
                    //             TaskWidgets(
                    //               height: height,
                    //               icon: Icons.flag,
                    //               text: 'High',
                    //               color: const Color.fromARGB(
                    //                   201, 229, 27, 27),
                    //               textcolor: const Color.fromARGB(
                    //                   255, 255, 255, 255),
                    //             ),
                    //             SizedBox(
                    //               width: 10,
                    //             ),
                    //             TaskWidgets(
                    //               height: height,
                    //               icon: Icons.calendar_month,
                    //               text: '5 Dec',
                    //               color: const Color.fromARGB(
                    //                   201, 229, 27, 27),
                    //               textcolor: const Color.fromARGB(
                    //                   255, 255, 255, 255),
                    //             )
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Card(
                      color: AppColor.mainFGColor,
                      elevation: 4,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Announcement',
                           style: TextStyle(
                                    fontSize: height * 0.015,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: height * 0.005,
                            ),
                            Image.asset(
                                fit: BoxFit.fitWidth,
                                width: width,
                                'assets/image/annoucementImage.png'),
                            SizedBox(
                              height: height * 0.005,
                            ),
                            Text(
                              'No announcements have been published yet. Keep an eye out for future updates.',
                              style: TextStyle(
                                fontSize: height * 0.012,
                                color: Color.fromARGB(141, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _shimmerEffectForLeaveBalance(double height, double width) {
    return SizedBox(
      height: height * 0.1,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              height: height * 0.15,
              color: AppColor.mainFGColor,
              width: width * 0.2,
              margin: EdgeInsets.symmetric(horizontal: 5),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 10),
        ),
      ),
    );
  }

  SizedBox _shimmerEffectshiftTime(double height, double width) {
    return SizedBox(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          color: AppColor.mainFGColor,
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '      ',
                    style: TextStyle(
                      fontSize: height * 0.02,
                      color: Color.fromARGB(141, 0, 0, 0),
                    ),
                  ),
                  Text(
                    '  -  ',
                    style: TextStyle(
                      fontSize: height * 0.02,
                      color: Color.fromARGB(141, 0, 0, 0),
                    ),
                  ),
                  Text(
                    '           ',
                    style: TextStyle(
                      fontSize: height * 0.02,
                      color: Color.fromARGB(141, 0, 0, 0),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  SizedBox leaveWidget(
      double height, double width, String leave, String leaveCount) {
    return SizedBox(
      width: width * 0.22,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(14, 0, 0, 0)),
            color: AppColor.mainBGColor,
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
          child: Column(
            children: [
              Text(
                leave,
                style: TextStyle(color: AppColor.mainTextColor2),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                leaveCount,
                style: TextStyle(
                    color: Color.fromARGB(141, 0, 0, 0),
                    fontSize: height * 0.022),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskWidgets extends StatelessWidget {
  TaskWidgets(
      {super.key,
      required this.height,
      required this.icon,
      required this.text,
      required this.color,
      required this.textcolor});

  final double height;
  final IconData icon;
  final String text;
  final Color color;
  final Color textcolor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(50)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: height * 0.02,
              color: textcolor,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              text,
              style: TextStyle(color: textcolor),
            )
          ],
        ),
      ),
    );
  }
}
