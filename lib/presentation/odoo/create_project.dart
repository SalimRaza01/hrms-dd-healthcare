import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/api/api.dart';
import '../../core/api/api_config.dart';
import '../../core/model/models.dart';
import '../../core/provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final Box _authBox = Hive.box('authBox');
  TextEditingController projectNameController = TextEditingController();
  TextEditingController assigneeEmailController = TextEditingController();
  late Future<List<OdooUserModel>> odooUser;
  List<OdooUserModel> selectedUsers = [];
  List<OdooUserModel> filteredUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    odooUser = fetchOddoUsers(0);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> createProject(
    BuildContext context,
    String projectNameController,
    List<String> assigneeEmails,
  ) async {
    final response = await dio.post(postOdooProject, data: {
      "name": projectNameController,
      "assignes_emails": assigneeEmails,
      "task_creator_email": _authBox.get('email')
    });

    if (response.data['result']['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project Created Successfully'),
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
          content: Text('Something Went Wrong'),
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
          'CREATE PROJECT',
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
                      label: Text('Project Name'),
                    ),
                    onChanged: (value) {},
                  ),
                ),
              ),

              _buildSelectedUsers(),
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
                ),
              ),

              SizedBox(height: height * 0.02),
              InkWell(
                onTap: isLoading ? null : () async {
                  if (projectNameController.text.isNotEmpty &&
                      selectedUsers.isNotEmpty) {
                    List<String> assigneeEmails =
                        selectedUsers.map((e) => e.email).toList();
                    setState(() {
                      isLoading = true;
                    });
                    await createProject(
                      context,
                      projectNameController.text,
                      assigneeEmails,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Please fill all fields and select assignees'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
                                'SUBMIT',
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