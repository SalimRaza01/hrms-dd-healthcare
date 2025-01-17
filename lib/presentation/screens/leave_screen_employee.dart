// ignore_for_file: sort_child_properties_last

import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'apply_leave.dart';

class LeaveScreenEmployee extends StatefulWidget {
  final String empID;
  const LeaveScreenEmployee(this.empID);

  @override
  State<LeaveScreenEmployee> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreenEmployee> {
  late String? empID;
  int touchedIndex = -1;
  String _selectedText = 'Pending';
  Color? activeColor;
  Color? activeText;
  late Future<List<LeaveHistory>> _leaveHistory;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print(widget.empID);
    _leaveHistory = fetchLeaveHistory(_selectedText, widget.empID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppColor.mainBGColor,
          body: Stack(
            children: [
              Container(
                height: height * 0.27,
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                                'Leave Balance',
                                style: TextStyle(
                                    fontSize: height * 0.025,
                                    color: AppColor.mainFGColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              Text(
                                'Leave History',
                                style: TextStyle(
                                  fontSize: height * 0.018,
                                  color: AppColor.mainFGColor,
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
                        child: SizedBox(
                          width: width,
                          child: FutureBuilder<LeaveBalance>(
                              future: fetchLeaves(widget.empID),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _shimmerLoader(height, width);
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('No Data Found'));
                                } else if (snapshot.hasData) {
                                  final leave = snapshot.data!;
                          
                          
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      leaveWidget(height, width, 'Casual',
                                          leave.casualLeave),
                                     
                                      leaveWidget(height, width,
                                          'Medical', leave.medicalLeave),
                                     
                                      leaveWidget(height, width, 'Earned',
                                          leave.earnedLeave),
                                                                      
                                      
                                    ],
                                  );
                                } else {
                                  return Center(child: Text('No Data Found'));
                                }
                              }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
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
                        padding: EdgeInsets.all(4),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _selectButton('Pending', height, width),
                              _selectButton('Approved', height, width),
                              _selectButton('Rejected', height, width),
                            ]),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Expanded(
                      child: FutureBuilder<List<LeaveHistory>>(
                          future: _leaveHistory,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _shimmerhistoryLoader(height, width);
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Card(
                                  color: AppColor.mainFGColor,
                                  elevation: 4,
                                  margin: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('No History Found'),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.1),
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Card(
                                  color: AppColor.mainFGColor,
                                  elevation: 4,
                                  margin: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('No History Found'),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.1),
                                ),
                              );
                            } else {
                              List<LeaveHistory> items = snapshot.data!;

                              return ListView.separated(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final leave = items[index];
                                  final startDate =
                                      DateTime.parse(leave.leaveStartDate);
                                  final endDate =
                                      DateTime.parse(leave.leaveEndDate);

                                  return Card(
                                    color: AppColor.mainFGColor,
                                    elevation: 4,
                                    margin: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                leave.totalDays == '1'
                                                    ? 'Full Day Application'
                                                    : leave.totalDays == '0.5'
                                                        ? 'Half-Day Application'
                                                        : '${leave.totalDays} Days Application',
                                                style: TextStyle(
                                                    fontSize: height * 0.014,
                                                    color: Color.fromARGB(
                                                        141, 0, 0, 0)),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: leave.status ==
                                                            'Pending'
                                                        ? const Color.fromARGB(
                                                            116, 255, 198, 124)
                                                        : leave.status ==
                                                                'Approved'
                                                            ? const Color
                                                                .fromARGB(255,
                                                                226, 255, 193)
                                                            : const Color
                                                                .fromARGB(255,
                                                                249, 177, 177),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                                  child: Text(
                                                    '${leave.status}',
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      color: leave.status ==
                                                              'Pending'
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 227, 129, 0)
                                                          : leave.status ==
                                                                  'Approved'
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  113, 163, 56)
                                                              : const Color
                                                                  .fromARGB(255,
                                                                  229, 45, 45),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '${DateFormat('EEE, dd MMM').format(startDate)} - ${DateFormat('EEE, dd MMM').format(endDate)}',
                                            style: TextStyle(
                                              fontSize: height * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.mainTextColor2,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          // Text(
                                          //   leave.leaveType == 'earnedLeave'
                                          //       ? 'Earned'
                                          //       : leave.leaveType ==
                                          //               'medicalLeave'
                                          //           ? 'Medical'
                                          //           : leave.leaveType ==
                                          //                   'casualLeave'
                                          //               ? 'Casual'
                                          //               : leave.leaveType ==
                                          //                       'paternityLeave'
                                          //                   ? 'Paternity'
                                          //                   : leave.leaveType ==
                                          //                           'maternityLeave'
                                          //                       ? 'Maternity'
                                          //                       : leave.leaveType ==
                                          //                               'regularized'
                                          //                           ? 'Regularization'
                                          //                           : leave
                                          //                               .leaveType,
                                          //   style: TextStyle(
                                          //       color: AppColor.mainThemeColor),
                                          // )
                                            Text(
  _leaveTypeLabel(leave.leaveType),
  style: TextStyle(color: AppColor.mainThemeColor),
)
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
            label:  Text(
              'Apply Leave',
              style: TextStyle(color: AppColor.mainFGColor),
            ),
          )),
    );
  }



String _leaveTypeLabel(String leaveType) {
  final leaveTypeMap = {
    'earnedLeave': 'Earned',
    'medicalLeave': 'Medical',
    'casualLeave': 'Casual',
    'paternityLeave': 'Paternity',
    'maternityLeave': 'Maternity',
    'regularized': 'Regularization',
        'shortLeave': 'Short-leave',
  };

  return leaveTypeMap[leaveType] ?? leaveType; 
}


  SizedBox leaveWidget(
      double height, double width, String leave, String leaveCount) {
    return SizedBox(
      width: width * 0.27,
      child: Card(
        color: AppColor.mainBGColor,
        elevation: 4,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = const Color.fromARGB(141, 0, 0, 0);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          _leaveHistory = fetchLeaveHistory(_selectedText, widget.empID);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 12),
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

  SizedBox _shimmerLoader(double height, double width) {
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

  SizedBox _shimmerhistoryLoader(double height, double width) {
    return SizedBox(
      height: height * 0.1,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.separated(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              height: height * 0.15,
              color: AppColor.mainFGColor,
              width: width * 0.9,
              margin: EdgeInsets.symmetric(vertical: 5),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 10),
        ),
      ),
    );
  }
}
