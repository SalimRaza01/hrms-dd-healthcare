import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/model/models.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/screens/home/punch_records.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});
  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  late Future<List<Attendance>> attendenceLog;

  @override
  void initState() {
    super.initState();

    attendenceLog = fetchAttendence();
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                child: Row(
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
                          height: 10,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: height * 0.68,
                  child: FutureBuilder<List<Attendance>>(
                    future: attendenceLog,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
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
                            Duration duration = dateTime2.difference(dateTime);

                            DateTime date = DateTime.parse(item.attendanceDate);

                            String attendDate =
                                DateFormat('dd MMMM yyyy').format(date);

                            String punchIn =
                                "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                            String punchOut =
                                "${dateTime2.hour.toString().padLeft(2, '0')}:${dateTime2.minute.toString().padLeft(2, '0')}";

                            int hours = duration.inHours;
                            int minutes = duration.inMinutes % 60;

                            return InkWell(
                                onTap: () {
                                  if (item.punchRecords.isNotEmpty) {
                                    showCupertinoModalBottomSheet(
                                      expand: true,
                                      context: context,
                                      barrierColor:
                                          const Color.fromARGB(130, 0, 0, 0),
                                      backgroundColor:
                                          const Color.fromARGB(0, 0, 0, 0),
                                      builder: (context) => PunchRecordScreen(
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
                                child:    Card(
                                        color: Colors.white,
                                        elevation: 4,
                     margin: EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        shadowColor:
                                            Colors.black.withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$attendDate',
                                          style: TextStyle(
                                            fontSize: height * 0.016,
                                            fontWeight: FontWeight
                                                .bold, // Improved hierarch
                                            color: AppColor.mainTextColor,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColor.mainBGColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey
                                                    .withOpacity(0.2)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                12), // Consistent padding
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _buildInfoColumn(
                                                    'Total Hours',
                                                    hours == 0 && minutes == 0
                                                        ? '00:00'
                                                        : (minutes >= 10 && minutes <= 59)
                                                            ? '0$hours:$minutes'
                                                            : '0$hours:${minutes}0',
                                                    height),
                                                _buildInfoColumn(
                                                    'Clock In & Out',
                                                    '$punchIn - $punchOut',
                                                    height),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              'Late: ',
                                              style: TextStyle(
                                                fontSize: height * 0.015,
                                                color: AppColor.mainTextColor2,
                                              ),
                                            ),
                                            Text(
                                              item.lateby.toString(),
                                              style: TextStyle(
                                                fontSize: height * 0.015,
                                                color: AppColor.mainTextColor2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: height * 0.015,
            color: AppColor.mainTextColor2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: height * 0.02,
            fontWeight: FontWeight.w600,
            color: AppColor.mainTextColor,
          ),
        ),
      ],
    );
  }
}
