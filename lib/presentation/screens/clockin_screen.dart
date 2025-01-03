import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/screens/punch_in_out_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'punch_records.dart';

class ClockInScreenSecond extends StatefulWidget {
    final String empID;
  const ClockInScreenSecond(this.empID);
  @override
  State<ClockInScreenSecond> createState() => _ClockInScreenSecondState();
}

class _ClockInScreenSecondState extends State<ClockInScreenSecond> {
  late Future<List<Attendance>> attendenceLog;

late String empID;
  @override
  void initState() {
    super.initState();
    attendenceLog = fetchAttendence(widget.empID);
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Let’s Clock-In!',
                              style: TextStyle(
                                  fontSize: height * 0.023,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Text(
                              'Don’t miss your clock in schedule',
                              style: TextStyle(
                                fontSize: height * 0.018,
                                color: Colors.white,
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
                      height: height * 0.01,
                    ),
                    Expanded(
                      child: FutureBuilder<List<Attendance>>(
                        future: attendenceLog,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
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
                                Duration duration =
                                    dateTime2.difference(dateTime);

                                int hours = duration.inHours;
                                int minutes = duration.inMinutes % 60;

                                String formattedDuration =
                                    hours == 0 && minutes == 0
                                        ? '--/--'
                                        : (hours < 10 ? '0$hours' : '$hours') +
                                            ':' +
                                            (minutes < 10
                                                ? '0$minutes'
                                                : '$minutes');

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
                                                  punchRecords:
                                                      item.punchRecords,
                                                  regularizationDate:
                                                      regularizationDate),
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
                                      color: Colors.white,
                                      elevation: 4,
                                      margin: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      shadowColor:
                                          Colors.black.withOpacity(0.1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Card(
                                                color: attendDay == 'Sun' ||
                                                        attendDay == 'Sat'
                                                    ? AppColor.mainBGColor
                                                    : item.isHoliday != 0
                                                        ? Colors.amber
                                                        : AppColor
                                                            .mainThemeColor,
                                                elevation: 4,
                                                margin: EdgeInsets.all(0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                shadowColor: Colors.black
                                                    .withOpacity(0.1),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 15,
                                                      vertical: 8),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        '$attendDate',
                                                        style: TextStyle(
                                                          fontSize:
                                                              height * 0.03,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: attendDay ==
                                                                      'Sun' ||
                                                                  attendDay ==
                                                                      'Sat'
                                                              ? Colors.black87
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        '$attendDay',
                                                        style: TextStyle(
                                                          fontSize:
                                                              height * 0.014,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: attendDay ==
                                                                      'Sun' ||
                                                                  attendDay ==
                                                                      'Sat'
                                                              ? Colors.black87
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    punchIn == '00:00'
                                                        ? '--/--'
                                                        : '$punchIn',
                                                    style: TextStyle(
                                                        fontSize: height * 0.02,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor
                                                            .mainTextColor),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Text(
                                                    'Clock in',
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
                                              VerticalDivider(
                                                color: Colors.black,
                                                thickness: 0.3,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    punchIn == '00:00'
                                                        ? '--/--'
                                                        : '$punchOut',
                                                    style: TextStyle(
                                                        fontSize: height * 0.02,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor
                                                            .mainTextColor),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Text(
                                                    'Clock out',
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
                                              VerticalDivider(
                                                color: Colors.black,
                                                thickness: 0.3,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    formattedDuration,
                                                    style: TextStyle(
                                                      fontSize: height * 0.02,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                            FontWeight.w500,
                                                        color: AppColor
                                                            .mainTextColor),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: width * 0.02,
                                              )
                                            ],
                                          ),
                                        ),
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
            label: const Text(
              'Clock-In',
              style: TextStyle(color: Colors.white),
            ),
          )),
    );
  }
}
