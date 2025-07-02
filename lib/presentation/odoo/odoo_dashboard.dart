// ignore_for_file: sort_child_properties_last

// import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hrms/core/api/api_config.dart';
import '../../core/model/models.dart';
import '../../core/provider/provider.dart';
import 'edit_project.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import 'create_project.dart';
import 'task_details.dart';
import 'view_projects.dart';
import 'package:provider/provider.dart';

class OdooDashboard extends StatefulWidget {
  const OdooDashboard({super.key});
  @override
  State<OdooDashboard> createState() => _OdooDashboardState();
}

class _OdooDashboardState extends State<OdooDashboard> {
  final Box _authBox = Hive.box('authBox');
  late Future<List<OdooProjectList>> _projectsFuture;
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;
  bool showSearch = false;
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // _fetchTasks();
    // _projectsFuture = fetchOdooProjects();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Future<void> _fetchTasks() async {
  //   try {
  //     final response = await Dio().get(getOdootasks);

  //     if (response.statusCode == 200) {
  //       final myTasks = List<Map<String, dynamic>>.from(response.data['tasks']);
  //       setState(() {
  //         tasks = myTasks
  //             .where((project) =>
  //                 project['assignees_emails'].contains(_authBox.get('email')))
  //             .toList();
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

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
            'DASHBOARD',
            style: TextStyle(
                color: AppColor.mainFGColor,
                fontWeight: FontWeight.w400,
                fontSize: height * 0.02),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                showSearch ? Icons.cancel : Icons.search,
                color: AppColor.mainFGColor,
              ),
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                  if (!showSearch) {
                    searchQuery = '';
                  }
                });
              },
            ),
          ],
        ),
        body: Consumer<ProjectProvider>(builder: (context, value, child) {
          if (value.projectUpdated == true) {
            _projectsFuture = fetchOdooProjects();
            Future.delayed(Duration(milliseconds: 1500), () {
              Provider.of<ProjectProvider>(context, listen: false)
                  .projectUpdatedStatus(false);
            });
          }

          return SizedBox(
            height: height,
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Projects",
                    style: TextStyle(
                        fontSize: height * 0.018,
                        color: AppColor.mainTextColor,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    height: height * 0.18,
                    child: FutureBuilder<List<OdooProjectList>>(
                      future: _projectsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('No projects found.'));
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          List<OdooProjectList> items = snapshot.data!;
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              OdooProjectList item = items[index];

                              return InkWell(
                                onLongPress: (item.task_creator_email ==
                                        _authBox.get('email'))
                                    ? () => {
                                          _projectsFuture = fetchOdooProjects(),
                                          showCupertinoModalBottomSheet(
                                              expand: true,
                                              context: context,
                                              barrierColor:
                                                  const Color.fromARGB(
                                                      130, 0, 0, 0),
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) => EditProject(
                                                    projectID: item.id,
                                                    projectName: item.name,
                                                    alreadyAssignedEmails:
                                                        List<String>.from(item
                                                            .assignes_emails),
                                                  ))
                                        }
                                    : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewProjects(
                                        projectName: item.name,
                                        projectID: item.id,
                                        createDate:
                                            _formatDate(item.create_date),
                                        alreadyAssignedEmails:
                                            List<String>.from(
                                                item.assignes_emails),
                                      ),
                                    ),
                                  );
                                },
                                child: projectCard(
                                  height,
                                  width,
                                  index <= 8
                                      ? 'Project : 0${index + 1}'
                                      : 'Project : ${index + 1}',
                                  item.name,
                                  _formatDate(item.create_date),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(height: height * 0.01);
                            },
                          );
                        } else {
                          return Center(child: Text('No projects found.'));
                        }
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    "Assigned to you",
                    style: TextStyle(
                        fontSize: height * 0.018,
                        color: AppColor.mainTextColor,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: height * 0.01),
                  isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = tasks[index];
                              
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: InkWell(
                                       
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TaskDetails(
                                                  taskID: task['id']),
                                            ),
                                          );
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        task['name']
                                                            .toString()
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          color: AppColor
                                                              .mainTextColor,
                                                          fontSize:
                                                              height * 0.016,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: task['priority'] !=
                                                                      null &&
                                                                  task['priority']
                                                                      .isNotEmpty
                                                              ? task['priority'][0] ==
                                                                          'High' ||
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
                                                                          255,
                                                                          226,
                                                                          255,
                                                                          193)
                                                                      : const Color.fromARGB(
                                                                          116,
                                                                          255,
                                                                          198,
                                                                          124)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius.circular(5)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 5),
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
                                                                height * 0.014,
                                                            color: task['priority'] !=
                                                                        null &&
                                                                    task['priority']
                                                                        .isNotEmpty
                                                                ? task['priority'][0] ==
                                                                            'High' ||
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
                                                                : Colors.grey,
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
                                                  backgroundColor:
                                                      AppColor.mainBGColor,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
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
                                                                  ? const Color.fromARGB(
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                                              style: TextStyle(
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
                                                          CupertinoIcons.dial,
                                                          color: const Color
                                                              .fromARGB(177,
                                                              158, 158, 158),
                                                        ),
                                                        SizedBox(
                                                          width: width * 0.02,
                                                        ),
                                                        Text(
                                                          task['stage_name'],
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize:
                                                                height * 0.017,
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
                onPressed: () => {
                  showCupertinoModalBottomSheet(
                    expand: true,
                    context: context,
                    barrierColor: const Color.fromARGB(130, 0, 0, 0),
                    backgroundColor: Colors.transparent,
                    builder: (context) => CreateProject(),
                  )
                },
                label: Text(
                  'Create Project',
                  style: TextStyle(color: AppColor.mainFGColor),
                ),
              )
            : null);
  }

  projectCard(double height, double width, String projectCount,
      String projectName, String createDate) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Card(
        color: AppColor.mainFGColor,
        elevation: 5,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
            width: width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.secondaryThemeColor2,
                  AppColor.primaryThemeColor,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/image/projectImage.png',
                        height: 30,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      Text(
                        projectCount,
                        style: TextStyle(
                            color: AppColor.mainFGColor,
                            fontSize: height * 0.018,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    projectName.toString().toUpperCase(),
                    style: TextStyle(
                        color: AppColor.mainFGColor,
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    createDate,
                    style: TextStyle(
                        color: AppColor.mainFGColor,
                        fontSize: height * 0.015,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
