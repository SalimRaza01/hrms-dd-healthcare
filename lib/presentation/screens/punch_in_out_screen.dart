// ignore_for_file: use_key_in_widget_constructors, depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class PunchInOutScreen extends StatefulWidget {
  @override
  State<PunchInOutScreen> createState() => _PunchInOutScreenState();
}

class _PunchInOutScreenState extends State<PunchInOutScreen> {
  late CameraController _cameraController;
  String? empName;
  File? _selfie;
  LatLng? _currentLocation;
  bool _isLoading = false;
  DateTime? _punchInTime;
  DateTime? _punchOutTime;
  List<Placemark>? placemarks;
  Placemark? place;

  @override
  void initState() {
    super.initState();
    _checkEmployeeId();
    _getCurrentLocation();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Location services are disabled.'),
      ));
      return;
    }

    PermissionStatus permissionStatus = await Permission.location.request();
    _initializeCamera();
    if (permissionStatus.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
          // desiredAccuracy: LocationAccuracy.high,
        );
        placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);

          place = placemarks![0];
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error retrieving location'),
        ));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Location permission denied.'),
      ));
    }
  }

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePunchInStatus(DateTime? punchInTime) async {
    var box = await Hive.openBox('authBox');
    box.put('punchInTime', punchInTime);
    Future.delayed(Duration(seconds: 1), () {
      _checkEmployeeId();
    });
  }

  Future<void> _savePunchOutStatus(DateTime? punchOutTime) async {
    var box = await Hive.openBox('authBox');
    box.put('punchOutTime', punchOutTime);
    Future.delayed(Duration(seconds: 1), () {
      _checkEmployeeId();
    });
  }

  Future<void> _checkEmployeeId() async {
    var box = await Hive.openBox('authBox');
    setState(() {
      empName = box.get('employeeName');
      _punchInTime = box.get('punchInTime', defaultValue: null);
      _punchOutTime = box.get('punchOutTime', defaultValue: null);
    });
    print('Stored Employee ID: $empName');
  }

  Future<void> _punchIn() async {
    await _getCurrentLocation();
    if (_selfie == null) {
      await _takeSelfie();
    }

    if (_selfie != null && _currentLocation != null) {
      setState(() {
        _isLoading = true;
      });

      setState(() {
        _isLoading = false;
      });

      await _savePunchInStatus(DateTime.now());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text('Punched In Successfully!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to punch in'),
      ));
    }
  }

  Future<void> _punchOut() async {
    await _getCurrentLocation();
    if (_selfie == null) {
      await _takeSelfie();
    }

    if (_selfie != null && _currentLocation != null) {
      setState(() {
        _isLoading = true;
      });

      setState(() {
        _isLoading = false;
      });

      await _savePunchOutStatus(DateTime.now());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text('Punched Out Successfully!'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to punch out'),
      ));
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Duration duration = _punchInTime != null
        ? DateTime.now().difference(_punchInTime!)
        : Duration(hours: 0, minutes: 0);

    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    String formattedDuration = hours == 0 && minutes == 0
        ? '--/--'
        : (hours < 10 ? '0$hours' : '$hours') +
            ':' +
            (minutes < 10 ? '0$minutes' : '$minutes');

    String punchIn = _punchInTime != null
        ? "${_punchInTime!.hour.toString().padLeft(2, '0')}:${_punchInTime!.minute.toString().padLeft(2, '0')}"
        : '--/--';

    String punchOut = _punchOutTime != null
        ? "${_punchOutTime!.hour.toString().padLeft(2, '0')}:${_punchOutTime!.minute.toString().padLeft(2, '0')}"
        : '--/--';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.inkDrop(
                color: AppColor.mainFGColor,
                size: height * 0.04,
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                      initialCenter: _currentLocation != null
                          ? _currentLocation!
                          : LatLng(50.5, 30.51),
                      initialZoom: 16.0),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    CurrentLocationLayer(
                      style: LocationMarkerStyle(
                          markerSize: Size.fromRadius(10),
                          accuracyCircleColor:
                              const Color.fromARGB(120, 64, 195, 255)),
                    ),
                  ],
                ),
                Container(
                  color: const Color.fromARGB(235, 207, 0, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "You're using a test version of the clock-in feature. Selfie, time, and location data are not saved and won't affect official attendance. Use this to help us improve.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        height: height / 3,
                        width: width,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                        decoration: BoxDecoration(
                          color: AppColor.mainFGColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: height * 0.06,
                            ),
                            Text(
                              empName != null ? 'Name : ${empName!}' : '',
                              style: TextStyle(
                                  fontSize: height * 0.02,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              place != null
                                  ? 'Location : ${place!.subLocality}, ${place!.locality}'
                                  : 'Unable to track location',
                              style: TextStyle(
                                  fontSize: height * 0.016,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.mainBGColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: IntrinsicHeight(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            punchIn,
                                            style: TextStyle(
                                                fontSize: height * 0.02,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.mainTextColor),
                                          ),
                                          Text(
                                            'Punch-in',
                                            style: TextStyle(
                                                fontSize: height * 0.014,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.mainTextColor),
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(
                                        color: Colors.black,
                                        thickness: 0.3,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            punchOut,
                                            style: TextStyle(
                                              fontSize: height * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.mainTextColor,
                                            ),
                                          ),
                                          Text(
                                            'Punch-Out',
                                            style: TextStyle(
                                                fontSize: height * 0.014,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.mainTextColor),
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(
                                        color: Colors.black,
                                        thickness: 0.3,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            formattedDuration,
                                            style: TextStyle(
                                              fontSize: height * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.mainTextColor,
                                            ),
                                          ),
                                          Text(
                                            'Total Hrs',
                                            style: TextStyle(
                                                fontSize: height * 0.014,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.mainTextColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  // onTap: _punchInTime != null ? null : _punchIn,
                                  onTap: _punchIn,
                                  child: Container(
                                    width: width / 3,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColor.primaryThemeColor,
                                            AppColor.secondaryThemeColor2,
                                          ]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      child: Center(
                                        child: Text(
                                          'Punch In',
                                          style: TextStyle(
                                              fontSize: height * 0.015,
                                              color: AppColor.mainFGColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  // onTap: _punchOutTime != null ? null : _punchOut,
                                  onTap: _punchOut,
                                  child: Container(
                                    width: width / 3,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColor.primaryThemeColor,
                                            AppColor.secondaryThemeColor2,
                                          ]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      child: Center(
                                        child: Text(
                                          'Punch Out',
                                          style: TextStyle(
                                              fontSize: height * 0.015,
                                              color: AppColor.mainFGColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          top: -height * 0.12,
                          child: GestureDetector(
                            onTap: () {
                              if (_selfie != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerScreen(
                                      imageFile: _selfie!,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.mainFGColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 50,
                                      color: const Color.fromARGB(
                                          255, 162, 162, 162),
                                      spreadRadius: 5)
                                ],
                              ),
                              child: _selfie == null
                                  ? CircleAvatar(
                                      backgroundColor: AppColor.mainBGColor,
                                      radius: 70,
                                      child: Image.asset(
                                        'assets/image/MaleAvatar.png',
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 70,
                                      backgroundColor: AppColor.mainBGColor,
                                      child: ClipOval(
                                        child: Image.file(
                                          _selfie!,
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final File imageFile;

  ImageViewerScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selfie Viewer')),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
