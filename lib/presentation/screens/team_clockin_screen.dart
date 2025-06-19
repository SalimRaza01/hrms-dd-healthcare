// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/screens/team_punchrecords.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TeamClockinScreen extends StatefulWidget {
  final String empID;
  const TeamClockinScreen(this.empID);
  @override
  State<TeamClockinScreen> createState() => _TeamClockinScreenState();
}

class _TeamClockinScreenState extends State<TeamClockinScreen> {
  final Box _authBox = Hive.box('authBox');
  late Future<List<Attendance>> attendenceLog;
  late String empID;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    attendenceLog = fetchAttendence(widget.empID,
        DateFormat('MMMM yyyy').format(DateTime.now()).toString());
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

    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColor.mainBGColor,
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder<List<Attendance>>(
            future: attendenceLog,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: AppColor.mainTextColor2,
                    size: height * 0.03,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('No attendance records available.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No attendance records available.'));
              } else {
                List<Attendance> items = snapshot.data!;

                return ListView.separated(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    Attendance item = items[index];

                    DateTime dateTime = DateTime.parse(item.inTime);
                    DateTime dateTime2 = DateTime.parse(item.outTime);

                    int hours = item.duration ~/ 60;
                    int minutes = item.duration % 60;

                    String formattedDuration = hours == 0 && minutes == 0
                        ? '--/--'
                        : (hours < 10 ? '0$hours' : '$hours') +
                            ':' +
                            (minutes < 10 ? '0$minutes' : '$minutes');

                    print(formattedDuration);

                    DateTime date = DateTime.parse(item.attendanceDate);

                    String attendDate = DateFormat('dd').format(date);

                    String attendDay = DateFormat('EEE').format(date);

                    String punchIn =
                        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                    String punchOut =
                        "${dateTime2.hour.toString().padLeft(2, '0')}:${dateTime2.minute.toString().padLeft(2, '0')}";

                    DateTime? scheduledTime;
                    scheduledTime = _authBox
                            .get('lateby')
                            .toString()
                            .contains('10')
                        ? DateTime.parse(
                            DateFormat('yyyy-MM-dd').format(dateTime) +
                                ' ${_authBox.get('lateby')}')
                        : DateTime.parse(
                            DateFormat('yyyy-MM-dd').format(dateTime) +
                                ' 0${_authBox.get('lateby')}');

                    Duration lateByDuration =
                        dateTime.difference(scheduledTime);

                    int lateMinutes = (lateByDuration.inMinutes) - 20;

                    return InkWell(
                        onTap: () {
                          if (item.punchRecords.isNotEmpty) {
                            // Navigator.push(context, MaterialPageRoute(builder: (context)=> PunchRecordScreen(punchRecords: item.punchRecords)));
                            showCupertinoModalBottomSheet(
                              expand: true,
                              context: context,
                              barrierColor: AppColor.barrierColor,
                              backgroundColor: Colors.transparent,
                              builder: (context) => TeamPunchrecords(
                                punchRecords: item.punchRecords,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
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
                          shadowColor: AppColor.shadowColor,
                          child: Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Card(
                                        color: item.weekOff == 1 ||
                                                item.isHoliday == 1
                                            ? AppColor.mainBGColor
                                            : AppColor.mainThemeColor,
                                        elevation: 4,
                                        margin: EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        shadowColor:
                                         AppColor.shadowColor,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                '$attendDate',
                                                style: TextStyle(
                                                  fontSize: height * 0.03,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.weekOff == 1 ||
                                                          item.isHoliday == 1
                                                      ? AppColor.mainTextColor2
                                                      : AppColor.mainFGColor,
                                                ),
                                              ),
                                              Text(
                                                '$attendDay',
                                                style: TextStyle(
                                                  fontSize: height * 0.014,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.weekOff == 1 ||
                                                          item.isHoliday == 1
                                                      ? AppColor.mainTextColor2
                                                      : AppColor.mainFGColor,
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
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.mainTextColor),
                                          ),
                                          SizedBox(
                                            height: height * 0.005,
                                          ),
                                          Text(
                                            'Clock in',
                                            style: TextStyle(
                                                fontSize: height * 0.014,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.mainTextColor),
                                          ),
                                          SizedBox(
                                            height: height * 0.01,
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(
                                        color: AppColor.mainTextColor,
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
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.mainTextColor),
                                          ),
                                          SizedBox(
                                            height: height * 0.005,
                                          ),
                                          Text(
                                            'Clock out',
                                            style: TextStyle(
                                                fontSize: height * 0.014,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.mainTextColor),
                                          ),
                                          SizedBox(
                                            height: height * 0.01,
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(
                                        color: AppColor.mainTextColor,
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
                                                : formattedDuration,
                                            style: TextStyle(
                                              fontSize: height * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.mainTextColor,
                                            ),
                                          ),
                                          SizedBox(
                                            height: height * 0.005,
                                          ),
                                          Text(
                                            'Total Hrs',
                                            style: TextStyle(
                                                fontSize: height * 0.014,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.mainTextColor),
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
                                alignment: AlignmentDirectional.bottomEnd,
                                children: [
                                  Visibility(
                                    visible: (item.weekOff != 1 &&
                                            item.isLeaveTaken == false) &&
                                        (item.duration > 200 &&
                                            item.duration < 450),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomRight:
                                                  Radius.circular(15))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 20),
                                        child: Text(
                                          'Half-Day',
                                          style: TextStyle(
                                              fontSize: height * 0.013,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.mainFGColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: (item.weekOff != 1 &&
                                            item.isLeaveTaken == false) &&
                                        (lateMinutes >= 1 && lateMinutes <= 20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomRight:
                                                  Radius.circular(15))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 20),
                                        child: Text(
                                          'Late by ${(lateMinutes / 60).toInt()}:${(lateMinutes - ((lateMinutes / 60).toInt()) * 60)} mins',
                                          style: TextStyle(
                                              fontSize: height * 0.013,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.mainFGColor),
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
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomRight:
                                                  Radius.circular(15))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 20),
                                        child: Text(
                                          item.leaveType,
                                          style: TextStyle(
                                              fontSize: height * 0.013,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.mainFGColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: (item.weekOff != 1 &&
                                            item.isLeaveTaken == false) &&
                                        (item.absent == 1 &&
                                            punchIn == "00:00"),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomRight:
                                                  Radius.circular(15))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 20),
                                        child: Text(
                                          'Absent',
                                          style: TextStyle(
                                              fontSize: height * 0.013,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.mainFGColor),
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
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: height * 0.01,
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    ));
  }
}
