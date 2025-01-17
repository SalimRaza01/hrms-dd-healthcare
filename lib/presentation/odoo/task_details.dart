import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/api/api.dart';
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
  final Box _authBox = Hive.box('authBox');
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
              .where((task) => task['id'] == widget.taskID)
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
                                    : task['stage_name'] == 'Hold'
                                        ? 2
                                        : task['stage_name'] == 'Review'
                                            ? 2
                                            : task['stage_name'] == 'Completed'
                                                ? 3
                                                : task['stage_name'] ==
                                                        'Running Late'
                                                    ? 3
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
                              task['stage_name'] == 'Hold'
                                  ? EasyStep(
                                      icon: Icon(CupertinoIcons.hand_raised),
                                      title: 'Hold',
                                    )
                                  : EasyStep(
                                      icon:
                                          Icon(CupertinoIcons.doc_text_search),
                                      title: 'Review',
                                    ),
                              task['stage_name'] == 'Running Late'
                                  ? EasyStep(
                                      icon: Icon(CupertinoIcons.timer),
                                      title: 'Late',
                                    )
                                  : EasyStep(
                                      icon: Icon(CupertinoIcons.flag),
                                      title: 'Completed',
                                    )
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
                        //for user or assigness
                        Visibility(
                          visible: task['task_creator_email'] ==
                              _authBox.get('email'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: task['stage_name'] == 'Hold',
                                  child: taskActionButtons(
                                      height,
                                      width,
                                      CupertinoIcons.multiply_square_fill,
                                      'Cancel',
                                      Colors.red,
                                      task['id']),
                                ),
                                Visibility(
                                  visible: task['stage_name'] == 'Redo' ||
                                      task['stage_name'] == 'Running Late' ||
                                      task['stage_name'] == 'Review',
                                  child: taskActionButtons(
                                      height,
                                      width,
                                      CupertinoIcons.flag_fill,
                                      'Completed',
                                      Colors.green,
                                      task['id']),
                                ),
                                Visibility(
                                  visible: task['stage_name'] == 'Review',
                                  child: taskActionButtons(
                                      height,
                                      width,
                                      CupertinoIcons.arrow_up_left_circle_fill,
                                      'Redo',
                                      Colors.red,
                                      task['id']),
                                ),
                                Visibility(
                                  visible: task['stage_name'] == 'Created' ||
                                      task['stage_name'] == 'Redo' ||
                                      task['stage_name'] == 'Running Late' ||
                                      task['stage_name'] == 'Completed' ||
                                      task['stage_name'] == 'Cancel' ||
                                      task['stage_name'] == 'In Progress',
                                  child: taskActionButtons(
                                      height,
                                      width,
                                      CupertinoIcons.hand_raised_fill,
                                      'Hold',
                                      Colors.amber,
                                      task['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: task['task_creator_email'] !=
                              _authBox.get('email'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: task['stage_name'] == 'Created' ||
                                      task['stage_name'] == 'Redo' ||
                                      task['stage_name'] == 'Running Late' ||
                                      task['stage_name'] == 'Hold' ||
                                      task['stage_name'] == 'Cancel',
                                  child: taskActionButtons(
                                      height,
                                      width,
                                      CupertinoIcons.play_fill,
                                      'Start Task',
                                      Colors.green,
                                      task['id']),
                                ),
                                Visibility(
                                  visible:
                                      task['stage_name'] == 'In Progress' ||
                                          task['stage_name'] == 'Running Late',
                                  child: taskActionButtons(
                                      height,
                                      width,
                                      CupertinoIcons.doc_text_search,
                                      'Send for Review',
                                      Colors.blue,
                                      task['id']),
                                ),
                                Visibility(
                                  visible: task['stage_name'] == 'Hold',
                                  child: taskActionButtons(
                                      height,
                                      width,
                                      CupertinoIcons.multiply_square_fill,
                                      'Cancel',
                                      Colors.red,
                                      task['id']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  taskActionButtons(double height, double width, IconData icon, String text,
      Color? color, int taskID) {
    return InkWell(
      onTap: () async {
        await changeTaskStage(
            context,
            taskID,
            text == 'Start Task'
                ? 'In Progress'
                : text == 'Send for Review'
                    ? 'Review'
                    : text);
        await _fetchTasks();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: height * 0.018,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: width * 0.02,
                    ),
                    Text(
                      text,
                      style: TextStyle(
                          color: AppColor.mainFGColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )),
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
