// ignore_for_file: use_key_in_widget_constructors, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/provider/provider.dart';
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
import 'package:provider/provider.dart';

class ManualPunchInScreen extends StatefulWidget {
  @override
  State<ManualPunchInScreen> createState() => _ManualPunchInScreenState();
}

class _ManualPunchInScreenState extends State<ManualPunchInScreen> {
  final Box _authBox = Hive.box('authBox');
  late CameraController _cameraController;
  File? _selfie;
  LatLng? _currentLocation;
  bool _isLoading = false;
  List<Placemark>? placemarks;
  Placemark? place;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<String> convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
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
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _isLoading = false;
        });
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

  Future<void> _punchIn() async {
    await _getCurrentLocation();

    if (_selfie == null) {
      await _takeSelfie();
    }

    if (_selfie != null && _currentLocation != null) {
      setState(() => _isLoading = true);

      String base64Image = await convertImageToBase64(_selfie!);
      String location = place!.subLocality!.isNotEmpty
          ? '(IN)${place!.subLocality}, ${place!.locality}'
          : '(IN)${place!.locality}';
      _authBox.put('punchLocation', location);
      await manualPunchIn(context, location, base64Image);

      setState(() => _isLoading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to punch in'),
      ));
    }
  }

  Future<void> _updatePunchLocation() async {
    await _getCurrentLocation();

    if (_currentLocation != null) {
      String location = place!.subLocality!.isNotEmpty
          ? '(UP)${place!.subLocality}, ${place!.locality}'
          : '(UP)${place!.locality}';
      _authBox.put('punchLocation', location);
      String punchId = _authBox.get('Punch-In-id');

      await updateLocation(context, punchId, location);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location not available for Punch-Out'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _punchOut() async {
    await _getCurrentLocation();

    if (_currentLocation != null) {
      String location = place!.subLocality!.isNotEmpty
          ? '(OUT)${place!.subLocality}, ${place!.locality}'
          : '(OUT)${place!.locality}';

      String punchId = _authBox.get('Punch-In-id');

      await manualPunchOut(context, punchId, location);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location not available for Punch-Out'),
          backgroundColor: Colors.red,
        ),
      );
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: AppColor.mainFGColor,
                size: height * 0.05,
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
                              const Color.fromARGB(120, 153, 207, 232)),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Consumer<PunchedIN>(
                        builder: (context, punchProvider, _) {
                          final record = punchProvider.record;

                          if (record == null) {
                            return newMethod(height, width, context);
                          }

                          final now = DateTime.now();
                          final times = record.getLastPunchTimes();

                          if (!DateUtils.isSameDay(now, record.createdAt)) {
                            return newMethod(height, width, context);
                          }

                          return Container(
                            height: height / 3,
                            width: width,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColor.mainFGColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.shadowColor,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(height: height * 0.03),
                                Text(
                                  _authBox.get('employeeName'),
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    color: AppColor.mainTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  place != null
                                      ? place!.subLocality!.isNotEmpty
                                          ? 'Location : ${place!.subLocality}, ${place!.locality}'
                                          : 'Location : ${place!.locality}'
                                      : 'Unable to track location',
                                  style: TextStyle(
                                    fontSize: height * 0.016,
                                    color:
                                        const Color.fromARGB(255, 57, 134, 60),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.mainBGColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 7),
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
                                            children: [
                                              Text(
                                                '${times['lastIn']}',
                                                style: TextStyle(
                                                  fontSize: height * 0.02,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColor.mainTextColor,
                                                ),
                                              ),
                                              Text(
                                                'Punch-in',
                                                style: TextStyle(
                                                  fontSize: height * 0.014,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.mainTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          VerticalDivider(
                                            color: AppColor.mainTextColor,
                                            thickness: 0.3,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${times['lastOut']}',
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
                                                  color: AppColor.mainTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Visibility(
                                  visible: _authBox.get('punchedIn') == null,
                                  child: InkWell(
                                    onTap: _punchIn,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.lightGreen,
                                            Colors.green
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      child: Center(
                                        child: Text(
                                          'Punch-In',
                                          style: TextStyle(
                                              fontSize: height * 0.015,
                                              color: AppColor.mainFGColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _authBox.get('punchedIn') != null,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: _updatePunchLocation,
                                        child: Container(
                                          width: width / 2.5,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.lightGreen,
                                                Colors.green
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12),
                                          child: Center(
                                            child: Text(
                                              'Update Location',
                                              style: TextStyle(
                                                  fontSize: height * 0.015,
                                                  color: AppColor.mainFGColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _punchOut,
                                        child: Container(
                                          width: width / 2.5,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black45,
                                                Colors.black
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
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
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.04,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: -height * 0.10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.mainFGColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 50,
                                color: AppColor.shadowColor,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: _authBox.get('selfie') == null
                              ? CircleAvatar(
                                  backgroundColor: AppColor.mainBGColor,
                                  radius: 70,
                                  child: Image.asset(
                                    'assets/image/MaleAvatar.png',
                                    height: height * 0.135,
                                    width: width * 0.3,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 70,
                                  backgroundColor: AppColor.mainBGColor,
                                  child: ClipOval(
                                    child: Image.memory(
                                      _authBox.get('selfie'),
                                      height: height * 0.135,
                                      width: width * 0.3,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Container newMethod(double height, double width, BuildContext context) {
    return Container(
      height: height / 3,
      width: width,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.mainFGColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: height * 0.04,
          ),
          Text(
            _authBox.get('employeeName'),
            style: TextStyle(
                fontSize: height * 0.02,
                color: AppColor.mainTextColor,
                fontWeight: FontWeight.w500),
          ),
          Text(
            place != null
                ? place!.subLocality!.isNotEmpty
                    ? 'Location : ${place!.subLocality}, ${place!.locality}'
                    : 'Location : ${place!.locality}'
                : 'Unable to track location',
            style: TextStyle(
                fontSize: height * 0.016,
                color: Colors.green,
                fontWeight: FontWeight.w400),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.mainBGColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '--/--',
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
                      color: AppColor.mainTextColor,
                      thickness: 0.3,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '--/--',
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
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: _punchIn,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.lightGreen,
                      Colors.green,
                    ]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Center(
                  child: Text(
                    'Punch In',
                    style: TextStyle(
                        fontSize: height * 0.015, color: AppColor.mainFGColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class ImageViewerScreen extends StatelessWidget {
//   final File imageFile;

//   const ImageViewerScreen({required this.imageFile});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Selfie Viewer')),
//       body: Center(
//         child: Image.file(imageFile),
//       ),
//     );
//   }
// }
