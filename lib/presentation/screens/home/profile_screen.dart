import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/animations/profile_shimmer.dart';
import 'package:database_app/presentation/screens/authentication/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/model/models.dart';
import 'package:hive_flutter/hive_flutter.dart';

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


  Future<void> logout() async {
    var box = await Hive.openBox('authBox');
    
box.put('token', null);

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
            return ProfileShimmerAnimation();
          } else if (snapshot.hasError) {
            return Center(child: Text('Please check your internet connection, try again'));
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
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
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
                              SizedBox(height: 10),
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
                              _buildProfileInfo('Place of Birth :',
                                  employee.placeOfBirth, Icons.location_on),
                              _buildProfileInfo('Marital Status :',
                                  employee.maritalStatus, Icons.favorite),
                              _buildProfileInfo('Nationality :',
                                  employee.nationality, Icons.flag),
                            ],
                          ),
                        ),
                      ),
                        SizedBox(
                height: 15,
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
                height: 15,
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
                              _buildProfileInfo(
                                  'Date of Joining :', employee.doj, Icons.work),
                              _buildProfileInfo('Workplace :', employee.workPlace,
                                  Icons.business),
                              _buildProfileInfo('Designation :',
                                  employee.designation, Icons.assignment),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                await  logout();
                Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen()));
                },
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
                          horizontal: 16, vertical: 13),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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

  Widget _buildProfileInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
