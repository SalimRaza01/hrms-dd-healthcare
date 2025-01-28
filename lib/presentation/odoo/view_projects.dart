// ignore_for_file: sort_child_properties_last

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/provider/provider.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hrms/presentation/odoo/create_task.dart';
import 'package:hrms/presentation/odoo/edit_task.dart';
import 'package:hrms/presentation/odoo/task_details.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class ViewProjects extends StatefulWidget {
  final String projectName;
  final int projectID;
  const ViewProjects(
      {super.key, required this.projectName, required this.projectID});

  @override
  State<ViewProjects> createState() => _ViewProjectsState();
}

class _ViewProjectsState extends State<ViewProjects> {
  final Box _authBox = Hive.box('authBox');
  late String projectName;
  late int projectID;
  // String _selectedText = 'All Task';
  Color? activeColor;
  Color? activeText;
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks(widget.projectID);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _fetchTasks(int projectID) async {
    try {
      final response = await Dio().get(getOdootasks);

      if (response.statusCode == 200) {
        final myTasks = List<Map<String, dynamic>>.from(response.data['tasks']);
        setState(() {
          tasks = myTasks
              .where((project) => project['project_id'] == projectID)
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: AppColor.mainBGColor,
        appBar: AppBar(
          backgroundColor: AppColor.mainThemeColor,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColor.mainFGColor,
            ),
          ),
          title: Text(
            widget.projectName,
            style: TextStyle(
                color: AppColor.mainFGColor,
                fontWeight: FontWeight.w400,
                fontSize: height * 0.02),
          ),
          centerTitle: true,
        ),
        body: Consumer<TaskProvider>(builder: (context, value, child) {
          if (value.taskupdated == true) {
            _fetchTasks(widget.projectID);
            Future.delayed(Duration(milliseconds: 1500), () {
              Provider.of<TaskProvider>(context, listen: false)
                  .taskupdatedStatus(false);
            });
          }
          return SizedBox(
            height: height,
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card(
                  //   color: AppColor.mainFGColor,
                  //   elevation: 4,
                  //   margin: EdgeInsets.all(0),
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   shadowColor: Colors.black.withOpacity(0.1),
                  //   child: Padding(
                  //     padding: EdgeInsets.all(4),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         _selectButton('All Task', height, width),
                  //         _selectButton('Pending', height, width),
                  //         _selectButton('Completed', height, width),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Text(
                    "Tasks",
                    style: TextStyle(
                        fontSize: height * 0.018,
                        color: AppColor.mainTextColor,
                        fontWeight: FontWeight.w500),
                  ),
                     SizedBox(
                                            height: height * 0.01,
                                          ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              String priority = task['priority'] != null &&
                                      task['priority'].isNotEmpty
                                  ? task['priority']
                                      .toString()
                                      .replaceAll('[', '')
                                      .replaceAll(']', '')
                                  : 'Not Set';

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                  onLongPress: (task['task_creator_email'] ==
                                          _authBox.get('email'))
                                      ? () => showCupertinoModalBottomSheet(
                                          expand: true,
                                          context: context,
                                          barrierColor: const Color.fromARGB(
                                              130, 0, 0, 0),
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => EditTask(
                                                taskID: task['id'],
                                                taskname: task['name'],
                                                description:
                                                    task['task_description'],
                                                priority: priority,
                                                taskDeadline:
                                                    task['deadline_date'],
                                                alreadyAssignedEmails:
                                                    List<String>.from(task[
                                                        'assignees_emails']),
                                              ))
                                      : null,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TaskDetails(taskID: task['id']),
                                      ),
                                    );
                                  },
                                  child:Card(
                                    color: AppColor.mainFGColor,
                                    elevation: 4,
                                    margin: EdgeInsets.all(0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: width / 1.5,
                                                child: Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  task['name'],
                                                  style: TextStyle(
                                                    color:
                                                        AppColor.mainTextColor,
                                                    fontSize: height * 0.016,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: task['priority']
                                                                    [0] ==
                                                                'High' ||
                                                            task['priority']
                                                                    [0] ==
                                                                'high'
                                                        ? const Color.fromARGB(
                                                            255, 249, 177, 177)
                                                        : task['priority'][0] ==
                                                                'Low'
                                                            ? const Color.fromARGB(
                                                                255,
                                                                226,
                                                                255,
                                                                193)
                                                            : const Color
                                                                .fromARGB(116,
                                                                255, 198, 124),
                                                    borderRadius:
                                                        BorderRadius.circular(5)),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                                  child: Text(
                                                    task['priority'][0]
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: height * 0.014,
                                                      color: task['priority']
                                                                      [0] ==
                                                                  'High' ||
                                                              task['priority']
                                                                      [0] ==
                                                                  'high'
                                                          ? const Color.fromARGB(
                                                              255, 229, 45, 45)
                                                          : task['priority'][0] ==
                                                                  'Low'
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  113, 163, 56)
                                                              : const Color
                                                                  .fromARGB(255,
                                                                  227, 129, 0),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Deadline: ${_formatDate(task['deadline_date'] ?? '')}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: height * 0.014,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(
                                            height: height * 0.02,
                                          ),
                                          LinearProgressIndicator(
                                            backgroundColor: AppColor.mainBGColor,
                                            borderRadius: BorderRadius.circular(20),
                                            minHeight: 6.0,
                                            color: task['stage_name'] ==
                                                    'Created'
                                                ? const Color.fromARGB(167, 76, 175, 79)
                                                : task['stage_name'] ==
                                                        'In Progress'
                                                    ? const Color.fromARGB(167, 76, 175, 79)
                                                    : task['stage_name'] ==
                                                            'Hold'
                                                        ? const Color.fromARGB(167, 255, 193, 7)
                                                        : task['stage_name'] ==
                                                                'Review'
                                                            ? const Color.fromARGB(167, 33, 149, 243)
                                                            : task['stage_name'] ==
                                                                    'Completed'
                                                                ? const Color.fromARGB(167, 76, 175, 79)
                                                                : task['stage_name'] ==
                                                                        'Running Late'
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
                                                                : task['stage_name'] ==
                                                                        'Running Late'
                                                                    ? 0.1
                                                                    : 0.0,
                                          ),
                                          SizedBox(
                                            height: height * 0.02,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              FlutterImageStack.widgets(
                                                children: [
                                                  for (var n = 0;
                                                      n <
                                                          task['assignees_emails']
                                                              .length;
                                                      n++)
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              235,
                                                              244,
                                                              254),
                                                      child: Text(
                                                        task['assignees_emails']
                                                                [n][0]
                                                            .toString()
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          fontSize:
                                                              height * 0.018,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    )
                                                ],
                                                showTotalCount: true,
                                                itemBorderColor: Colors.white,
                                                totalCount:
                                                    task['assignees_emails']
                                                        .length,
                                                itemRadius: 40,
                                                itemBorderWidth: 2,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .dial,
                                                    color: const Color.fromARGB(
                                                        177, 158, 158, 158),
                                                  ),
                                                  SizedBox(
                                                    width: width * 0.02,
                                                  ),
                                                  Text(
                                                    task['stage_name'],
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: height * 0.017,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
        }),
        floatingActionButton: _authBox.get('role') == 'Manager'
            ? FloatingActionButton.extended(
                backgroundColor: AppColor.mainThemeColor,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateTask(projectID: widget.projectID)),
                ),
                label: Text(
                  'Create Task',
                  style: TextStyle(color: AppColor.mainFGColor),
                ),
              )
            : null);
  }

  // Widget _selectButton(String text, double height, double width) {
  //   Color activeColor;
  //   Color activeText;

  //   if (_selectedText == text) {
  //     activeColor = AppColor.mainThemeColor;
  //     activeText = AppColor.mainFGColor;
  //   } else {
  //     activeColor = Colors.transparent;
  //     activeText = const Color.fromARGB(141, 0, 0, 0);
  //   }

  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _selectedText = text;
  //       });
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         color: activeColor,
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 10),
  //         child: Text(
  //           text,
  //           style: TextStyle(
  //             color: activeText,
  //             fontSize: height * 0.015,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
