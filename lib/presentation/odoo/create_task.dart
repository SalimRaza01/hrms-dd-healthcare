// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class CreateTask extends StatefulWidget {
  const CreateTask();

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController assigneeEmailController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  late Future<List<OdooUserModel>> odooUser;
  List<OdooUserModel> selectedUsers = [];
  List<OdooUserModel> filteredUsers = [];
  String _selectedText = 'Low';

  @override
  void initState() {
    super.initState();
    odooUser = fetchOddoUsers('search user');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  dateTimePickerWidget(BuildContext context) {
    return DatePicker.showDatePicker(
      context,
      dateFormat: 'dd MMMM yyyy HH:mm',
      initialDateTime: DateTime.now(),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(3000),
      onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime, List<int> index) {
        DateTime selectdate = dateTime;
        final formattedDate =
            DateFormat('dd-MMM-yyyy - HH:mm').format(selectdate);
        print(formattedDate);
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
            color: Colors.white,
          ),
        ),
        title: Text(
          'CREATE TASK',
          style: TextStyle(color: Colors.white),
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
              _buildTextField(
                  'Search Assignee by Email', assigneeEmailController),
              Visibility(
                  visible: assigneeEmailController.text.isNotEmpty,
                  child: _buildAssigneeList(height)),
              _buildPrioritySelection(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateSelection('Start Date'),
                  _buildDateSelection('End Date'),
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
          fillColor: Colors.white,
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
      color: Colors.white,
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
              ? Colors.white
              : const Color.fromARGB(255, 128, 128, 128),
          backgroundColor:
              _selectedText == label ? AppColor.mainThemeColor : Colors.white,
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
    return FutureBuilder<List<OdooUserModel>>(
      future: odooUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Center(child: Text('No User Found'));
        } else {
          List<OdooUserModel> items = snapshot.data!;

          if (filteredUsers.isEmpty) {
            filteredUsers = items;
          }

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
                        color: Colors.white,
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
      },
    );
  }

  Widget _buildDateSelection(String text) {
    return GestureDetector(
      onTap: () {
        dateTimePickerWidget(context);
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
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
      onTap: () async {
        if (taskNameController.text.isNotEmpty &&
            descriptionController.text.isNotEmpty &&
            selectedUsers.isNotEmpty &&
            startDateController.text.isNotEmpty &&
            endDateController.text.isNotEmpty) {
          List<int> assigneeIDs = selectedUsers.map((e) => e.id).toList();

          await createProject(context, taskNameController.text,
              descriptionController.text, assigneeIDs);
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
        child: Center(
          child: Text('Create Task',
              style: TextStyle(
                  color: Colors.white,
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
              style: TextStyle(color: Colors.white),
            ),
            avatar: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name[0],
                style: TextStyle(color: AppColor.mainThemeColor, fontSize: 10),
              ),
            ),
            deleteIcon: Icon(Icons.cancel, color: Colors.white),
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
