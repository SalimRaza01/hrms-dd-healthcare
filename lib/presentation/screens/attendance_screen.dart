import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.newgredient1,
                const Color.fromARGB(52, 96, 125, 139),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 15.0,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    ' My Attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: height * 0.018, color: Colors.black),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: height * 0.07,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(28),
                  ),
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
                              attendenceLog = fetchAttendence(empID, items);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text(
                              months[index].toUpperCase(),
                              style: TextStyle(
                                fontSize: height * 0.016,
                                color: isSelected ? Colors.black : Colors.grey,
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
                Expanded(
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
                        return Center(
                            child: Text('No attendance records available.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('No attendance records available.'));
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
      
                            String formattedDuration = hours == 0 &&
                                    minutes == 0
                                ? '--/--'
                                : (hours < 10 ? '0$hours' : '$hours') +
                                    ':' +
                                    (minutes < 10 ? '0$minutes' : '$minutes');
      
                            DateTime date = DateTime.parse(item.attendanceDate);
      
                            String attendDate = DateFormat('dd').format(date);
      
                            String attendDay = DateFormat('EEE').format(date);
      
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
                                ? DateTime.parse(
                                    DateFormat('yyyy-MM-dd').format(dateTime) +
                                        ' ${_authBox.get('lateby')}')
                                : DateTime.parse(
                                    DateFormat('yyyy-MM-dd').format(dateTime) +
                                        ' 0${_authBox.get('lateby')}');
      
                            Duration lateByDuration =
                                dateTime.difference(scheduledTime);
      
                            int lateMinutes = (lateByDuration.inMinutes) - 15;
                            int reguTimeLimit = (lateMinutes -
                                ((lateMinutes / 60).toInt()) * 60);
      
                            print(
                                'late min $lateMinutes and regutime $reguTimeLimit');
      
                            return InkWell(
                                onTap: () {
                                  if (item.punchRecords.isNotEmpty) {
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=> PunchRecordScreen(punchRecords: item.punchRecords)));
                                    showCupertinoModalBottomSheet(
                                      expand: true,
                                      context: context,
                                      barrierColor: AppColor.barrierColor,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => PunchRecordScreen(
                                        punchRecords: item.punchRecords,
                                        regularizationDate: regularizationDate,
                                        lateMinutes: reguTimeLimit,
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Card(
                                      color: AppColor.mainFGColor,
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(38),
                                      ),
                                      shadowColor: AppColor.shadowColor,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 13),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: width * 0.14,
                                                height: height * 0.072,
                                                decoration: BoxDecoration(
                                                  color: item.weekOff == 1 ||
                                                          item.isHoliday == 1
                                                      ? AppColor.mainBGColor
                                                      : const Color(0xFF8CD193),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '$attendDate',
                                                      style: TextStyle(
                                                        fontSize:
                                                            height * 0.024,
                                                        color: item.weekOff ==
                                                                    1 ||
                                                                item.isHoliday ==
                                                                    1
                                                            ? AppColor
                                                                .mainTextColor2
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      '$attendDay',
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.014,
                                                          color: item.weekOff ==
                                                                      1 ||
                                                                  item.isHoliday ==
                                                                      1
                                                              ? AppColor
                                                                  .mainTextColor2
                                                              : const Color
                                                                  .fromARGB(255,
                                                                  58, 58, 58)),
                                                    ),
                                                  ],
                                                ),
                                              ),
      
                                              // Clock-In
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    punchIn == '00:00'
                                                        ? '--/--'
                                                        : '$punchIn',
                                                    style: TextStyle(
                                                      fontSize: height * 0.02,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.005),
                                                  Text(
                                                    'Clock-In',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      color: AppColor
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              VerticalDivider(
                                                color: AppColor.mainTextColor
                                                    .withOpacity(0.4),
                                                thickness: 0.5,
                                              ),
                                              // Clock-Out
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    punchIn == '00:00'
                                                        ? '--/--'
                                                        : '$punchOut',
                                                    style: TextStyle(
                                                      fontSize: height * 0.02,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.005),
                                                  Text(
                                                    'Clock-Out',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      color: AppColor
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              VerticalDivider(
                                                color: AppColor.mainTextColor
                                                    .withOpacity(0.4),
                                                thickness: 0.5,
                                              ),
                                              // Total Hours
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    punchIn == '00:00'
                                                        ? '--/--'
                                                        : formattedDuration,
                                                    style: TextStyle(
                                                      fontSize: height * 0.02,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.005),
                                                  Text(
                                                    'Total Hrs',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      color: AppColor
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Stack(
                                      alignment: AlignmentDirectional.bottomEnd,
                                      children: [
                                        if ((item.weekOff != 1 &&
                                            item.isLeaveTaken == false &&
                                            item.duration > 270 &&
                                            item.duration < 510))
                                          _buildTag(height, 'Half-Day',
                                              Colors.redAccent),
                                        if ((item.weekOff != 1 &&
                                            item.isLeaveTaken == false &&
                                            lateMinutes >= 1 &&
                                            lateMinutes <= 15))
                                          _buildTag(
                                            height,
                                            'Late by ${(lateMinutes / 60).toInt()}:${(lateMinutes % 60).toString().padLeft(2, '0')} mins',
                                            Colors.redAccent,
                                          ),
                                        if (item.weekOff != 1 &&
                                            item.isLeaveTaken == true)
                                          _buildTag(height, item.leaveType,
                                              Colors.green),
                                        if ((item.weekOff != 1 &&
                                            item.isLeaveTaken == false &&
                                            item.absent == 1 &&
                                            punchIn == "00:00"))
                                          _buildTag(height, 'Absent',
                                              Colors.redAccent),
                                      ],
                                    ),
                                  ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(double height, String text, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: height * 0.013,
            fontWeight: FontWeight.w500,
            color: AppColor.mainFGColor,
          ),
        ),
      ),
    );
  }
}
