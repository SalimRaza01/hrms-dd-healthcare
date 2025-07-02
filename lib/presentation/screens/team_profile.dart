import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TeamProfile extends StatefulWidget {
  final String empID;
  TeamProfile(this.empID);
  @override
  _TeamProfileState createState() => _TeamProfileState();
}

class _TeamProfileState extends State<TeamProfile> {
  late Future<EmployeeProfile> employeeProfile;

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
      body: Container(
                decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.newgredient1,
              const Color.fromARGB(52, 124, 157, 174),
            ],
          ),
        ),
        child: FutureBuilder<EmployeeProfile>(
          future: employeeProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColor.mainTextColor2,
                  size: height * 0.03,
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Center(child: Text('No Data Found', style: TextStyle(color: AppColor.mainTextColor2)));
            }
        
            final employee = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              children: [
                // --- Profile Header ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
     color:  const Color.fromARGB(52, 124, 157, 174),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: employee.employeePhoto.contains('NA')
                            ? AssetImage(
                                employee.gender == 'Male'
                                    ? 'assets/image/MaleAvatar.png'
                                    : 'assets/image/FemaleAvatar.png',
                              ) as ImageProvider
                            : NetworkImage(employee.employeePhoto),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.employeeName,
                              style: TextStyle(
                                fontSize: height * 0.022,
                                fontWeight: FontWeight.bold,
                                color:AppColor.mainTextColor
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.email,
                              style: TextStyle(
                                fontSize: height * 0.016,
                                color:AppColor.mainTextColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        
                 SizedBox(height: height * 0.012),
                _sectionCard(
                  title: "Personal Information",
                  height: height,
                  children: [
                    _infoRow("Gender", employee.gender),
                    _infoRow("Date of Birth", employee.dob),
                    _infoRow("Marital Status", employee.maritalStatus),
                    _infoRow("Address", employee.permanentAddress),
                  ],
                ),
                SizedBox(height: height * 0.012),
                _sectionCard(
                  title: "Contact Information",
                  height: height,
                  children: [
                    _infoRow("Contact No", employee.contactNo),
                    _infoRow("Email", employee.email),
                    _infoRow("Emergency Contact", employee.emergencyContact),
                  ],
                ),
                 SizedBox(height: height * 0.012),
                _sectionCard(
                  title: "Work Information",
                  height: height,
                  children: [
                    _infoRow("Employee ID", employee.employeeId),
                    _infoRow("Date of Joining", employee.doj),
                    _infoRow("Workplace", employee.workPlace),
                    _infoRow("Designation", employee.designation),
                    _infoRow("Employee Type", employee.employmentType),
                  ],
                ),
                  SizedBox(height: height * 0.012),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required double height,
    required List<Widget> children,
  }) {
    return Card(
      color:   const Color.fromARGB(224, 255, 255, 255),
      elevation: 0,
      shadowColor: AppColor.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: height * 0.018,
                fontWeight: FontWeight.w600,
                color: AppColor.mainTextColor,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: AppColor.mainTextColor2,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColor.mainTextColor2,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
