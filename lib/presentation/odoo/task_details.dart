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
          style: TextStyle(color: AppColor.mainFGColor, fontWeight: FontWeight.w400, fontSize: height * 0.02),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
                  return Card(
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
                                  color: AppColor.mainThemeColor, size: height * 0.022),
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
                                      ? const Color.fromARGB(150, 255, 17, 0)
                                      : priority == 'Medium'
                                          ? const Color.fromARGB(150, 255, 193, 7)
                                          : const Color.fromARGB(150, 76, 175, 79),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03, vertical: 3),
                                  child: Text(
                                    priority,
                                    style: TextStyle(
                                      color: AppColor.mainFGColor,
                                      fontSize: height * 0.015,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.02),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color.fromARGB(143, 255, 191, 0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03, vertical: 3),
                                  child: Text(
                                    task['stage_name'],
                                    style: TextStyle(
                                      color: AppColor.mainTextColor,
                                      fontSize: height * 0.015,
                                    ),
                                  ),
                                ),
                              ),
                               SizedBox(width: width * 0.02),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:  const Color.fromARGB(143, 255, 17, 0)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03, vertical: 3),
                                  child: Text(
                                   'Deadline: ${_formatDate(task['deadline_date'] ?? '')}',
                                    style: TextStyle(
                                      color: AppColor.mainFGColor,
                                      fontSize: height * 0.015,
                                    ),
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
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildAssigneeList(List<dynamic> assignees) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
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
      maxLines: 4,
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
        contentPadding: EdgeInsets.all(15),
      ),
    );
  }
}
