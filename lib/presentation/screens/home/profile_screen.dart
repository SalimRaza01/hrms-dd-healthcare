import 'package:database_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/model/models.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<EmployeeProfile> employeeProfile;

  @override
  void initState() {
    super.initState();
    employeeProfile = fetchEmployeeDetails();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      body: FutureBuilder<EmployeeProfile>(
        future: employeeProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final employee = snapshot.data!;
            return ListView(children: [
              Container(
                // color: AppColor.mainThemeColor,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.primaryThemeColor,
                      AppColor.secondaryThemeColor2,
                    ],
                  ),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30))
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: height * 0.14,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: width * 0.01,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 10),
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          child: Image.asset(
                            employee.gender == 'Male'
                                ? 'assets/image/MaleAvatar.png'
                                : 'assets/image/FemaleAvatar.png',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            employee.employeeName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.circle,
                            color: employee.employeeStatus == 'Working'
                                ? Colors.green
                                : Colors.red,
                            size: height * .015,
                          )
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        employee.email,
                        style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 224, 224, 224)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColor.mainThemeColor,
                            ),
                          ),
                          SizedBox(height: 5),
                          _buildProfileInfo('Gender', employee.gender),
                          _buildProfileInfo('Date of Birth', employee.dob),
                          _buildProfileInfo(
                              'Place of Birth', employee.placeOfBirth),
                          _buildProfileInfo(
                              'Marital Status', employee.maritalStatus),
                          _buildProfileInfo(
                              'Nationality', employee.nationality),
                          SizedBox(height: 10),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColor.mainThemeColor,
                            ),
                          ),
                          SizedBox(height: 5),
                          _buildProfileInfo('Contact No', employee.contactNo),
                          _buildProfileInfo('Email', employee.email),
                          _buildProfileInfo(
                              'Emergency Contact', employee.emergencyContact),
                          SizedBox(height: 10),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Work Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColor.mainThemeColor,
                            ),
                          ),
                          SizedBox(height: 5),
                          _buildProfileInfo('EmployeeID', employee.employeeId),
                          _buildProfileInfo('Date of Joining', employee.doj),
                          _buildProfileInfo('Workplace', employee.workPlace),
                          _buildProfileInfo(
                              'Designation', employee.designation),
                        ],
                      )
                    ]),
                  ),
                ),
              ),
              
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColor.mainThemeColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Log-Out',
                            style: TextStyle(
                              fontSize: 16,     fontWeight: FontWeight.w500,
                         color: AppColor.mainTextColor,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: const Color.fromARGB(139, 0, 0, 0),
            ),
          ),
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
