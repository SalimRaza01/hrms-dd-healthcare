import 'package:flutter/services.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TeamProfile extends StatefulWidget {
  final String empID;
  TeamProfile(this.empID);
  @override
  _TeamProfileState createState() => _TeamProfileState();
}

class _TeamProfileState extends State<TeamProfile> {
  late Future<EmployeeProfile> employeeProfile;
  late String empID;

  @override
  void initState() {
    super.initState();
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    employeeProfile = fetchEmployeeDetails(widget.empID);
  }

  @override
  Widget build(BuildContext context) {
        final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      body: FutureBuilder<EmployeeProfile>(
        future: employeeProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                                        child: LoadingAnimationWidget
                                            .threeArchedCircle(
                                          color: AppColor.mainTextColor2,
                                          size: height * 0.03,
                                        ),
                                      );
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text('No Data Found'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final employee = snapshot.data!;
            return ListView(children: [
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColor.primaryThemeColor,
                        AppColor.secondaryThemeColor2,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: employee.employeePhoto.contains('NA')
                            ? AssetImage(
                                employee.gender == 'Male'
                                    ? 'assets/image/MaleAvatar.png'
                                    : 'assets/image/FemaleAvatar.png',
                              )
                            : NetworkImage(employee.employeePhoto),
                        radius: 30,
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.employeeName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColor.mainFGColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            employee.email,
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                    const Color.fromARGB(255, 224, 224, 224)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: AppColor.mainFGColor,
                  elevation: 4,
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColor.mainBGColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColor.mainTextColor2,
                                ),
                              ),
                              SizedBox(height: 5),
                              _buildProfileInfo(
                                  'Gender :', employee.gender, Icons.person),
                              _buildProfileInfo('Date of Birth :', employee.dob,
                                  Icons.calendar_today),
                              _buildProfileInfo('Marital Status :',
                                  employee.maritalStatus, Icons.favorite),
                              _buildProfileInfo('Address :',
                                  employee.permanentAddress, Icons.flag),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColor.mainBGColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColor.mainTextColor2,
                                ),
                              ),
                              SizedBox(height: 5),
                              _buildProfileInfo('Contact No :',
                                  employee.contactNo, Icons.phone),
                              _buildProfileInfo(
                                  'Email :', employee.email, Icons.email),
                              _buildProfileInfo(
                                  'Emergency Contact :',
                                  employee.emergencyContact,
                                  Icons.local_hospital),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.015,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColor.mainBGColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Work Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColor.mainTextColor2,
                                ),
                              ),
                              SizedBox(height: 5),
                              _buildProfileInfo('EmployeeID :',
                                  employee.employeeId, Icons.badge),
                              _buildProfileInfo('Date of Joining :',
                                  employee.doj, Icons.work),
                              _buildProfileInfo('Workplace :',
                                  employee.workPlace, Icons.business),
                              _buildProfileInfo('Designation :',
                                  employee.designation, Icons.assignment),
                              _buildProfileInfo('Employee Type :',
                                  employee.employmentType, Icons.assignment),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ]);
          }
        },
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: const Color.fromARGB(139, 0, 0, 0),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: const Color.fromARGB(139, 0, 0, 0),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
