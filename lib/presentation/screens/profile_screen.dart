// ignore_for_file: unused_element

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/animations/profile_shimmer.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/presentation/screens/document_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
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
  String? viewPhoto;
  String? filepath;
  bool isLoading = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    employeeProfile = fetchEmployeeDetails(widget.empID);
  }

  Future<void> logout() async {
    var box = await Hive.openBox('authBox');

    box.put('token', null);
  }

  // Future<void> _pickImage(ImageSource source) async {

  //   PermissionStatus permissionStatus;

  //   permissionStatus = await Permission.camera.request();

  //   if (permissionStatus.isGranted) {
  //               isLoading = true;
  //     final picker = ImagePicker();
  //     final pickedFile = await picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       setState(() {
  //         _image = File(pickedFile.path);
  //         filepath = pickedFile.path;
  //       });

  //       final fileSize = await _image!.length();

  //       uploadAvatar([
  //         PlatformFile(
  //           path: filepath,
  //           name: pickedFile.name,
  //           size: fileSize,
  //         ),
  //       ]);
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Permission not granted')),
  //     );
  //   }
  // }

  Future<void> _filepicker(ImageSource source) async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    final permissionStatus = android.version.sdkInt < 33
        ? await Permission.manageExternalStorage.request()
        : PermissionStatus.granted;

    // PermissionStatus permissionStatus =
    //     await Permission.manageExternalStorage.request();

    if (permissionStatus.isGranted) {
      isLoading = true;
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          filepath = pickedFile.path;
        });

        final fileSize = await _image!.length();

        uploadAvatar([
          PlatformFile(
            path: filepath,
            name: pickedFile.name,
            size: fileSize,
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
  Future<void> uploadAvatar(List<PlatformFile> files) async {
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
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Avatar Updated'),
                  backgroundColor: Colors.green),
            );
            setState(() {
              employeeProfile = fetchEmployeeDetails(widget.empID);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to Update Avatar'),
                  backgroundColor: Colors.red),
            );
          }
        } on DioException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.response!.data['message']),
                backgroundColor: Colors.red),
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
            // ListTile(
            //   leading: Icon(Icons.photo_camera, color: AppColor.mainTextColor2),
            //   title: Text(
            //     'Camera',
            //     style: TextStyle(color: AppColor.mainTextColor2),
            //   ),
            //   onTap: () {
            //     _pickImage(ImageSource.camera);
            //     Navigator.of(context).pop();
            //   },
            // ),
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
            return Center(child: Text('No Data Found'));
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
                        onLongPress: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhotoView(
                                        imageProvider:
                                            NetworkImage(employee.employeePhoto),
                                      )));
                        },
                        child: Container(
                          width: 120,
                          height: height * 0.14,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: width * 0.01,
                              color: AppColor.mainBGColor,
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
                          child: isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundImage: employee.employeePhoto
                                          .contains("NA")
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
                      SizedBox(height: height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            employee.employeeName,
                            style: TextStyle(
                              fontSize: height * 0.02,
                              fontWeight: FontWeight.bold,
                              color: AppColor.mainFGColor,
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
                            fontSize: height * 0.016,
                            color: const Color.fromARGB(255, 224, 224, 224)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.01,
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
                                  fontSize: height * 0.018,
                                  color: AppColor.mainTextColor2,
                                ),
                              ),
                              SizedBox(height: height * 0.005),
                              _buildProfileInfo('Gender :', employee.gender,
                                  Icons.person, height),
                              _buildProfileInfo('Date of Birth :', employee.dob,
                                  Icons.calendar_today, height),
                              _buildProfileInfo(
                                  'Marital Status :',
                                  employee.maritalStatus,
                                  Icons.favorite,
                                  height),
                              _buildProfileInfo(
                                  'Address :',
                                  employee.permanentAddress,
                                  Icons.flag,
                                  height),
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
                                  fontSize: height * 0.018,
                                  color: AppColor.mainTextColor2,
                                ),
                              ),
                              SizedBox(height: height * 0.005),
                              _buildProfileInfo('Contact No :',
                                  employee.contactNo, Icons.phone, height),
                              _buildProfileInfo('Email :', employee.email,
                                  Icons.email, height),
                              _buildProfileInfo(
                                  'Emergency Contact :',
                                  employee.emergencyContact,
                                  Icons.local_hospital,
                                  height),
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
                                  fontSize: height * 0.018,
                                  color: AppColor.mainTextColor2,
                                ),
                              ),
                              SizedBox(height: height * 0.005),
                              _buildProfileInfo('EmployeeID :',
                                  employee.employeeId, Icons.badge, height),
                              _buildProfileInfo('Date of Joining :',
                                  employee.doj, Icons.work, height),
                              _buildProfileInfo('Workplace :',
                                  employee.workPlace, Icons.business, height),
                              _buildProfileInfo(
                                  'Designation :',
                                  employee.designation,
                                  Icons.assignment,
                                  height),
                              _buildProfileInfo(
                                  'Employee Type :',
                                  employee.employmentType,
                                  Icons.assignment,
                                  height),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DocumentListScreen()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: AppColor.mainFGColor,
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
                            Icons.file_copy_rounded,
                            color: AppColor.mainThemeColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Documents',
                            style: TextStyle(
                              fontSize: height * 0.016,
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
                height: height * 0.02,
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
                    color: AppColor.mainFGColor,
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
                              fontSize: height * 0.016,
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
                height: height * 0.02,
              ),
            ]);
          }
        },
      ),
    );
  }

  Widget _buildProfileInfo(
      String label, String value, IconData icon, double height) {
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
              fontSize: height * 0.014,
              color: const Color.fromARGB(139, 0, 0, 0),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: height * 0.014,
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
