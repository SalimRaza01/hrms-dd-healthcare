// ignore_for_file: sort_child_properties_last, prefer_final_fields
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:hrms/presentation/screens/manual_punch_history.dart';
import 'package:hrms/presentation/screens/manual_punchin_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../odoo/task_details.dart';
import '../../widgets/holiday_widget.dart';
import '../../widgets/leave_balance_widget.dart';
import '../../widgets/manual_punch_card.dart';
import '../../widgets/no_task_widget.dart';
import '../../widgets/shift_time_widget.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DashboardScreen extends StatefulWidget {
  final String empID;
  const DashboardScreen(this.empID, {super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else if (hour < 20) {
      return "Good Evening";
    } else {
      return "Good Night";
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEEE dd MMM yyyy')
                                .format(DateTime.now())
                                .toString(),
                            style: TextStyle(
                              fontSize: height * 0.013,
                              color: AppColor.mainTextColor2,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.004,
                          ),
                          Text(
                            _authBox.get('employeeName') != null
                                ? "${getGreeting()}, ${_authBox.get('employeeName').split(' ').first}"
                                : '',
                            style: TextStyle(
                              fontSize: height * 0.018,
                              color: AppColor.mainTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15, top: 20),
                          child: Image.asset(
                            'assets/image/notificationIcon.png',
                            height: height * 0.04,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 20),
                          child: SizedBox(
                            height: height * 0.035,
                            child: CircleAvatar(
                              backgroundImage: _authBox.get('photo') == "NA" ||
                                      _authBox.get('photo') == null
                                  ? AssetImage(
                                      _authBox.get('gender') == 'Male'
                                          ? 'assets/image/MaleAvatar.png'
                                          : 'assets/image/FemaleAvatar.png',
                                    )
                                  : NetworkImage(_authBox.get('photo')!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      ShiftTImeWidget(),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      InkWell(
                                 onLongPress: () => showCupertinoModalBottomSheet(
                                expand: true,
                                context: context,
                                barrierColor:
                                    const Color.fromARGB(130, 0, 0, 0),
                                backgroundColor: Colors.transparent,
                                builder: (context) => PunchHistoryScreen(),
                              ),
                          // onTap: () => showCupertinoModalBottomSheet(
                          //       expand: true,
                          //       context: context,
                          //       barrierColor:
                          //           const Color.fromARGB(130, 0, 0, 0),
                          //       backgroundColor: Colors.transparent,
                          //       builder: (context) => ManualPunchInScreen(),
                          //     ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ManualPunchInScreen()));
                          },
                        child: PunchCardWidget()),

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

                      LeaveBalanceWidget(),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      HolidayWidget(),
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
                              ? NoTaskWidget()
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
                                                          taskID: task['id'])));
                                        },
                                        child: Card(
                                          color: AppColor.mainFGColor,
                                          elevation: 4,
                                          margin: EdgeInsets.all(0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          shadowColor: AppColor.shadowColor,
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
                                                            topRight:
                                                                Radius.circular(
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
                                                      CrossAxisAlignment.start,
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
                                                              fontSize: height *
                                                                  0.016,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: task['priority'] !=
                                                                              null &&
                                                                          task['priority']
                                                                              .isNotEmpty
                                                                      ? task['priority'][0] == 'High' ||
                                                                              task['priority'][0] ==
                                                                                  'high'
                                                                          ? const Color.fromARGB(
                                                                              255,
                                                                              249,
                                                                              177,
                                                                              177)
                                                                          : task['priority'][0] ==
                                                                                  'Low'
                                                                              ? const Color.fromARGB(
                                                                                  255, 226, 255, 193)
                                                                              : const Color.fromARGB(
                                                                                  116, 255, 198, 124)
                                                                      : Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
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
                                                              style: TextStyle(
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
                                                                            ? const Color.fromARGB(
                                                                                255,
                                                                                113,
                                                                                163,
                                                                                56)
                                                                            : const Color.fromARGB(
                                                                                255,
                                                                                227,
                                                                                129,
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
                                                          AppColor.mainBGColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      minHeight: 6.0,
                                                      color: task['stage_name'] ==
                                                              'Created'
                                                          ? const Color.fromARGB(
                                                              167, 76, 175, 79)
                                                          : task['stage_name'] ==
                                                                  'In Progress'
                                                              ? const Color.fromARGB(
                                                                  167, 76, 175, 79)
                                                              : task['stage_name'] ==
                                                                      'Hold'
                                                                  ? const Color.fromARGB(
                                                                      167,
                                                                      255,
                                                                      193,
                                                                      7)
                                                                  : task['stage_name'] ==
                                                                          'Review'
                                                                      ? const Color
                                                                          .fromARGB(
                                                                          167,
                                                                          33,
                                                                          149,
                                                                          243)
                                                                      : task['stage_name'] ==
                                                                              'Completed'
                                                                          ? const Color.fromARGB(
                                                                              167,
                                                                              76,
                                                                              175,
                                                                              79)
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
                                                                          [n][0]
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
                                                          showTotalCount: true,
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
                                                              width:
                                                                  width * 0.02,
                                                            ),
                                                            Text(
                                                              task[
                                                                  'stage_name'],
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
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
                      //                      SizedBox(
                      //   height: height * 0.015,
                      // ),
                      // AnnoucememtWidget(),
                      SizedBox(
                        height: height * 0.1,
                      ),
                    ],
                  ),
                )
              ],
            ),
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
