import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hrms/presentation/odoo/create_task.dart';
import 'package:hrms/presentation/odoo/task_details.dart';
import 'package:intl/intl.dart';

class ViewProjects extends StatefulWidget {
  final String projectName;
  final int projectID;
  const ViewProjects(
      {super.key, required this.projectName, required this.projectID});

  @override
  State<ViewProjects> createState() => _ViewProjectsState();
}

class _ViewProjectsState extends State<ViewProjects> {
  late String projectName;
  late int projectID;
  String _selectedText = 'All Task';
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
      print(response);

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
      body: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      _selectButton('All Task', height, width),
                      _selectButton('Pending', height, width),
                      _selectButton('Completed', height, width),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TaskDetails(taskID: task['id']),
                                  ),
                                );
                              },
                              child: Card(
                                color: AppColor.mainFGColor,
                                elevation: 4,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadowColor: Colors.black.withOpacity(0.1),
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              task['stage_name'] == "Completed"
                                                  ? Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: Colors.green,
                                                      size: height * 0.018,
                                                    )
                                                  : Icon(
                                                      Icons.circle_outlined,
                                                      color: AppColor
                                                          .mainThemeColor,
                                                      size: height * 0.018,
                                                    ),
                                              SizedBox(width: width * 0.02),
                                              SizedBox(
                                                width: width / 1.5,
                                                child: Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  task['name'],
                                                  style: TextStyle(
                                                    color:
                                                        AppColor.mainTextColor,
                                                    fontSize: height * 0.016,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Container(
                                              width: width,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        14, 0, 0, 0)),
                                                color: AppColor.mainBGColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  task['description'],
                                                  style: TextStyle(
                                                    color:
                                                        AppColor.mainTextColor2,
                                                    fontSize: height * 0.015,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Deadline: ${_formatDate(task['deadline_date'] ?? '')}',
                                            style: TextStyle(
                                              color: AppColor.mainTextColor2,
                                              fontSize: height * 0.015,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    task['stage_name'] == "Completed"
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 15.0),
                                              child: Text(
                                                task['stage_name'],
                                                style: TextStyle(
                                                  color: AppColor.mainFGColor,
                                                  fontSize: height * 0.015,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: priority == 'High' || priority == 'high'
                                                  ? Colors.red
                                                  : priority == 'Medium'
                                                      ? Colors.amber
                                                      : Colors.green,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 30.0),
                                              child: Text(
                                                priority,
                                                style: TextStyle(
                                                  color: AppColor.mainFGColor,
                                                  fontSize: height * 0.015,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColor.mainThemeColor,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CreateTask(projectID: widget.projectID)),
        ),
        label: Text(
          'Create Task',
          style: TextStyle(color: AppColor.mainFGColor),
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
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 10),
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
