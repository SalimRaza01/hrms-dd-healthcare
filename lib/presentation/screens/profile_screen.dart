import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/api/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../animations/profile_shimmer.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'document_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wiredash/wiredash.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String empID;
  ProfileScreen(this.empID);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
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
    box.put('photo', null);
    box.put('token', null);
    box.put('maxRegularization', null);
    box.put('casual', null);
    box.put('medical', null);
    box.put('maternity', null);
    box.put('paternity', null);
    box.put('earned', null);
    box.put('short', null);
    box.put('managerId', null);
    box.put('earlyby', null);
    box.put('lateby', null);
    box.put('employeeId', null);
    box.put('employeeName', null);
    box.put('employeeDesign', null);
    box.put('gender', null);
    box.put('email', null);
    box.put('role', null);
  }

  // Future<void> _filepicker(ImageSource source) async {
  //   final plugin = DeviceInfoPlugin();
  //   final android = await plugin.androidInfo;
  //   final permissionStatus = android.version.sdkInt < 33
  //       ? await Permission.manageExternalStorage.request()
  //       : PermissionStatus.granted;

  //   if (permissionStatus.isGranted) {
  //     isLoading = true;
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
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Permission not granted for storage')),
  //     );
  //   }
  // }
  Future<void> _filepicker(ImageSource source) async {
  bool hasPermission = false;

  if (Platform.isAndroid) {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    final permissionStatus = android.version.sdkInt < 33
        ? await Permission.manageExternalStorage.request()
      : PermissionStatus.granted;

    hasPermission = permissionStatus.isGranted;
  } else if (Platform.isIOS) {
    hasPermission = true; // image_picker handles the permission for PhotoLibrary automatically
  }

  if (hasPermission) {
    setState(() => isLoading = true);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        filepath = pickedFile.path;
      });

      final fileSize = await _image!.length();

      await uploadAvatar([
        PlatformFile(
          path: filepath,
          name: pickedFile.name,
          size: fileSize,
        ),
      ]);
    } else {
      setState(() => isLoading = false);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Permission not granted for storage access.')),
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
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text('Choose Option'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                _filepicker(ImageSource.gallery);
                Navigator.of(context).pop();
              },
              child: Text('Photo Library'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: AppColor.mainFGColor,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Photo Library'),
                    onTap: () {
                      _filepicker(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text('Cancel', style: TextStyle(color: Colors.red)),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                  return Container(
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          spacing: 15.0,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                ' My Profile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: height * 0.018,
                                    color: Colors.black),
                              ),
                            ),
                            Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Container(
                                    width: double.infinity,
                                    height: height * 0.28,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        color: Color(0xFFC9D9D5)),
                                    child: isLoading
                                        ? Center(
                                            child: LoadingAnimationWidget
                                                .threeArchedCircle(
                                              color: AppColor.mainBGColor,
                                              size: height * 0.05,
                                            ),
                                          )
                                        : employee.employeePhoto.contains("NA")
                                            ? Image.asset(
                                                employee.gender == 'Male'
                                                    ? 'assets/image/maleAvatar2.png'
                                                    : 'assets/image/femaleAvatar2.png',
                                              )
                                            : Image.network(
                                                fit: BoxFit.fitWidth,
                                                employee.employeePhoto),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Center(
                                    child: Column(
                       
                                      children: [
                                        Text(
                                          employee.employeeName,
                                          style: TextStyle(
                                            fontSize: height * 0.021,
                                            fontWeight: FontWeight.bold,
                                            color:Colors.white
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
     
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: const Color.fromARGB(
                                                      152, 0, 0, 0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      color: employee
                                                                  .employeeStatus ==
                                                              'Working'
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 83, 238, 88)
                                                          : Colors.red,
                                                      size: height * .015,
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      employee.employeeId ==
                                                              '413'
                                                          ? 'Flutter & UI/UX Developer'
                                                          : employee
                                                              .designation,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _showPicker(context);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: const Color.fromARGB(
                                                        152, 0, 0, 0)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons.camera,
                                                        color: Colors.white,
                                                        size: height * .015,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: AppColor.mainBGColor,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: TabBar(
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      unselectedLabelColor:
                                          AppColor.unselectedColor,
                                      indicatorColor: Colors.black,
                                      labelColor: Colors.black,
                                      tabs: [
                                        Tab(text: 'Personal'),
                                        Tab(text: 'Contact'),
                                        Tab(text: 'Work Info'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.28,
                                    child: TabBarView(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildProfileInfo(
                                                  'Gender',
                                                  employee.gender,
                                                  Icons.description_outlined,
                                                  height),
                                              _buildProfileInfo(
                                                  'DOB',
                                                  employee.dob,
                                                  Icons.calendar_month,
                                                  height),
                                              _buildProfileInfo(
                                                  'Marital Status',
                                                  employee.maritalStatus,
                                                  Icons.favorite_border,
                                                  height),
                                              _buildProfileInfo(
                                                  'Address',
                                                  employee.permanentAddress,
                                                  Icons.location_on_outlined,
                                                  height),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildProfileInfo(
                                                  'Contact',
                                                  employee.contactNo,
                                                  Icons.phone_outlined,
                                                  height),
                                              _buildProfileInfo(
                                                  'Email',
                                                  employee.email,
                                                  Icons.email_outlined,
                                                  height),
                                              _buildProfileInfo(
                                                  'Emergency Contact',
                                                  employee.emergencyContact,
                                                  Icons.local_hospital_outlined,
                                                  height),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildProfileInfo(
                                                  'Emp-ID',
                                                  employee.employeeId,
                                                  Icons.badge_outlined,
                                                  height),
                                              _buildProfileInfo(
                                                  'DOJ',
                                                  employee.doj,
                                                  Icons.work_outline,
                                                  height),
                                              _buildProfileInfo(
                                                  'Designation',
                                                  employee.employeeId == '413'
                                                      ? 'Flutter & UI/UX Developer'
                                                      : employee.designation,
                                                  Icons.assignment_outlined,
                                                  height),
                                              _buildProfileInfo(
                                                  'Emp-Type',
                                                  employee.employmentType,
                                                  Icons.assignment_outlined,
                                                  height),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DocumentListScreen()));
                              },
                              child: Card(
                                color: AppColor.mainBGColor,
                                elevation: 0,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(38),
                                ),
                                shadowColor: AppColor.shadowColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 13),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFD8E1E7),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.file_copy_rounded,
                                            color: AppColor.mainTextColor,
                                            size: height * 0.016,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      Text(
                                        'Documents',
                                        style: TextStyle(
                                          fontSize: height * 0.015,
                                          color: AppColor.mainTextColor,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Wiredash.of(context)
                                  .show(inheritMaterialTheme: true),
                              child: Card(
                                color: AppColor.mainBGColor,
                                elevation: 0,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(38),
                                ),
                                shadowColor: AppColor.shadowColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 13),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFD8E1E7),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.support_agent,
                                            color: AppColor.mainTextColor,
                                            size: height * 0.016,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      Text(
                                        'Support & Feedback',
                                        style: TextStyle(
                                          fontSize: height * 0.015,
                                          color: AppColor.mainTextColor,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                logoutMethod(context, height);
                              },
                              child: Card(
                                color: AppColor.mainBGColor,
                                elevation: 0,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(38),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 13),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFD8E1E7),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.logout_rounded,
                                            color: AppColor.mainTextColor,
                                            size: height * 0.016,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      Text(
                                        'Log-Out',
                                        style: TextStyle(
                                          fontSize: height * 0.015,
                                          color: AppColor.mainTextColor,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.1,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(
      String label, String value, IconData icon, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFD8E1E7),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                size: height * 0.016,
                color: AppColor.mainTextColor,
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: height * 0.016,
              fontWeight: FontWeight.w500,
              color: AppColor.mainTextColor,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: height * 0.016,
                color: AppColor.mainTextColor2,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logoutMethod(BuildContext context, double height) {
    return showDialog<void>(
      barrierColor: AppColor.barrierColor.withOpacity(0.8),
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.mainFGColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              fontSize: height * 0.024,
              fontWeight: FontWeight.bold,
              color: AppColor.mainTextColor,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: height * 0.017,
              color: AppColor.mainTextColor2,
            ),
          ),
          actionsPadding:
              const EdgeInsets.only(bottom: 12, left: 20, right: 20),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            // YES button
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: height * 0.018,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // NO button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColor.borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "No",
                  style: TextStyle(
                    color: AppColor.mainTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: height * 0.018,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
