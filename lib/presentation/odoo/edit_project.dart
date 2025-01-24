import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/provider/provider.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class EditProject extends StatefulWidget {
  final int projectID;
  final String projectName;
  final List<String> alreadyAssignedEmails;

  const EditProject({
    required this.projectID,
    required this.projectName,
    required this.alreadyAssignedEmails,
  });

  @override
  State<EditProject> createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  TextEditingController projectNameController = TextEditingController();
  TextEditingController assigneeEmailController = TextEditingController();
  late Future<List<OdooUserModel>> odooUser;
  List<String> selectedUsers = [];
  List<OdooUserModel> filteredUsers = [];
  final Box _authBox = Hive.box('authBox');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.alreadyAssignedEmails.map((email) {
      selectedUsers.add(email);
    }).toList();
    odooUser = fetchOddoUsers('search user', 0);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> updateProject(
    BuildContext context,
    int projectID,
    String projectNameController,
    List<String> assigneeEmails,
  ) async {
    final response = await dio.put('$postOdooProject/$projectID', data: {
      "name": projectNameController,
      "assignees_emails": assigneeEmails,
      "task_creator_email": _authBox.get('email')
    });

    if (response.data['result']['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project Updated Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        isLoading = false;
      });
      Provider.of<ProjectProvider>(context, listen: false)
          .projectUpdatedStatus(true);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['result']['message']),
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
          'UPDATE PROJECT',
          style: TextStyle(
              fontSize: height * 0.02,
              fontWeight: FontWeight.w500,
              color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  color: AppColor.mainFGColor,
                  height: height * 0.06,
                  child: TextField(
                    controller: projectNameController,
                    decoration: InputDecoration(
                      filled: false,
                      hintText: widget.projectName,
                      hintStyle: TextStyle(fontSize: height * 0.016),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
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
                      runSpacing: 2.0,
                      children: selectedUsers.map((email) {
           
                        return Chip(
                          backgroundColor: AppColor.mainThemeColor,
                          label: Text(
                            email,
                            style: TextStyle(color: AppColor.mainFGColor),
                          ),
                          deleteIcon:
                              Icon(Icons.cancel, color: AppColor.mainFGColor),
                          onDeleted: () {
                            setState(() {
                              selectedUsers.remove(email);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Assignee Email Search
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  color: AppColor.mainFGColor,
                  height: height * 0.06,
                  child: TextField(
                    controller: assigneeEmailController,
                    decoration: InputDecoration(
                      filled: false,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 0.5, color: Colors.blueGrey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      label: Text('Search Assignee by Email'),
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
              ),

              Visibility(
                visible: assigneeEmailController.text.isNotEmpty,
                child: SizedBox(
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
                                    backgroundColor: const Color.fromARGB(
                                        255, 235, 244, 254),
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
                                        color: Colors.grey.shade600),
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
                                          assigneeEmailController.clear();
                                        } else {
                                          selectedUsers.add(item.email);
                                                  assigneeEmailController.clear();
                                          print(
                                              "selected user ${selectedUsers}");
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
                ),
              ),

              SizedBox(height: height * 0.02),
              InkWell(
                onTap: isLoading ? null :  () async {
                  setState(() {
                    isLoading = true;
                  });
                  await updateProject(
                    context,
                    widget.projectID,
                    projectNameController.text.isNotEmpty
                        ? projectNameController.text
                        : widget.projectName,
                    selectedUsers,
                  );
                },
                child: Center(
                  child: Container(
                    width: width / 2,
                    decoration: BoxDecoration(
                      color: AppColor.mainThemeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: isLoading
                          ? Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: AppColor.mainFGColor,
                                size: height * 0.03,
                              ),
                            )
                          : Center(
                              child: Text(
                                'Update Project',
                                style: TextStyle(
                                    color: AppColor.mainFGColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
