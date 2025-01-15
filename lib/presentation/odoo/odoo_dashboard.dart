import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/model/models.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/odoo/create_project.dart';
import 'package:hrms/presentation/odoo/task_details.dart';
import 'package:hrms/presentation/odoo/view_projects.dart';

class OdooDashboard extends StatefulWidget {
  const OdooDashboard({super.key});
  @override
  State<OdooDashboard> createState() => _OdooDashboardState();
}

class _OdooDashboardState extends State<OdooDashboard> {
  final Box _authBox = Hive.box('authBox');
  late Future<List<OdooProjectList>> _projectsFuture;
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;
  bool showSearch = false;
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _projectsFuture = fetchOdooProjects();
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
              .where((project) =>
                  project['assignees_emails'].contains(_authBox.get('email')))
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

  List<Map<String, dynamic>> _getFilteredTasks() {
    List<Map<String, dynamic>> filteredTasks = tasks;
    

    if (searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return task['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
               task['description'].toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    

    if (selectedFilter == 'Today') {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      filteredTasks = filteredTasks.where((task) {
        return task['deadline_date']?.startsWith(today) ?? false;
      }).toList();
    }  else if (selectedFilter == 'Deadline') {
      final today = DateTime.now();
      filteredTasks = filteredTasks.where((task) {
        DateTime? deadline = DateTime.tryParse(task['deadline_date'] ?? '');
        return deadline != null && deadline.isBefore(today);
      }).toList();
    }

    return filteredTasks;
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
            'DASHBOARD',
            style: TextStyle(
                color: AppColor.mainFGColor,
                fontWeight: FontWeight.w400,
                fontSize: height * 0.02),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                showSearch ? Icons.cancel : Icons.search,
                color: AppColor.mainFGColor,
              ),
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                  if (!showSearch) {
                    searchQuery = ''; 
                  }
                });
              },
            ),
          ],
        ),
        body: SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    
                if (showSearch)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      onChanged: (query) {
                        setState(() {
                          searchQuery = query;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Projects/Tasks...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),


                // DropdownButton<String>(
                //   value: selectedFilter,
                //   onChanged: (value) {
                //     setState(() {
                //       selectedFilter = value!;
                //     });
                //   },
                //   items: ['All', 'Today', 'Deadline']
                //       .map((filter) {
                //     return DropdownMenuItem<String>(
                //       value: filter,
                //       child: Text(filter),
                //     );
                //   }).toList(),
                // ),


                Text(
                  "Projects",
                  style: TextStyle(
                      fontSize: height * 0.018,
                      color: AppColor.mainTextColor,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: height * 0.02),
                SizedBox(
                  height: height * 0.18,
                  child: FutureBuilder<List<OdooProjectList>>(
                    future: _projectsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        List<OdooProjectList> items = snapshot.data!;
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            OdooProjectList item = items[index];

                            String formattedDate = item.date_start == "False"
                                ? "No start date"
                                : item.date_start;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewProjects(projectName: item.name, projectID: item.id),
                                  ),
                                );
                              },
                              child: projectCard(
                                height,
                                width,
                                index <= 8 ? 'Project : 0${index + 1}' : 'Project : ${index + 1}',
                                item.name,
                                formattedDate,
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: height * 0.01);
                          },
                        );
                      } else {
                        return Center(child: Text('No projects found.'));
                      }
                    },
                  ),
                ),

       
                SizedBox(height: height * 0.02),
                Text(
                  "Today's Tasks",
                  style: TextStyle(
                      fontSize: height * 0.018,
                      color: AppColor.mainTextColor,
                      fontWeight: FontWeight.w500),
                ),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _getFilteredTasks().length,
                          itemBuilder: (context, index) {
                            final task = _getFilteredTasks()[index];
                            String priority = task['priority'] != null && task['priority'].isNotEmpty
                                ? task['priority'].toString().replaceAll('[', '').replaceAll(']', '')
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.circle_outlined,
                                                  color: AppColor.mainThemeColor,
                                                  size: height * 0.018,
                                                ),
                                                SizedBox(width: width * 0.02),
                                                SizedBox(
                                                  width: width / 1.5,
                                                  child: Text(
                                                    overflow: TextOverflow.ellipsis,
                                                    task['name'],
                                                    style: TextStyle(
                                                      color: AppColor.mainTextColor,
                                                      fontSize: height * 0.016,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Container(
                                                width: width,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color.fromARGB(14, 0, 0, 0)),
                                                  color: AppColor.mainBGColor,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    //task['description'],
                                                    'Tap to View Task Details',
                                                    style: TextStyle(
                                                      color: AppColor.mainTextColor2,
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
                                      Container(
                                        decoration: BoxDecoration(
                                          color: priority == 'High'
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 30.0),
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
 floatingActionButton:        _authBox.get('role') == 'Manager' ? FloatingActionButton.extended(
          backgroundColor: AppColor.mainThemeColor,
          onPressed: () => showCupertinoModalBottomSheet(
            expand: true,
            context: context,
            barrierColor: const Color.fromARGB(130, 0, 0, 0),
            backgroundColor: Colors.transparent,
            builder: (context) => CreateProject(),
          ),
          label: Text(
            'Create Project',
            style: TextStyle(color: AppColor.mainFGColor),
          ),
        ) : null );
  }

  projectCard(double height, double width, String projectCount,
      String projectName, String createDate) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Card(
        color: AppColor.mainFGColor,
        elevation: 5,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Container(
   
            width: width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.secondaryThemeColor2,
                  AppColor.primaryThemeColor,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/image/projectImage.png',
                        height: 30,
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      Text(
                        projectCount,
                        style: TextStyle(
                            color: AppColor.mainFGColor,
                            fontSize: height * 0.018,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  Text(
                    projectName,
                    style: TextStyle(
                        color: AppColor.mainFGColor,
                        fontSize: height * 0.021,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    createDate,
                    style: TextStyle(
                        color: AppColor.mainFGColor,
                        fontSize: height * 0.015,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
