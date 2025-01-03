// ignore_for_file: sort_child_properties_last

import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'apply_leave.dart';

class LeaveScreenManager extends StatefulWidget {
  final String empID;
  const LeaveScreenManager(this.empID);

  @override
  State<LeaveScreenManager> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreenManager>
    with SingleTickerProviderStateMixin {
  final Box _authBox = Hive.box('authBox');

  late String? empID;
  bool isLoading = true;
  int touchedIndex = -1;
  String _selectedText = 'Pending';
  Color? activeColor;
  Color? activeText;
  String updateUser = 'Self';
  late TabController _tabController;
  late Future<List<LeaveHistory>> _leaveHistory;
  late Future<List<LeaveRequests>> _leaveRequest;

  @override
  void initState() {
    _leaveHistory = fetchLeaveHistory(_selectedText, widget.empID);
    _leaveRequest = fetchLeaveRequest();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(_handleTabSelection);
    super.initState();
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          updateUser = 'Self';
          _leaveHistory = fetchLeaveHistory(_selectedText, widget.empID);
          break;
        case 1:
          updateUser = 'Team';
          _leaveRequest = fetchLeaveRequest();
          break;
      }
    });
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
                    TabBar(
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor:
                            const Color.fromARGB(206, 255, 255, 255),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.person), Text('Self')],
                            ),
                            // text: 'Self',
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.person), Text('Team')],
                            ),
                            // text: 'Self',
                          ),
                        ]),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Expanded(
                      child: TabBarView(controller: _tabController, children: [
                        selfSection(height, width),
                        teamSection(height, width),
                      ]),
                    )
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
            label: const Text(
              'Apply Leave',
              style: TextStyle(color: Colors.white),
            ),
          )),
    );
  }

  selfSection(double height, double width) {
    return Expanded(
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
                  FutureBuilder<LeaveBalance>(
                      future: fetchLeaves(widget.empID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _shimmerLoader(height, width);
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Internet connection error'));
                        } else if (snapshot.hasData) {
                          final leave = snapshot.data!;

                          _authBox.put('casual', leave.casualLeave);
                          _authBox.put('medical', leave.medicalLeave);
                          _authBox.put('maternity', leave.maternityLeave);
                          _authBox.put('earned', leave.earnedLeave);
                          _authBox.put('paternity', leave.paternityLeave);

                          return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  leaveWidget(height, width, 'Casual',
                                      leave.casualLeave),
                                  SizedBox(
                                    width: width * 0.025,
                                  ),
                                  leaveWidget(height, width, 'Medical',
                                      leave.medicalLeave),
                                  SizedBox(
                                    width: width * 0.025,
                                  ),
                                  leaveWidget(height, width, 'Earned',
                                      leave.earnedLeave),
                                  SizedBox(
                                    width: width * 0.025,
                                  ),
                                  leaveWidget(height, width, 'Maternity',
                                      leave.maternityLeave),
                                  SizedBox(
                                    width: width * 0.025,
                                  ),
                                  leaveWidget(height, width, 'Paternity',
                                      leave.paternityLeave),
                                ],
                              ));
                        } else {
                          return Center(child: Text('No Data Found'));
                        }
                      }),
                ],
              ),
            ),
          ),
          SizedBox(
            height: height * 0.02,
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _shimmerhistoryLoader(height, width);
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Card(
                        color: Colors.white,
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No History Found'));
                  } else {
                    List<LeaveHistory> items = snapshot.data!;

                    return ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final leave = items[index];
                        final startDate = DateTime.parse(leave.leaveStartDate);
                        final endDate = DateTime.parse(leave.leaveEndDate);

                        return Card(
                          color: Colors.white,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color: Color.fromARGB(141, 0, 0, 0)),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: leave.status == 'Pending'
                                              ? const Color.fromARGB(
                                                  116, 255, 198, 124)
                                              : leave.status == 'Approved'
                                                  ? const Color.fromARGB(
                                                      255, 226, 255, 193)
                                                  : const Color.fromARGB(
                                                      255, 249, 177, 177),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        child: Text(
                                          '${leave.status}',
                                          style: TextStyle(
                                            fontSize: height * 0.014,
                                            color: leave.status == 'Pending'
                                                ? const Color.fromARGB(
                                                    255, 227, 129, 0)
                                                : leave.status == 'Approved'
                                                    ? const Color.fromARGB(
                                                        255, 113, 163, 56)
                                                    : const Color.fromARGB(
                                                        255, 229, 45, 45),
                                            fontWeight: FontWeight.w500,
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
                                Text(
                                  leave.leaveType == 'earnedLeave'
                                      ? 'Earned'
                                      : leave.leaveType == 'medicalLeave'
                                          ? 'Medical'
                                          : leave.leaveType == 'casualLeave'
                                              ? 'Casual'
                                              : leave.leaveType ==
                                                      'paternityLeave'
                                                  ? 'Paternity'
                                                  : leave.leaveType ==
                                                          'maternityLeave'
                                                      ? 'Maternity'
                                                      : leave.leaveType ==
                                                              'regularized'
                                                          ? 'Regularization'
                                                          : leave.leaveType,
                                  style:
                                      TextStyle(color: AppColor.mainThemeColor),
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
    );
  }

  teamSection(double height, double width) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<LeaveRequests>>(
                future: _leaveRequest,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _shimmerhistoryLoader(height, width);
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('No Data Found'),
                        ),
                        shadowColor: Colors.black.withOpacity(0.1),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No Data Found'));
                  } else {
                    List<LeaveRequests> items = snapshot.data!;

                    return ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final leave = items[index];
                        final startDate = DateTime.parse(leave.leaveStartDate);
                        final endDate = DateTime.parse(leave.leaveEndDate);

                        return Card(
                          color: Colors.white,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      leave.employeeName,
                                      style: TextStyle(
                                          fontSize: height * 0.016,
                                          color: Color.fromARGB(141, 0, 0, 0),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: leave.status == 'Pending'
                                              ? const Color.fromARGB(
                                                  116, 255, 198, 124)
                                              : leave.status == 'Approved'
                                                  ? const Color.fromARGB(
                                                      255, 226, 255, 193)
                                                  : const Color.fromARGB(
                                                      255, 249, 177, 177),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        child: Text(
                                          '${leave.status}',
                                          style: TextStyle(
                                            fontSize: height * 0.014,
                                            color: leave.status == 'Pending'
                                                ? const Color.fromARGB(
                                                    255, 227, 129, 0)
                                                : leave.status == 'Approved'
                                                    ? const Color.fromARGB(
                                                        255, 113, 163, 56)
                                                    : const Color.fromARGB(
                                                        255, 229, 45, 45),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  leave.totalDays == '1' ||
                                          leave.totalDays == '0.5'
                                      ? DateFormat('EEE, dd MMM')
                                          .format(startDate)
                                      : '${DateFormat('EEE, dd MMM').format(startDate)} - ${DateFormat('EEE, dd MMM').format(endDate)}',
                                  style: TextStyle(
                                    fontSize: height * 0.018,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.mainTextColor2,
                                  ),
                                ),
                                Text(
                                  leave.leaveType == 'earnedLeave'
                                      ? leave.totalDays == '1'
                                          ? 'Earned - Full Day Application'
                                          : leave.totalDays == '0.5'
                                              ? 'Earned - Half-Day Application'
                                              : 'Earned - ${leave.totalDays} Days Application'
                                      : leave.leaveType == 'medicalLeave'
                                          ? leave.totalDays == '1'
                                              ? 'Medical - Full Day Application'
                                              : leave.totalDays == '0.5'
                                                  ? 'Medical - Half-Day Application'
                                                  : 'Medical - ${leave.totalDays} Days Application'
                                          : leave.leaveType == 'casualLeave'
                                              ? leave.totalDays == '1'
                                                  ? 'Casual - Full Day Application'
                                                  : leave.totalDays == '0.5'
                                                      ? 'Casual - Half-Day Application'
                                                      : 'Casual - ${leave.totalDays} Days Application'
                                              : leave.leaveType ==
                                                      'paternityLeave'
                                                  ? leave.totalDays == '1'
                                                      ? 'Paternity - Full Day Application'
                                                      : leave.totalDays == '0.5'
                                                          ? 'Paternity - Half-Day Application'
                                                          : 'Paternity - ${leave.totalDays} Days Application'
                                                  : leave.leaveType ==
                                                          'maternityLeave'
                                                      ? leave.totalDays == '1'
                                                          ? 'Maternity - Full Day Application'
                                                          : leave.totalDays ==
                                                                  '0.5'
                                                              ? 'Maternity - Half-Day Application'
                                                              : 'Maternity - ${leave.totalDays} Days Application'
                                                      : leave.leaveType ==
                                                              'regularized'
                                                          ? 'Regularization'
                                                          : leave.leaveType,
                                  style: TextStyle(
                                      color: AppColor.mainThemeColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: height * 0.015,
                                ),
                                Container(
                                  width: width,
                                  height: height * 0.05,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColor.mainBGColor,
                                          width: 2.0),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(leave.reason),
                                  ),
                                ),
                                Visibility(
                                  visible: leave.location.isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      width: width,
                                      height: height * 0.05,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColor.mainBGColor,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.file_copy_rounded,
                                              color: Colors.blue,
                                              size: height * 0.02,
                                            ),
                                            SizedBox(
                                              width: width * 0.03,
                                            ),
                                            Text(
                                              'IMG_45544871.JPG',
                                              style: TextStyle(
                                                  color:
                                                      AppColor.mainTextColor2,
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: leave.status == 'Pending',
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await leaveAction(
                                                context, 'Approved', leave.id);
                                            _leaveRequest = fetchLeaveRequest();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: const Color.fromARGB(
                                                  255, 127, 229, 131),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: width / 7,
                                                  vertical: 5),
                                              child: Text(
                                                'Accept',
                                                style: TextStyle(
                                                    color:
                                                        AppColor.mainTextColor,
                                                    fontSize: height * 0.015,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await leaveAction(
                                                context, 'Rejected', leave.id);
                                            _leaveRequest = fetchLeaveRequest();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: AppColor.mainBGColor,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: width / 7,
                                                  vertical: 5),
                                              child: Text(
                                                'Decline',
                                                style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: height * 0.015,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
              color: Colors.white,
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
