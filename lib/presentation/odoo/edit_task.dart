// // ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/provider/provider.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class EditTask extends StatefulWidget {
  final int taskID;
  final String taskname;
  final String description;
  final String priority;
  final String taskDeadline;
  final List<String> alreadyAssignedEmails;

  const EditTask({
    required this.taskID,
    required this.taskname,
    required this.description,
    required this.priority,
    required this.taskDeadline,
    required this.alreadyAssignedEmails,
  });

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController assigneeEmailController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  // late Future<List<OdooUserModel>> odooUser;
  // List<OdooUserModel> filteredUsers = [];
  // List<OdooUserModel> selectedUsers = [];
  String? selectedPriority;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    selectedPriority = widget.priority;
    // odooUser = fetchOddoUsers('search user');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> updateTask(
    BuildContext context,
    int taskID,
    String taskName,
    String taskDescription,
    String taskPriority,
    String taskEndDate,
    List<String> userEmails,
  ) async {
      print('$taskID, $taskName, $taskDescription, $taskPriority, $taskEndDate $userEmails');
    try {
      final response = await dio.put('$postOdootasks/$taskID', data: {
        "name": taskName,
        "assignees_emails": userEmails,
        "priority": taskPriority,
        "date_deadline": taskEndDate,
        "task_description": taskDescription,
      });

      if (response.data['result']['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task Updated Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isLoading = false;
        });
        Provider.of<TaskProvider>(context, listen: false)
            .taskupdatedStatus(true);
        Navigator.pop(
          context,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['result']['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task $error'),
          backgroundColor: Colors.red,
        ),
      );
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
          'UPDATE TASK',
          style: TextStyle(
              fontSize: height * 0.02,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Name:',
                style: TextStyle(
                    fontSize: height * 0.016, color: AppColor.mainTextColor2),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: taskNameController,
                  maxLines: null,
                  style: TextStyle(
                      fontSize: height * 0.016, color: AppColor.mainTextColor),
                  decoration: InputDecoration(
                    hintText: widget.taskname,
                    hintStyle: TextStyle(fontSize: height * 0.016),
                    filled: true,
                    fillColor: AppColor.mainFGColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              Text(
                'Task Description:',
                style: TextStyle(
                    fontSize: height * 0.016, color: AppColor.mainTextColor2),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: height * 0.016, color: AppColor.mainTextColor),
                  decoration: InputDecoration(
                    hintText: widget.description,
                    hintStyle: TextStyle(fontSize: height * 0.016),
                    filled: true,
                    fillColor: AppColor.mainFGColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignees:',
                      style: TextStyle(
                          fontSize: height * 0.016,
                          color: AppColor.mainTextColor2),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: widget.alreadyAssignedEmails.map((email) {
                        return Chip(
                          backgroundColor: AppColor.mainThemeColor,
                          label: Text(
                            email,
                            style: TextStyle(
                                color: AppColor.mainFGColor,
                                fontSize: height * 0.014),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 16),
              //   child: TextFormField(
              //     controller: assigneeEmailController,
              //     maxLines: 1,
              //     style: TextStyle(fontSize: 16, color: Colors.black87),
              //     decoration: InputDecoration(
              //       labelText: 'Search or Add Assignee by Email',
              //       labelStyle: TextStyle(color: Colors.black54),
              //       filled: true,
              //       fillColor: AppColor.mainFGColor,
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12),
              //         borderSide: BorderSide.none,
              //       ),
              //       contentPadding:
              //           EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //     ),
              //     onChanged: (value) {
              //       setState(() {
              //         filteredUsers = value.isEmpty
              //             ? []
              //             : filteredUsers
              //                 .where((user) => user.email
              //                     .toLowerCase()
              //                     .contains(value.toLowerCase()))
              //                 .toList();
              //       });
              //     },
              //   ),
              // ),
              // Visibility(
              //     visible: assigneeEmailController.text.isNotEmpty,
              //     child: _buildAssigneeList(height)),
              Text(
                'Priority:',
                style: TextStyle(
                    fontSize: height * 0.016, color: AppColor.mainTextColor2),
              ),
              _buildPrioritySelection(height),
              Text(
                'Deadline:',
                style: TextStyle(
                    fontSize: height * 0.016, color: AppColor.mainTextColor2),
              ),
              _buildDateSelection(
                  endDateController.text.isNotEmpty
                      ? endDateController.text
                      : widget.taskDeadline,
                  height),
              SizedBox(height: height * 0.02),
              _buildSubmitButton(width, height),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelection(double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _priorityButton('Low', height),
          _priorityButton('Medium', height),
          _priorityButton('High', height),
        ],
      ),
    );
  }

  Widget _priorityButton(String label, double height) {
    return Card(
      color: AppColor.mainFGColor,
      elevation: 4,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedPriority = label;
            print(selectedPriority);
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: selectedPriority == label
              ? AppColor.mainFGColor
              : const Color.fromARGB(255, 128, 128, 128),
          backgroundColor: selectedPriority == label
              ? AppColor.mainThemeColor
              : AppColor.mainFGColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: height * 0.014, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDateSelection(String date, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: endDateController,
        style: TextStyle(fontSize: height * 0.018, color: Colors.black87),
        readOnly: true,
        onTap: () => endDate(context),
        decoration: InputDecoration(
          hintText: widget.taskDeadline,
          hintStyle: TextStyle(fontSize: height * 0.016),
          filled: true,
          fillColor: AppColor.mainFGColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  endDate(BuildContext context) {
    return DatePicker.showDatePicker(
      context,
      dateFormat: 'dd MMMM yyyy HH:mm',
      initialDateTime: DateTime.now(),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(3000),
      onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          DateTime selectdate = dateTime;
          endDateController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(selectdate);
        });
      },
    );
  }

  Widget _buildSubmitButton(double width, double height) {
    return InkWell(
      onTap: isLoading
          ? null
          : () async {
              setState(() {
                isLoading = true;
              });
              
              await updateTask(
                context,
                widget.taskID,
                taskNameController.text.isEmpty
                    ? widget.taskname
                    : taskNameController.text,
                descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : widget.description,
                selectedPriority!,
                endDateController.text.isNotEmpty
                    ? endDateController.text
                    : DateFormat('yyyy-MM-dd HH:mm')
                        .format(DateTime.parse(widget.taskDeadline)),
                widget.alreadyAssignedEmails,
              );
            },
      child: Center(
        child: Container(
          width: width / 2,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColor.mainThemeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: isLoading
              ? Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: AppColor.mainFGColor,
                    size: height * 0.03,
                  ),
                )
              : Center(
                  child: Text('Update Task',
                      style: TextStyle(
                          color: AppColor.mainFGColor,
                          fontWeight: FontWeight.w500,
                          fontSize: height * 0.018)),
                ),
        ),
      ),
    );
  }
}
