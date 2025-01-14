import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class TaskDetails extends StatefulWidget {
  final int taskID;
  const TaskDetails({super.key, required this.taskID});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  late int taskID;
  TextEditingController noteController = TextEditingController();
  List<String> assignees = [];
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await Dio().get(getOdootasks);
      print(response);

      if (response.statusCode == 200) {
        final myTasks = List<Map<String, dynamic>>.from(response.data['tasks']);
        setState(() {
          tasks = myTasks
              .where((project) => project['id'] == widget.taskID)
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print('Error fetching tasks: $e');
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
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: AppColor.mainFGColor),
        ),
        title: Text(
          'Task Details',
          style: TextStyle(
              color: AppColor.mainFGColor,
              fontWeight: FontWeight.w400,
              fontSize: height * 0.02),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: tasks.map((task) {
                    String priority =
                        task['priority'] != null && task['priority'].isNotEmpty
                            ? task['priority']
                                .toString()
                                .replaceAll('[', '')
                                .replaceAll(']', '')
                            : 'Not Set';
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: EasyStepper(
                            disableScroll: true,
                            enableStepTapping: false,
                            stepShape: StepShape.circle,
                            activeStep: task['stage_name'] == 'Created'
                                ? 0
                                : task['stage_name'] == 'In Progress'
                                    ? 1
                                    : task['stage_name'] == 'On Hold'
                                        ? 2
                                        : task['stage_name'] == 'Review'
                                            ? 2
                                            : task['stage_name'] == 'Completed'
                                                ? 3
                                                : task['stage_name'] ==
                                                        'Running Late'
                                                    ? 4
                                                    : 0,
                            lineStyle: const LineStyle(
                              lineLength: 50,
                              lineThickness: 1,
                              lineSpace: 5,
                            ),
                            stepRadius: 15,
                            finishedStepBackgroundColor:
                                AppColor.mainThemeColor,
                            finishedStepTextColor: AppColor.mainThemeColor,
                            finishedStepBorderColor: AppColor.mainThemeColor,
                            activeStepIconColor:
                                const Color.fromARGB(255, 0, 163, 5),
                            activeStepBorderColor:
                                const Color.fromARGB(255, 0, 163, 5),
                            activeStepTextColor:
                                const Color.fromARGB(255, 0, 163, 5),
                            unreachedStepIconColor: AppColor.mainTextColor2,
                            unreachedStepBorderColor: AppColor.mainTextColor2,
                            unreachedStepTextColor: AppColor.mainTextColor2,
                            showLoadingAnimation: false,
                            steps: [
                              EasyStep(
                                icon: Icon(Icons.create),
                                title: 'Created',
                              ),
                              EasyStep(
                                icon: Icon(CupertinoIcons.timelapse),
                                title: 'Progress',
                              ),
                              task['stage_name'] == 'On Hold'
                                  ? EasyStep(
                                      icon: Icon(CupertinoIcons.hand_raised),
                                      title: 'Hold',
                                    )
                                  : EasyStep(
                                      icon:
                                          Icon(CupertinoIcons.doc_text_search),
                                      title: 'Review',
                                    ),
                              EasyStep(
                                icon: Icon(CupertinoIcons.flag),
                                title: 'Completed',
                              ),
                              EasyStep(
                                icon: Icon(CupertinoIcons.timer),
                                title: 'Late',
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: AppColor.mainFGColor,
                          elevation: 5,
                          margin: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.circle_outlined,
                                        color: AppColor.mainThemeColor,
                                        size: height * 0.022),
                                    SizedBox(width: width * 0.02),
                                    SizedBox(
                                      width: width / 1.5,
                                      child: Text(
                                        task['name'].toString().toUpperCase(),
                                        style: TextStyle(
                                          color: AppColor.mainTextColor,
                                          fontSize: height * 0.016,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.015),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: priority == 'High'
                                            ? const Color.fromARGB(
                                                150, 255, 17, 0)
                                            : priority == 'Medium'
                                                ? const Color.fromARGB(
                                                    150, 255, 193, 7)
                                                : const Color.fromARGB(
                                                    150, 76, 175, 79),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.02,
                                            vertical: 3),
                                        child: Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .shield_lefthalf_fill,
                                              size: height * 0.018,
                                              color: priority == 'High'
                                                  ? Colors.white
                                                  : priority == 'Medium'
                                                      ? AppColor.mainTextColor
                                                      : Colors.white,
                                            ),
                                            SizedBox(
                                              width: width * 0.02,
                                            ),
                                            Text(
                                              priority,
                                              style: TextStyle(
                                                color: priority == 'High'
                                                    ? Colors.white
                                                    : priority == 'Medium'
                                                        ? AppColor.mainTextColor
                                                        : Colors.white,
                                                fontSize: height * 0.015,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromARGB(
                                              143, 255, 17, 0)),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.02,
                                            vertical: 3),
                                        child: Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.flag_fill,
                                              size: height * 0.018,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: width * 0.02,
                                            ),
                                            Text(
                                              'Deadline: ${_formatDate(task['deadline_date'] ?? '')}',
                                              style: TextStyle(
                                                color: AppColor.mainFGColor,
                                                fontSize: height * 0.015,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.015),
                                TextField(
                                  controller: noteController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: 'Description',
                                    hintStyle: TextStyle(
                                      color: AppColor.mainTextColor2,
                                      fontSize: height * 0.016,
                                    ),
                                    filled: true,
                                    fillColor: AppColor.mainBGColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.all(15),
                                  ),
                                ),
                                SizedBox(height: height * 0.015),
                                Text(
                                  'Assignee :',
                                  style: TextStyle(
                                    color: AppColor.mainTextColor,
                                    fontSize: height * 0.016,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: height * 0.010),
                                _buildAssigneeList(task['assignees_emails']),
                                SizedBox(height: height * 0.015),
                                Text(
                                  'Add a Note:',
                                  style: TextStyle(
                                    color: AppColor.mainTextColor,
                                    fontSize: height * 0.016,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: height * 0.010),
                                _buildNoteField(height),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.02,),
                         _activityCard(
                          context,
                          userName: 'Nadeem Akhtar',
                          timeAgo: '4 days ago',
                          mainContent: 'None → Task Created',
                          subContent: 'Created Date: 10/01/2025 15:36:12',
                        ),
                        _activityCard(
                          context,
                          userName: 'Salim Raza',
                          timeAgo: '4 days ago',
                          mainContent: 'Running Late → Review',
                          subContent: 'Submission Date: 10/01/2025 15:36:12',
                        ),
                       
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _activityCard(
    BuildContext context, {
    required String userName,
    required String timeAgo,
    required String mainContent,
    required String subContent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  mainContent,
                  style: TextStyle(fontSize: 14),
                ),
                if (subContent.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    subContent,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeList(List<dynamic> assignees) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 1.0,
        children: assignees.map((user) {
          return Chip(
            backgroundColor: AppColor.mainThemeColor,
            label: Text(
              user ?? 'Unknown User',
              style: TextStyle(color: AppColor.mainFGColor),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoteField(double height) {
    return TextField(
      controller: noteController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Write your feedback or note...',
        hintStyle: TextStyle(
          color: AppColor.mainTextColor2,
          fontSize: height * 0.016,
        ),
        filled: true,
        fillColor: AppColor.mainBGColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }
}

enum StepEnabling { sequential, individual }
