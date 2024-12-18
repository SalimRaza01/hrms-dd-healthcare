// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/model/models.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/screens/home/apply_leave.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String? empID;
  int touchedIndex = -1;
  String _selectedText = 'Pending';
  Color? activeColor;
  Color? activeText;
  late Future<List<LeaveHistory>> _leaveHistory;

  @override
  void initState() {
    checkEmployeeId();
    _leaveHistory = fetchLeaveHistory(_selectedText);
    super.initState();
  }

  Future<void> checkEmployeeId() async {
    var box = await Hive.openBox('authBox');

    setState(() {
      empID = box.get('employeeId');
    });
    print('Stored Employee ID: $empID');
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
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Row(
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
                              'Leave Summary',
                              style: TextStyle(
                                  fontSize: height * 0.023,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Submit Leave',
                              style: TextStyle(
                                fontSize: height * 0.018,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/image/leaveImage.png',
                        height: height * 0.1,
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
                    height: height * 0.69,
                    child: Column(
                      children: [
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
                                  height: 7,
                                ),
                                FutureBuilder<LeaveBalance>(
                                    future: fetchLeaves(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error:'));
                                      } else if (snapshot.hasData) {
                                        final leave = snapshot.data!;

                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              leaveWidget(height, width,
                                                  'Casual', leave.casualLeave),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              leaveWidget(
                                                  height,
                                                  width,
                                                  'Medical',
                                                  leave.medicalLeave),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              leaveWidget(height, width,
                                                  'Earned', leave.earnedLeave),
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
                                              leaveWidget(
                                                  height,
                                                  width,
                                                  'CompOff',
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
                            borderRadius: BorderRadius.circular(50),
                          ),
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _selectButton('Pending', height, width),
                                  _selectButton('Approved', height, width),
                                  _selectButton('Rejected', height, width),
                                ]),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: height * 0.47,
                          child: FutureBuilder<List<LeaveHistory>>(
                              future: _leaveHistory,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text('No History Found'));
                                } else {
                                  List<LeaveHistory> items = snapshot.data!;

                                  return ListView.separated(
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final leave = items[index];
                                      final applyDate =
                                          DateTime.parse(leave.dateTime);
                                      final startDate =
                                          DateTime.parse(leave.leaveStartDate);
                                      final endDate =
                                          DateTime.parse(leave.leaveEndDate);

                                      return Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        margin: EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        shadowColor:
                                            Colors.black.withOpacity(0.1),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('dd MMM yyyy')
                                                    .format(applyDate),
                                                style: TextStyle(
                                                  fontSize: height * 0.02,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.mainTextColor,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: AppColor.mainBGColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // Leave Date Section
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Leave Date',
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.016,
                                                              color: AppColor
                                                                  .mainTextColor
                                                                  .withOpacity(
                                                                      0.7),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text(
                                                            '${DateFormat('dd-MMM-yy').format(startDate)} - ${DateFormat('dd-MMM-yy').format(endDate)}',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  height * 0.02,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColor
                                                                  .mainTextColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Leave Deducted',
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.016,
                                                              color: AppColor
                                                                  .mainTextColor
                                                                  .withOpacity(
                                                                      0.7),
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text(
                                                            '${leave.leaveType}',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  height * 0.02,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
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
                                              SizedBox(height: 15),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    size: height * 0.02,
                                                    color: leave.status ==
                                                            'Approved'
                                                        ? Colors.green
                                                        : leave.status ==
                                                                'Pending'
                                                            ? Colors.orange
                                                            : Colors.red,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    leave.status,
                                                    style: TextStyle(
                                                      fontSize: height * 0.016,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColor
                                                          .mainTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 10),
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColor.mainThemeColor,
            onPressed: () => showCupertinoModalBottomSheet(
              expand: true,
              context: context,
              barrierColor: const Color.fromARGB(130, 0, 0, 0),
              backgroundColor: Colors.transparent,
              builder: (context) => ApplyLeave(),
            ),
            label: const Text(
              'Apply Leave',
              style: TextStyle(color: Colors.white),
            ),
          )),
    );
  }

  SizedBox leaveWidget(
      double height, double width, String leave, String leaveCount) {
    return SizedBox(
      width: width * 0.2,
      child: Card(
        color: AppColor.mainBGColor,
        elevation: 4,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
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

  Widget _selectButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedText == text) {
      activeColor = AppColor.mainThemeColor;
      activeText = Colors.white;
    } else {
      activeColor = Colors.transparent;
      activeText = const Color.fromARGB(141, 0, 0, 0);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          _leaveHistory = fetchLeaveHistory(_selectedText);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 5),
          child: Text(
            text,
            style: TextStyle(
              color: activeText,
              fontSize: height * 0.015,
            ),
          ),
        ),
      ),
    );
  }
}
