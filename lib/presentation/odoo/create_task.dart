// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/api/api.dart';
import '../../core/api/api_config.dart';
import '../../core/model/models.dart';
import '../../core/provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class CreateTask extends StatefulWidget {
  final int projectID;
  const CreateTask({required this.projectID});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  late int projectID;
  TextEditingController taskNameController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController assigneeEmailController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  late Future<List<OdooUserModel>> odooUser;
  List<OdooUserModel> selectedUsers = [];
  List<OdooUserModel> filteredUsers = [];
  String _selectedText = 'Low';
  bool isLoading = false;
  final Box _authBox = Hive.box('authBox');

  @override
  void initState() {
    super.initState();
    odooUser = fetchOddoUsers(widget.projectID);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> createTask(
    BuildContext context,
    String taskName,
    int projectID,
    String taskDescription,
    String taskPriority,
    String taskStartDate,
    String taskEndDate,
    List<String> userEmails,
  ) async {
    final response = await dio.post(postOdootasks, data: {
      "name": taskName,
      "project_id": projectID,
      "assignees_emails": userEmails,
      "priority": taskPriority,
      "start_date": taskStartDate,
      "date_deadline": taskEndDate,
      "task_description": taskDescription,
      "task_creator_email": _authBox.get('email')
    });

    if (response.data['result']['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task Created Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        isLoading = false;
      });
      Provider.of<TaskProvider>(context, listen: false).taskupdatedStatus(true);
      Navigator.pop(context, 'refresh');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['result']['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  startDate(BuildContext context) {
    return DatePicker.showDatePicker(context,
        dateFormat: 'dd MMMM yyyy HH:mm',
        initialDateTime: DateTime.now(),
        minDateTime: DateTime(2000),
        maxDateTime: DateTime(3000),
        onMonthChangeStartWithFirstDate: true,
        onConfirm: (dateTime, List<int> index) {
      setState(() {
        DateTime selectdate = dateTime;
        startDateController.text = DateFormat('yyyy-MM-dd').format(selectdate);
      });
    });
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
          print(endDateController.text);
        });
      },
    );
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
          'CREATE TASK',
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
              _buildTextField('Task Name', taskNameController),
              _buildTextField('Description', descriptionController,
                  maxLines: 3),
              _buildSelectedUsers(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: assigneeEmailController,
                  maxLines: 1,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Search Assignee by Email',
                    labelStyle: TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: AppColor.mainFGColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredUsers = value.isEmpty
                          ? []
                          : filteredUsers
                              .where((user) => user.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                    });
                  },
                ),
              ),
              Visibility(
                  visible: assigneeEmailController.text.isNotEmpty,
                  child: _buildAssigneeList(height)),
              _buildPrioritySelection(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateSelection(startDateController.text.isNotEmpty
                      ? startDateController.text
                      : 'Start Date'),
                  _buildDateSelection(endDateController.text.isNotEmpty
                      ? endDateController.text
                      : 'End Date'),
                ],
              ),
              SizedBox(height: height * 0.02),
              _buildSubmitButton(width, height),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
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

  Widget _buildPrioritySelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _priorityButton('Low'),
          _priorityButton('Medium'),
          _priorityButton('High'),
        ],
      ),
    );
  }

  Widget _priorityButton(String label) {
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
            _selectedText = label;
          });
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: _selectedText == label
              ? AppColor.mainFGColor
              : const Color.fromARGB(255, 128, 128, 128),
          backgroundColor: _selectedText == label
              ? AppColor.mainThemeColor
              : AppColor.mainFGColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAssigneeList(double height) {
    return SizedBox(
            height: height * 0.27,
            child: FutureBuilder<List<OdooUserModel>>(
              future: odooUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('No User Found'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No User Found'));
                } else {
                  List<OdooUserModel> items = snapshot.data!;

                  if (filteredUsers.isEmpty) {
                    filteredUsers = items;
                  }

                  return ListView.separated(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      OdooUserModel item = filteredUsers[index];

                      return Card(
                        color: AppColor.mainFGColor,
                        elevation: 4,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  const Color.fromARGB(255, 235, 244, 254),
                              child: Text(
                                item.name[0],
                                style: TextStyle(
                                  fontSize: height * 0.022,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: height * 0.016,
                                color: AppColor.mainTextColor2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              item.email,
                              style: TextStyle(
                                fontSize: height * 0.013,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                selectedUsers.contains(item)
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: AppColor.mainThemeColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (selectedUsers.contains(item)) {
                                    selectedUsers.remove(item);
                                  } else {
                                    selectedUsers.add(item);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: height * 0.01,
                      );
                    },
                  );
                }
              },
            ),
          );
  }

  Widget _buildDateSelection(String text) {
    return GestureDetector(
      onTap: () {
        if (text.contains('Start')) {
          startDate(context);
        } else {
          endDate(context);
        }
      },
      child: Card(
        color: AppColor.mainFGColor,
        elevation: 4,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Center(
            child: Text(text,
                style: TextStyle(
                    color: const Color.fromARGB(255, 128, 128, 128),
                    fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(double width, double height) {
    return InkWell(
      onTap:  isLoading ? null :  () async {
        if (taskNameController.text.isNotEmpty &&
            descriptionController.text.isNotEmpty &&
            selectedUsers.isNotEmpty &&
            startDateController.text.isNotEmpty &&
            endDateController.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });

          List<String> assigneeEmails =
              selectedUsers.map((e) => e.email).toList();

          await createTask(
              context,
              taskNameController.text,
              widget.projectID,
              descriptionController.text,
              _selectedText,
              startDateController.text,
              endDateController.text,
              assigneeEmails);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill all fields and select assignees'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 14),
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
                child: Text('Create Task',
                    style: TextStyle(
                        color: AppColor.mainFGColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18)),
              ),
      ),
    );
  }

  Widget _buildSelectedUsers() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: selectedUsers.map((user) {
          return Chip(
            backgroundColor: AppColor.mainThemeColor,
            label: Text(
              user.name,
              style: TextStyle(color: AppColor.mainFGColor),
            ),
            avatar: CircleAvatar(
              backgroundColor: AppColor.mainFGColor,
              child: Text(
                user.name[0],
                style: TextStyle(color: AppColor.mainThemeColor, fontSize: 10),
              ),
            ),
            deleteIcon: Icon(Icons.cancel, color: AppColor.mainFGColor),
            onDeleted: () {
              setState(() {
                selectedUsers.remove(user);
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
