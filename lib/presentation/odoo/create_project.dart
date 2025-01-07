import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CreateProject extends StatefulWidget {
  CreateProject();

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectDescriptionController = TextEditingController();
  TextEditingController assigneeEmailController = TextEditingController();
  late Future<List<OdooUserModel>> odooUser;
  List<OdooUserModel> selectedUsers = [];
  List<OdooUserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    odooUser = fetchOddoUsers('search user');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create Project',
          style: TextStyle(
            fontSize: height * 0.02,
            fontWeight: FontWeight.w500,
            color: AppColor.mainTextColor,
          ),
        ),
        backgroundColor: AppColor.mainBGColor,
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
                  color: Colors.white,
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

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                    color: Colors.white,
                    height: height * 0.1,
                    width: width,
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      controller: projectDescriptionController,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0.5, color: Colors.blueGrey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0.5, color: Colors.blueGrey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0.5, color: Colors.blueGrey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        label: Text('Project Description'),
                      ),
                    )),
              ),

              // Assignee Email Search
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  color: Colors.white,
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
                onTap: () async {
                  if (projectNameController.text.isNotEmpty &&
                      projectDescriptionController.text.isNotEmpty &&
                      selectedUsers.isNotEmpty) {
                    List<int> assigneeIDs =
                        selectedUsers.map((e) => e.id).toList();

                    await createProject(
                      context,
                      projectNameController.text,
                      projectDescriptionController.text,
                      assigneeIDs,
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
                      child: Center(
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
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
