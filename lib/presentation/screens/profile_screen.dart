// ignore_for_file: unused_element

import 'dart:io';

import 'package:database_app/core/api/api_config.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:database_app/presentation/animations/profile_shimmer.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/model/models.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String empID;
  ProfileScreen(this.empID);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<EmployeeProfile> employeeProfile;
  late String empID;
  File? _image;
  String? filepath;

  @override
  void initState() {
    super.initState();
    employeeProfile = fetchEmployeeDetails(widget.empID);
  }

  Future<void> logout() async {
    var box = await Hive.openBox('authBox');

    box.put('token', null);
  }

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus permissionStatus;

    permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          filepath = pickedFile.path;
          print('This is my set image $_image');
        });

        // Get the file size
        final fileSize = await _image!.length();

        // Pass the required size parameter
        uploadPrescription([
          PlatformFile(
            path: filepath,
            name: pickedFile.name,
            size: fileSize, // Provide the size of the file
          ),
        ]);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission not granted')),
      );
    }
  }

  Future<void> _filepicker(ImageSource source) async {
    PermissionStatus permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          filepath = pickedFile.path;
          print('This is my set image $_image');
        });

        // Get the file size
        final fileSize = await _image!.length();

        // Pass the required size parameter
        uploadPrescription([
          PlatformFile(
            path: filepath,
            name: pickedFile.name,
            size: fileSize, // Provide the size of the file
          ),
        ]);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission not granted for storage')),
      );
    }
  }

  String? get uploadURL => '$profileImageUpload/${widget.empID}';
  Future<void> uploadPrescription(List<PlatformFile> files) async {
    final dio = Dio();

    for (var file in files) {
      if (file.path != null) {
        try {
          var formData = FormData.fromMap({
            'file':
                await MultipartFile.fromFile(file.path!, filename: file.name),
          });

          Response response = await dio.post(uploadURL!, data: formData);

          if (response.statusCode == 200) {
            print(response);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Avatar Updated'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to Update Avatar'),
                  backgroundColor: Colors.red),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } else {
        print("File path is null");
      }
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: <Widget>[
            ListTile(
              leading:
                  Icon(Icons.photo_library, color: AppColor.mainTextColor2),
              title: Text(
                'Photo Library',
                style: TextStyle(color: AppColor.mainTextColor2),
              ),
              onTap: () {
                _filepicker(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera, color: AppColor.mainTextColor2),
              title: Text(
                'Camera',
                style: TextStyle(color: AppColor.mainTextColor2),
              ),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            Visibility(
              visible: _image != null,
              child: ListTile(
                leading: Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                title: Text(
                  'Remove Current Profile',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  // setState(() {
                  //   _image = null;
                  // });
                  //  SharedPrefsHelper()
                  //     .putImageFile('profileImage', _image!);

                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              title: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            return Center(
                child:
                    Text('Please check your internet connection, try again'));
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
                      InkWell(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: Container(
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
                            backgroundImage: employee.employeePhoto.isEmpty
                                ? AssetImage(
                                    employee.gender == 'Male'
                                        ? 'assets/image/MaleAvatar.png'
                                        : 'assets/image/FemaleAvatar.png',
                                  )
                                : NetworkImage(employee.employeePhoto),
                            radius: 50,
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
                            color: employee.employeeStatus == 'Present'
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
                              _buildProfileInfo('Marital Status :',
                                  employee.maritalStatus, Icons.favorite),
                              _buildProfileInfo('Address :',
                                  employee.permanentAddress, Icons.flag),
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
              InkWell(
                onTap: () async {
                  showDialog<void>(
                    barrierColor: Colors.black38,
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text(
                          'Confirm Logout',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () async {
                              await logout();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SplashScreen()));
                            },
                            child: Text(
                              "Yes",
                            ),
                          ),
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "No",
                            ),
                          ),
                        ],
                        content: Text(
                          'Are you sure want to logout?',
                        ),
                      );
                    },
                  );
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
