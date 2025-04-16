// ignore_for_file: prefer_interpolation_to_compose_strings, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hrms/presentation/screens/punch_in_out_screen.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'punch_records.dart';

class ClockInScreenSecond extends StatefulWidget {
  final String empID;
  const ClockInScreenSecond(this.empID);
  @override
  State<ClockInScreenSecond> createState() => _ClockInScreenSecondState();
}

class _ClockInScreenSecondState extends State<ClockInScreenSecond> {
  final Box _authBox = Hive.box('authBox');
  late Future<List<Attendance>> attendenceLog;
  String? empDesign;
  String? empGender;
  late String empID;
  int pageCount = 1;
  int selectedIndex = 0;
  String? monthString;
  List<String> months = [];
  DateTime currentDate = DateTime.now();

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    empID = widget.empID;

    for (int i = 0; i < 12; i++) {
      DateTime monthDate = DateTime(currentDate.year, currentDate.month - i);
      monthString =
          getMonthName(monthDate.month) + " " + monthDate.year.toString();
      months.add(monthString!);
    }

    attendenceLog = fetchAttendence(
        empID, DateFormat('MMMM yyyy').format(DateTime.now()).toString());

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

   String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
          backgroundColor: AppColor.mainBGColor,
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
                          offset: Offset(0, 10))
                    ],
                    color: AppColor.mainThemeColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Attendence',
                              style: TextStyle(
                                  fontSize: height * 0.023,
                                  color: AppColor.mainFGColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            SizedBox(
                              width: width / 2,
                              child: Text(
                                'Check Your Punch Record & Leave Types',
                                style: TextStyle(
                                  fontSize: height * 0.015,
                                  color: AppColor.mainFGColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        Image.asset(
                          'assets/image/clockinImage.png',
                          height: height * 0.09,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: width,
                      height: height * 0.06,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: months.length,
                          itemBuilder: (context, index) {
                            final items = months[index];
                            bool isSelected = selectedIndex == index;

                            return Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    attendenceLog =
                                        fetchAttendence(empID, items);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ))),
                                  child: Text(
                                    months[index].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: height * 0.016,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Expanded(
                      child: FutureBuilder<List<Attendance>>(
                        future: attendenceLog,
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
                            return Center(
                                child:
                                    Text('No attendance records available.'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child:
                                    Text('No attendance records available.'));
                          } else {
                            List<Attendance> items = snapshot.data!;

                            return ListView.separated(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                Attendance item = items[index];

                                DateTime dateTime = DateTime.parse(item.inTime);
                                DateTime dateTime2 =
                                    DateTime.parse(item.outTime);

                                int hours = item.duration ~/ 60;
                                int minutes = item.duration % 60;

                                String formattedDuration =
                                    hours == 0 && minutes == 0
                                        ? '--/--'
                                        : (hours < 10 ? '0$hours' : '$hours') +
                                            ':' +
                                            (minutes < 10
                                                ? '0$minutes'
                                                : '$minutes');

                                print(formattedDuration);

                                DateTime date =
                                    DateTime.parse(item.attendanceDate);

                                String attendDate =
                                    DateFormat('dd').format(date);

                                String attendDay =
                                    DateFormat('EEE').format(date);

                                String regularizationDate =
                                    DateFormat('yyyy-MM-dd').format(date);

                                String punchIn =
                                    "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                                String punchOut =
                                    "${dateTime2.hour.toString().padLeft(2, '0')}:${dateTime2.minute.toString().padLeft(2, '0')}";

                                DateTime? scheduledTime;
                                scheduledTime = _authBox
                                        .get('lateby')
                                        .toString()
                                        .contains('10')
                                    ? DateTime.parse(DateFormat('yyyy-MM-dd')
                                            .format(dateTime) +
                                        ' ${_authBox.get('lateby')}')
                                    : DateTime.parse(DateFormat('yyyy-MM-dd')
                                            .format(dateTime) +
                                        ' 0${_authBox.get('lateby')}');

                                Duration lateByDuration =
                                    dateTime.difference(scheduledTime);

                                int lateMinutes =
                                    (lateByDuration.inMinutes) - 20;

                                return InkWell(
                                    onTap: () {
                                      if (item.punchRecords.isNotEmpty) {
                                        // Navigator.push(context, MaterialPageRoute(builder: (context)=> PunchRecordScreen(punchRecords: item.punchRecords)));
                                        showCupertinoModalBottomSheet(
                                          expand: true,
                                          context: context,
                                          barrierColor: const Color.fromARGB(
                                              130, 0, 0, 0),
                                          backgroundColor:
                                              const Color.fromARGB(0, 0, 0, 0),
                                          builder: (context) =>
                                              PunchRecordScreen(
                                            punchRecords: item.punchRecords,
                                            regularizationDate:
                                                regularizationDate,
                                            lateMinutes: lateMinutes,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'No punch records available for this date.')),
                                        );
                                      }
                                    },
                                    child: Card(
                                      color: AppColor.mainFGColor,
                                      elevation: 4,
                                      margin: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      shadowColor:
                                          Colors.black.withOpacity(0.1),
                                      child: Stack(
                                        alignment:
                                            AlignmentDirectional.bottomEnd,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: width * 0.16,
                                                    height: height * 0.08,
                                                    child: Card(
                                                      color: item.weekOff ==
                                                                  1 ||
                                                              item.isHoliday ==
                                                                  1
                                                          ? AppColor.mainBGColor
                                                          : AppColor
                                                              .mainThemeColor,
                                                      elevation: 4,
                                                      margin: EdgeInsets.all(0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      shadowColor: Colors.black
                                                          .withOpacity(0.1),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              '$attendDate',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    height * 0.03,
                                                                color: item.weekOff ==
                                                                            1 ||
                                                                        item.isHoliday ==
                                                                            1
                                                                    ? Colors
                                                                        .black87
                                                                    : Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              '$attendDay',
                                                              style: TextStyle(
                                                                fontSize: height *
                                                                    0.014,
                                                                color: item.weekOff ==
                                                                            1 ||
                                                                        item.isHoliday ==
                                                                            1
                                                                    ? Colors
                                                                        .black87
                                                                    : Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        punchIn == '00:00'
                                                            ? '--/--'
                                                            : '$punchIn',
                                                        style: TextStyle(
                                                            fontSize:
                                                                height * 0.02,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColor
                                                                .mainTextColor),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.005,
                                                      ),
                                                      Text(
                                                        'Clock-In',
                                                        style: TextStyle(
                                                            fontSize:
                                                                height * 0.014,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                            color: AppColor
                                                                .mainTextColor),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.01,
                                                      ),
                                                    ],
                                                  ),
                                                  VerticalDivider(
                                                    color: Colors.black,
                                                    thickness: 0.3,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        punchIn == '00:00'
                                                            ? '--/--'
                                                            : '$punchOut',
                                                        style: TextStyle(
                                                            fontSize:
                                                                height * 0.02,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColor
                                                                .mainTextColor),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.005,
                                                      ),
                                                      Text(
                                                        'Clock-Out',
                                                        style: TextStyle(
                                                            fontSize:
                                                                height * 0.014,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                            color: AppColor
                                                                .mainTextColor),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.01,
                                                      ),
                                                    ],
                                                  ),
                                                  VerticalDivider(
                                                    color: Colors.black,
                                                    thickness: 0.3,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        punchIn == '00:00'
                                                            ? '--/--'
                                                            : formattedDuration,
                                                        style: TextStyle(
                                                          fontSize:
                                                              height * 0.02,
                                                               fontWeight:
                                                                FontWeight.w600,
                                                          color: AppColor
                                                              .mainTextColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.005,
                                                      ),
                                                      Text(
                                                        'Total Hrs',
                                                        style: TextStyle(
                                                            fontSize:
                                                                height * 0.014,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                            color: AppColor
                                                                .mainTextColor),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.01,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Stack(
                                            alignment:
                                                AlignmentDirectional.bottomEnd,
                                            children: [
                                              Visibility(
                                                visible: (item.weekOff != 1 &&
                                                        item.isLeaveTaken ==
                                                            false) &&
                                                    (item.duration > 200 &&
                                                        item.duration < 450),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 0,
                                                        horizontal: 20),
                                                    child: Text(
                                                      'Half-Day',
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.013,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .mainFGColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: (item.weekOff != 1 &&
                                                        item.isLeaveTaken ==
                                                            false) &&
                                                    (lateMinutes >= 1 &&
                                                        lateMinutes <= 20),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 0,
                                                        horizontal: 20),
                                                    child: Text(
                                                      'Late by ${(lateMinutes / 60).toInt()}:${(lateMinutes - ((lateMinutes / 60).toInt()) * 60)} mins',
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.013,
                                                      fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .mainFGColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: (item.weekOff != 1 &&
                                                    item.isLeaveTaken == true),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 0,
                                                        horizontal: 20),
                                                    child: Text(
                                                      item.leaveType,
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.013,
                                                   fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .mainFGColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: (item.weekOff != 1 &&
                                                        item.isLeaveTaken ==
                                                            false) &&
                                                    (item.absent == 1 &&
                                                        punchIn == "00:00"),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          15))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 0,
                                                        horizontal: 20),
                                                    child: Text(
                                                      'Absent',
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.013,
                                                       fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .mainFGColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  height: height * 0.01,
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColor.mainThemeColor,
            onPressed: () => showCupertinoModalBottomSheet(
              expand: true,
              context: context,
              barrierColor: const Color.fromARGB(130, 0, 0, 0),
              backgroundColor: Colors.transparent,
              builder: (context) => PunchInOutScreen(),
            ),
            label: Text(
              'Clock-In',
              style: TextStyle(color: AppColor.mainFGColor),
            ),
          )),
    );
  }
}
