// ignore_for_file: sort_child_properties_last, prefer_final_fields
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/presentation/odoo/task_details.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'holiday_list.dart';
import 'package:calendar_timeline/calendar_timeline.dart';

class DashboardScreen extends StatefulWidget {
  final String empID;
  const DashboardScreen(this.empID, {super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<HolidayModel>> holidayList;
  final Box _authBox = Hive.box('authBox');
  List<Map<String, dynamic>> tasks = [];
  DateTime today = DateTime.now();
  bool isLoading = false;


  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    // _fetchTasks();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    holidayList = fetchHolidayList('HomeScreen');
  }

  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Future<void> _fetchTasks() async {
  //   try {
  //     final response = await Dio().get(getOdootasks);

  //     if (response.data['status'] == 'success') {
  //       final myTasks = List<Map<String, dynamic>>.from(response.data['tasks']);

  //       setState(() {
  //         tasks = myTasks.where((project) {
  //           bool isAssigneeMatch =
  //               project['assignees_emails'].contains(_authBox.get('email')!);

  //           bool isInProgress = project['stage_name'] == 'In Progress' ||
  //               project['stage_name'] == 'Created';

  //           return isAssigneeMatch && isInProgress;
  //         }).toList();
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });

  //     print('Error fetching tasks: $e');
  //   }
  // }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "🌞 Good Morning";
    } else if (hour < 17) {
      return "🌤️ Good Afternoon";
    } else if (hour < 20) {
      return "🌇 Good Evening";
    } else {
      return "🌙 Good Night";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.mainFGColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: CircleAvatar(
              backgroundImage:
                  _authBox.get('photo') == "NA" || _authBox.get('photo') == null
                      ? AssetImage(
                          _authBox.get('gender') == 'Male'
                              ? 'assets/image/MaleAvatar.png'
                              : 'assets/image/FemaleAvatar.png',
                        )
                      : NetworkImage(_authBox.get('photo')!),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _authBox.get('employeeName') != null
                    ? "${getGreeting()}, ${_authBox.get('employeeName').split(' ').first}"
                    : '',
                style: TextStyle(
                  fontSize: height * 0.017,
                  color: AppColor.mainTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: height * 0.004,
              ),
              Text(
                _authBox.get('employeeDesign') != null
                    ? _authBox.get('employeeId') == '413'
                        ? 'Flutter & UI/UX Developer'
                        : _authBox.get('employeeDesign')!
                    : '',
                style: TextStyle(
                  fontSize: height * 0.013,
                  color: AppColor.mainTextColor2,
                ),
              )
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.asset(
                'assets/image/read.png',
                height: height * 0.033,
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
                        future: fetchShiftTime(widget.empID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child:
                                  LoadingAnimationWidget.threeArchedCircle(
                                color: AppColor.mainTextColor2,
                                size: height * 0.03,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Card(
                              color: AppColor.mainFGColor,
                              elevation: 4,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: Text('No Data Found')),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final shift = snapshot.data!;
          
                            return Card(
                                color: AppColor.mainFGColor,
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
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${shift.startTime} AM ',
                                            style: TextStyle(
                                              fontSize: height * 0.015,
                                              color: Color.fromARGB(
                                                  141, 0, 0, 0),
                                            ),
                                          ),
                                          Text(
                                            '- ',
                                            style: TextStyle(
                                              fontSize: height * 0.015,
                                              color: Color.fromARGB(
                                                  141, 0, 0, 0),
                                            ),
                                          ),
                                          Text(
                                            '${shift.endTime} PM',
                                            style: TextStyle(
                                              fontSize: height * 0.015,
                                              color: Color.fromARGB(
                                                  141, 0, 0, 0),
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
                      height: height * 0.015,
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => OdooDashboard()));
                    //   },
                    //   child: Container(
                    //       width: width,
                    //       decoration: BoxDecoration(
                    //           gradient: LinearGradient(
                    //             begin: Alignment.topLeft,
                    //             end: Alignment.centerRight,
                    //             colors: [
                    //               AppColor.primaryThemeColor,
                    //               AppColor.mainThemeColor,
                    //             ],
                    //           ),
                    //           border: Border.all(
                    //               color: const Color.fromARGB(14, 0, 0, 0)),
                    //           borderRadius: BorderRadius.circular(10)),
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: 10, vertical: 12),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.check_circle_outline_outlined,
                    //                   color: AppColor.mainFGColor,
                    //                   size: height * 0.022,
                    //                 ),
                    //                 SizedBox(
                    //                   width: width * 0.02,
                    //                 ),
                    //                 Text(
                    //                   'View Task Dashbaord',
                    //                   style: TextStyle(
                    //                       fontSize: height * 0.015,
                    //                       color: AppColor.mainFGColor,
                    //                       fontWeight: FontWeight.w400),
                    //                 ),
                    //               ],
                    //             ),
                    //             Icon(
                    //               Icons.arrow_forward_ios_outlined,
                    //               color: AppColor.mainFGColor,
                    //               size: height * 0.018,
                    //             ),
                    //           ],
                    //         ),
                    //       )),
                    // ),
                    //   SizedBox(
                    //   height: height * 0.015,
                    // ),
                    Card(
                      color: AppColor.mainFGColor,
                      elevation: 4,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: CalendarTimeline(
                          height: height * 0.075,
                          dayNameFontSize: 10,
                          fontSize: 18,
                          showYears: false,
                          initialDate: today,
                          firstDate: today.subtract(Duration(days: 30)),
                          lastDate: today.add(Duration(days: 30)),
                          onDateSelected: (date) => print(date),
                          leftMargin: 0,
                          monthColor: Colors.blueGrey,
                          dayColor: Colors.blueGrey,
                          activeDayColor: Colors.amberAccent,
                          activeBackgroundDayColor:
                              AppColor.mainThemeColor,
                          locale: 'en_ISO',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.015,
                    ),
          
                    SizedBox(
                      width: width,
                      child: Card(
                        color: AppColor.mainFGColor,
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
                                    fontSize: height * 0.015,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              FutureBuilder<LeaveBalance>(
                                  future: fetchLeaves(widget.empID),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: LoadingAnimationWidget
                                            .threeArchedCircle(
                                          color: AppColor.mainTextColor2,
                                          size: height * 0.03,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text('No Data Found'));
                                    } else if (snapshot.hasData) {
                                      final leave = snapshot.data!;
          
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          leaveWidget(height, width,
                                              'Casual', leave.casualLeave),
                                          leaveWidget(
                                              height,
                                              width,
                                              'Medical',
                                              leave.medicalLeave),
                                          leaveWidget(height, width,
                                              'Earned', leave.earnedLeave),
                                        ],
                                      );
                                    } else {
                                      return Text('No data Found');
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upcoming Holiday',
                              style: TextStyle(
                                  fontSize: height * 0.015,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            FutureBuilder<List<HolidayModel>>(
                              future: holidayList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: LoadingAnimationWidget
                                          .threeArchedCircle(
                                    color: AppColor.mainTextColor2,
                                    size: height * 0.03,
                                  ));
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('No Holiday List Found'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text('No Holiday available.'));
                                } else {
                                  List<HolidayModel> items = snapshot.data!;
          
                                  HolidayModel item = items[0];
          
                                  final newDate =
                                      DateTime.parse(item.holidayDate);
          
                                  return InkWell(
                                    onTap: () =>
                                        showCupertinoModalBottomSheet(
                                      expand: true,
                                      context: context,
                                      barrierColor: const Color.fromARGB(
                                          130, 0, 0, 0),
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
                                                  color: AppColor
                                                      .mainThemeColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  )),
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 15,
                                                  vertical: 4,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      DateFormat('dd')
                                                          .format(newDate)
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize:
                                                            height * 0.02,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor
                                                            .mainFGColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('EEE')
                                                          .format(newDate)
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: height *
                                                              0.014,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                          color: AppColor
                                                              .mainFGColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  vertical: 4,
                                                  horizontal: 20),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  SizedBox(
                                                    width: width / 2,
                                                    child: Text(
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      item.holidayName,
                                                      style: TextStyle(
                                                          fontSize: height *
                                                              0.015,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                          color: AppColor
                                                              .mainTextColor),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Text(
                                                    DateFormat('MMMM')
                                                        .format(newDate)
                                                        .toString(),
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
                      height: height * 0.015,
                    ),
                    isLoading
                        ? Center(
                            child: LoadingAnimationWidget.threeArchedCircle(
                            color: AppColor.mainTextColor2,
                            size: height * 0.03,
                          ))
                        : tasks.isEmpty
                            ? NoTaskWidget(height: height)
                            : Container(
                                width: width,
                                height: height * 0.225,
                                child: ListView.builder(
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    final task = tasks[tasks.length - 1];
          
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TaskDetails(
                                                        taskID:
                                                            task['id'])));
                                      },
                                      child: Card(
                                        color: AppColor.mainFGColor,
                                        elevation: 4,
                                        margin: EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        shadowColor:
                                            Colors.black.withOpacity(0.1),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: width,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          topRight: Radius
                                                              .circular(
                                                                  10))),
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 5.0),
                                                child: Text(
                                                  'Current Task ',
                                                  style: TextStyle(
                                                      fontSize:
                                                          height * 0.015,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: width / 1.5,
                                                        child: Text(
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 2,
                                                          task['name']
                                                              .toString()
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            color: AppColor
                                                                .mainTextColor,
                                                            fontSize:
                                                                height *
                                                                    0.016,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                            color: task['priority'] != null && task['priority'].isNotEmpty
                                                                ? task['priority'][0] == 'High' || task['priority'][0] == 'high'
                                                                    ? const Color.fromARGB(255, 249, 177, 177)
                                                                    : task['priority'][0] == 'Low'
                                                                        ? const Color.fromARGB(255, 226, 255, 193)
                                                                        : const Color.fromARGB(116, 255, 198, 124)
                                                                : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(5)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8,
                                                                  vertical:
                                                                      5),
                                                          child: Text(
                                                            task['priority'] !=
                                                                        null &&
                                                                    task['priority']
                                                                        .isNotEmpty
                                                                ? task['priority']
                                                                        [0]
                                                                    .toString()
                                                                    .toUpperCase()
                                                                : 'Not Set',
                                                            style:
                                                                TextStyle(
                                                              fontSize:
                                                                  height *
                                                                      0.014,
                                                              color: task['priority'] !=
                                                                          null &&
                                                                      task['priority']
                                                                          .isNotEmpty
                                                                  ? task['priority'][0] == 'High' ||
                                                                          task['priority'][0] ==
                                                                              'high'
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          229,
                                                                          45,
                                                                          45)
                                                                      : task['priority'][0] ==
                                                                              'Low'
                                                                          ? const Color.fromARGB(255, 113, 163,
                                                                              56)
                                                                          : const Color.fromARGB(255, 227, 129,
                                                                              0)
                                                                  : Colors
                                                                      .grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    task['deadline_date'] ==
                                                            'False'
                                                        ? 'Deadline: Not Provided'
                                                        : 'Deadline: ${_formatDate(task['deadline_date'])}',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize:
                                                          height * 0.014,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.02,
                                                  ),
                                                  LinearProgressIndicator(
                                                    backgroundColor:
                                                        AppColor
                                                            .mainBGColor,
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(20),
                                                    minHeight: 6.0,
                                                    color: task['stage_name'] ==
                                                            'Created'
                                                        ? const Color.fromARGB(
                                                            167, 76, 175, 79)
                                                        : task['stage_name'] ==
                                                                'In Progress'
                                                            ? const Color
                                                                .fromARGB(
                                                                167, 76, 175, 79)
                                                            : task['stage_name'] ==
                                                                    'Hold'
                                                                ? const Color
                                                                    .fromARGB(
                                                                    167,
                                                                    255,
                                                                    193,
                                                                    7)
                                                                : task['stage_name'] ==
                                                                        'Review'
                                                                    ? const Color.fromARGB(
                                                                        167,
                                                                        33,
                                                                        149,
                                                                        243)
                                                                    : task['stage_name'] == 'Completed'
                                                                        ? const Color.fromARGB(167, 76, 175, 79)
                                                                        : task['stage_name'] == 'Running Late'
                                                                            ? const Color.fromARGB(167, 244, 67, 54)
                                                                            : const Color.fromARGB(167, 76, 175, 79),
                                                    value: task['stage_name'] ==
                                                            'Created'
                                                        ? 0.1
                                                        : task['stage_name'] ==
                                                                'In Progress'
                                                            ? 0.3
                                                            : task['stage_name'] ==
                                                                    'Hold'
                                                                ? 0.5
                                                                : task['stage_name'] ==
                                                                        'Review'
                                                                    ? 0.7
                                                                    : task['stage_name'] ==
                                                                            'Completed'
                                                                        ? 1.0
                                                                        : task['stage_name'] == 'Running Late'
                                                                            ? 0.1
                                                                            : 0.0,
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.02,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      FlutterImageStack
                                                          .widgets(
                                                        children: [
                                                          for (var n = 0;
                                                              n <
                                                                  task['assignees_emails']
                                                                      .length;
                                                              n++)
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      235,
                                                                      244,
                                                                      254),
                                                              child: Text(
                                                                task['assignees_emails']
                                                                        [
                                                                        n][0]
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.018,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            )
                                                        ],
                                                        showTotalCount:
                                                            true,
                                                        itemBorderColor:
                                                            Colors.white,
                                                        totalCount: task[
                                                                'assignees_emails']
                                                            .length,
                                                        itemRadius: 40,
                                                        itemBorderWidth: 2,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons
                                                                .dial,
                                                            color: const Color
                                                                .fromARGB(
                                                                177,
                                                                158,
                                                                158,
                                                                158),
                                                          ),
                                                          SizedBox(
                                                            width: width *
                                                                0.02,
                                                          ),
                                                          Text(
                                                            task[
                                                                'stage_name'],
                                                            style:
                                                                TextStyle(
                                                              color: Colors
                                                                  .grey,
                                                              fontSize:
                                                                  height *
                                                                      0.017,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Announcement',
                              style: TextStyle(
                                  fontSize: height * 0.015,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: height * 0.005,
                            ),
                            Image.asset(
                                fit: BoxFit.fitWidth,
                                width: width,
                                'assets/image/annoucementImage.png'),
                            SizedBox(
                              height: height * 0.005,
                            ),
                            Text(
                              'No announcements have been published yet. Keep an eye out for future updates.',
                              style: TextStyle(
                                fontSize: height * 0.012,
                                color: Color.fromARGB(141, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
      width: width * 0.27,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(14, 0, 0, 0)),
            color: AppColor.mainBGColor,
            borderRadius: BorderRadius.circular(10)),
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
}

class NoTaskWidget extends StatelessWidget {
  const NoTaskWidget({
    super.key,
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppColor.mainFGColor,
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
                'Today Task',
                style: TextStyle(
                    fontSize: height * 0.015,
                    color: AppColor.mainTextColor,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: height * 0.005,
              ),
              Text(
                'The tasks assigned to you for today',
                style: TextStyle(
                  fontSize: height * 0.012,
                  color: AppColor.mainTextColor2,
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        'assets/image/Frame.png',
                        height: height * 0.08,
                      )),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Center(
                child: Text(
                  'No Tasks Assigned',
                  style: TextStyle(
                      fontSize: height * 0.015,
                      color: AppColor.mainTextColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Text(
                'It looks like you don’t have any tasks assigned to you right now. Don’t worry, this space will be updated as new tasks become available.',
                style: TextStyle(
                  fontSize: height * 0.012,
                  color: AppColor.mainTextColor2,
                ),
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
