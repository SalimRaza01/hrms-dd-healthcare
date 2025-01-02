import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/screens/team_punchrecords.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TeamClockinScreen extends StatefulWidget {
  final String empID;
  const TeamClockinScreen(this.empID);
  @override
  State<TeamClockinScreen> createState() => _TeamClockinScreenState();
}

class _TeamClockinScreenState extends State<TeamClockinScreen> {
  late Future<List<Attendance>> attendenceLog;
  late String empID;
  @override
  void initState() {
    super.initState();
    attendenceLog = fetchAttendence(widget.empID);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
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
                    Duration duration = dateTime2.difference(dateTime);

                    int hours = duration.inHours;
                    int minutes = duration.inMinutes % 60;

                    String formattedDuration = hours == 0 && minutes == 0
                        ? '--/--'
                        : (hours < 10 ? '0$hours' : '$hours') +
                            ':' +
                            (minutes < 10 ? '0$minutes' : '$minutes');

                    DateTime date = DateTime.parse(item.attendanceDate);

                    String attendDate = DateFormat('dd').format(date);

                    String attendDay = DateFormat('EEE').format(date);


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
                              barrierColor: const Color.fromARGB(130, 0, 0, 0),
                              backgroundColor: const Color.fromARGB(0, 0, 0, 0),
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
                          color: Colors.white,
                          elevation: 4,
                          margin: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Card(
                                    color:
                                        attendDay == 'Sun' || attendDay == 'Sat'
                                            ? AppColor.mainBGColor
                                            : item.isHoliday != 0
                                                ? Colors.amber
                                                : AppColor.mainThemeColor,
                                    elevation: 4,
                                    margin: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.1),
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
                                              color: attendDay == 'Sun' ||
                                                      attendDay == 'Sat'
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '$attendDay',
                                            style: TextStyle(
                                              fontSize: height * 0.014,
                                              fontWeight: FontWeight.bold,
                                              color: attendDay == 'Sun' ||
                                                      attendDay == 'Sat'
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    ],
                                  ),
                                  VerticalDivider(
                                    color: Colors.black,
                                    thickness: 0.3,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    ],
                                  ),
                                  VerticalDivider(
                                    color: Colors.black,
                                    thickness: 0.3,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        formattedDuration,
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
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 10,
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
