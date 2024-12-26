// ignore_for_file: sort_child_properties_last

import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/model/models.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

import 'holiday_list.dart';
import 'notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<HolidayModel>> holidayList;
  String? empName;
  String? empDesign;
  String? empGender;

  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    checkEmployeeId();
    holidayList = fetchHolidayList();
  }

  Future<void> checkEmployeeId() async {
    var box = await Hive.openBox('authBox');
    setState(() {
      empDesign = box.get('employeeDesign');
      empName = box.get('employeeName');
      empGender = box.get('gender');
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
          backgroundColor: Colors.white,

          leading: CircleAvatar(
            child: Image.asset(
              empGender == 'Male'
                  ? 'assets/image/MaleAvatar.png'
                  : 'assets/image/FemaleAvatar.png', height: height * 0.045,
            ),
      
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                empName != null ? empName! : '',
                style: TextStyle(
                    fontSize: height * 0.02,
                    color: AppColor.mainTextColor,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                empDesign != null ? empDesign! : '',
                style: TextStyle(
                    fontSize: height * 0.014,
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
                        future: fetchShiftTime(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _shimmerEffectshiftTime(height, width);
                          } else if (snapshot.hasError) {
                            return Card(
                              color: Colors.white,
                              elevation: 4,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                        'Please check your internect connection')),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final shift = snapshot.data!;

                            return Card(
                                color: Colors.white,
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
                                            fontWeight: FontWeight.bold),
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
                      height: 15,
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: CalendarTimeline(
                          height: height * 0.075,
                          dayNameFontSize: 10,
                          fontSize: 20,
                          showYears: false,
                          initialDate: today,
                          firstDate: today.subtract(Duration(days: 30)),
                          lastDate: today.add(Duration(days: 30)),
                          onDateSelected: (date) => print(date),
                          leftMargin: 0,
                          monthColor: Colors.blueGrey,
                          dayColor: Colors.blueGrey,
                          activeDayColor: Colors.white,
                          activeBackgroundDayColor: AppColor.mainThemeColor,
                          locale: 'en_ISO',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Card(
                      color: Colors.white,
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
                                  fontSize: height * 0.018,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<LeaveBalance>(
                                future: fetchLeaves(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _shimmerEffectForLeaveBalance(
                                        height, width);
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Please check your internect connection'));
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
                                          leaveWidget(height, width, 'Medical',
                                              leave.medicalLeave),
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
                                          SizedBox(
                                            width: 10,
                                          ),
                                          leaveWidget(height, width, 'CompOff',
                                              leave.compOffLeave),
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
                    SizedBox(
                      height: 15,
                    ),
                    Card(
                      color: Colors.white,
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
                                  fontSize: height * 0.018,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10,
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
                                      child: Text(
                                          'Please check your internet connection'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text('No Holiday available.'));
                                } else {
                                  List<HolidayModel> items = snapshot.data!;

                                  HolidayModel item = items[0];

                                  final newDate = DateTime.parse(item.holidayDate);


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
                                                    Radius.circular(15),
                                                  )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 8,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                   DateFormat('dd').format(newDate).toString(),
                                                      style: TextStyle(
                                                        fontSize: height * 0.02,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                            DateFormat('EEE').format(newDate).toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.014,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.holidayName,
                                                    style: TextStyle(
                                                        fontSize: height * 0.02,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor
                                                            .mainTextColor),
                                                  ),
                                                  // SizedBox(
                                                  //   height: height * 0.005,
                                                  // ),
                                                  // Text(
                                                  //   item.holidayDescription
                                                  //    ,
                                                  //   style: TextStyle(
                                                  //       fontSize:
                                                  //           height * 0.014,
                                                  //       fontWeight:
                                                  //           FontWeight.w500,
                                                  //       color: AppColor
                                                  //           .mainTextColor),
                                                  // ),
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
                      height: 15,
                    ),
                    Card(
                      color: Colors.white,
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
                              'Today Task ',
                              style: TextStyle(
                                  fontSize: height * 0.018,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'The tasks assigned to you for today',
                              style: TextStyle(
                                fontSize: height * 0.015,
                                color: Color.fromARGB(141, 0, 0, 0),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(14, 0, 0, 0)),
                                  color: AppColor.mainBGColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle_outlined,
                                          color: AppColor.primaryThemeColor,
                                          size: height * 0.022,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Complete HRMS UI',
                                          style: TextStyle(
                                              fontSize: height * 0.018,
                                              color: AppColor.mainTextColor,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TaskWidgets(
                                          height: height,
                                          icon: Icons.timelapse_rounded,
                                          text: 'In Progress',
                                          color: const Color.fromARGB(
                                              86, 158, 158, 158),
                                          textcolor: const Color.fromARGB(
                                              158, 0, 0, 0),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        TaskWidgets(
                                          height: height,
                                          icon: Icons.flag,
                                          text: 'High',
                                          color: const Color.fromARGB(
                                              201, 229, 27, 27),
                                          textcolor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        TaskWidgets(
                                          height: height,
                                          icon: Icons.calendar_month,
                                          text: '5 Dec',
                                          color: const Color.fromARGB(
                                              201, 229, 27, 27),
                                          textcolor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Card(
                      color: Colors.white,
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
                                  fontSize: height * 0.018,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'A new announcement has been published by Swasti Negi on Wednesday, 20 December, 2023.',
                              style: TextStyle(
                                fontSize: height * 0.015,
                                color: Color.fromARGB(141, 0, 0, 0),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                    'assets/image/annoucementImage.png')),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: 15,
                    // ),
                    // Card(
                    //   color: Colors.white,
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
                    //           'Today Task',
                    //           style: TextStyle(
                    //               fontSize: height * 0.018,
                    //               color: AppColor.mainTextColor,
                    //               fontWeight: FontWeight.w500),
                    //         ),
                    //         SizedBox(
                    //           height: 5,
                    //         ),
                    //         Text(
                    //           'The tasks assigned to you for today',
                    //           style: TextStyle(
                    //             fontSize: height * 0.015,
                    //             color: AppColor.mainTextColor2,
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 10,
                    //         ),
                    //         Padding(
                    //           padding: const EdgeInsets.all(12),
                    //           child: Center(
                    //             child: ClipRRect(
                    //                 borderRadius: BorderRadius.circular(5),
                    //                 child: Image.asset(
                    //                   'assets/image/Frame.png',
                    //                   height: height * 0.08,
                    //                 )),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 10,
                    //         ),
                    //         Center(
                    //           child: Text(
                    //             'No Tasks Assigned',
                    //             style: TextStyle(
                    //                 fontSize: height * 0.018,
                    //                 color: AppColor.mainTextColor,
                    //                 fontWeight: FontWeight.w500),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 10,
                    //         ),
                    //         Text(
                    //           'It looks like you don’t have any tasks assigned to you right now. Don’t worry, this space will be updated as new tasks become available.',
                    //           style: TextStyle(
                    //             fontSize: height * 0.012,
                    //             color: AppColor.mainTextColor2,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 15,
                    // ),
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
              color: Colors.white,
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
          color: Colors.white,
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
      width: width * 0.2,
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
