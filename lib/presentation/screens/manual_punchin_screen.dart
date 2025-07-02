// // ignore_for_file: use_key_in_widget_ructors, depend_on_referenced_packages, must_be_immutable

// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import '../../core/api/api.dart';
import '../../core/api/api_config.dart';
import '../../core/provider/provider.dart';
import '../../core/theme/app_colors.dart';
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
  bool _isLoadingPO = false;
  bool _isLoadingUP = false;
  bool _isLoadingPI = false;
  List<Placemark>? placemarks;
  Placemark? place;

  @override
  void initState() {
    super.initState();
    _requestPlatformPermissions();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _requestPlatformPermissions() async {
    bool cameraGranted = false;
    bool locationGranted = false;

    if (Platform.isAndroid) {
      cameraGranted = await Permission.camera.request().isGranted;
      locationGranted = await Permission.location.request().isGranted;
    } else if (Platform.isIOS) {
      cameraGranted = await Permission.camera.request().isGranted;
      locationGranted = await Permission.locationWhenInUse.request().isGranted;
    }

    if (cameraGranted && locationGranted) {
      await _initializeCamera();
      await _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera or Location permission denied")),
      );
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        place = placemarks![0];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving location')),
      );
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

  Future<String> compressAndConvertToBase64(File file) async {
    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 360,
      minHeight: 640,
      quality: 60,
    );
    return base64Encode(compressedBytes!);
  }

  Future<void> _punchIn() async {
    await _getCurrentLocation();

    if (_selfie == null) {
      await _takeSelfie();
    }

    if (_selfie != null && _currentLocation != null) {
      setState(() => _isLoading = true);

      String base64Image = await compressAndConvertToBase64(_selfie!);
      String location = place!.subLocality!.isNotEmpty
          ? '(IN)${place!.subLocality}, ${place!.locality}'
          : '(IN)${place!.locality}';

      _authBox.put('punchLocation', location);
      await manualPunchIn(context, location, base64Image);
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
          content: Text('Location not available for update'),
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

  Future<void> manualPunchIn(
    BuildContext context,
    String location,
    String imageUrl64,
  ) async {
    String empID = _authBox.get('employeeId');
    String token = _authBox.get('token');
    setState(() => _isLoadingPI = true);

    try {
      final response = await dio.post(punchinAction,
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }),
          data: {
            "employeeId": empID,
            "location": location,
            "imageUrl": imageUrl64,
          });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _authBox.put('punchedIn', 'yes');
        await _authBox.put('Punch-In-id', response.data['data']['_id']);
        await _authBox.put(
            'selfie', decodeBase64Image(response.data['data']['imageUrl']));
        final punchProvider = Provider.of<PunchedIN>(context, listen: false);
        await punchProvider.fetchAndSetPunchRecord();

        setState(() {
          _isLoadingPI = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Punch-In Success'),
          backgroundColor: Colors.green,
        ));
      }
    } on DioException catch (e) {
      setState(() => _isLoadingPI = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.data['message'] ?? 'Punch-In failed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> manualPunchOut(
      BuildContext context, String punchInId, String location) async {
    String token = _authBox.get('token');
    setState(() => _isLoadingPO = true);

    try {
      final response = await dio.post('$punchOutAction/$punchInId',
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }),
          data: {"location": location});

      if (response.statusCode == 200 || response.statusCode == 201) {
        _authBox.put('punchedIn', null);
        _authBox.put('selfie', null);

        final punchProvider = Provider.of<PunchedIN>(context, listen: false);
        await punchProvider.fetchAndSetPunchRecord();

        setState(() => _isLoadingPO = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Punch-Out Success'),
          backgroundColor: Colors.green,
        ));
      }
    } on DioException catch (e) {
      setState(() => _isLoadingPO = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.data['message'] ?? 'Punch-Out failed'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> updateLocation(
      BuildContext context, String id, String location) async {
    setState(() => _isLoadingUP = true);
    try {
      final response = await dio.put('$updatePunchLocation/$id', data: {
        "location": location,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final punchProvider = Provider.of<PunchedIN>(context, listen: false);
        await punchProvider.fetchAndSetPunchRecord();

        setState(() => _isLoadingUP = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location Updated Successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Update Failed'),
          backgroundColor: Colors.red,
        ));
      }
    } on DioException catch (e) {
      setState(() => _isLoadingUP = false);
      print(e);
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

    //  final String? punchStatus = widget.alreadyPunchIn;

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
                              Color.fromARGB(120, 153, 207, 232)),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Consumer<PunchedIN>(
                    builder: (context, punchProvider, _) {
                      final record = punchProvider.record;
                      // final now = DateTime.now();
                      final times = record?.getLastPunchTimes();
                      // final isToday = record != null &&
                      //     DateUtils.isSameDay(now, record.createdAt);
                      // final isPunchedIn = _authBox.get('punchedIn') != null;

                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              spreadRadius: 3,
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// Profile Section
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(78, 123, 158, 177))),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: width * .2,
                                      height: height * 0.09,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  78, 123, 158, 177)),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xFFC9D9D5)),
                                      child: _authBox.get('selfie') == null
                                          ? Image.asset(
                                              'assets/image/MaleAvatar.png')
                                          : Image.memory(
                                              _authBox.get('selfie'),
                                              fit: BoxFit.fitWidth,
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _authBox.get('employeeName') ?? '',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now())
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              Color.fromARGB(255, 85, 85, 85),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      InkWell(
                                        onTap: _getCurrentLocation,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_pin,
                                              size: height * .016,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 4),
                                            SizedBox(
                                              width: width * 0.45,
                                              child: Text(
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                place != null
                                                    ? place!.subLocality!
                                                            .isNotEmpty
                                                        ? ' ${place!.subLocality}, ${place!.locality}'
                                                        : place!.locality!
                                                    : 'Tap to fetch location',
                                                style: TextStyle(
                                                  fontSize: height * .016,
                                                  color: Color.fromARGB(
                                                      255, 85, 85, 85),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: height * .016,
                            ),

                            /// Schedule Tiles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    // width: width,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      border: Border.all(
                                          color: Color.fromARGB(
                                              78, 123, 158, 177)),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          times == null
                                              ? '--/--'
                                              : '${times['lastIn']}',
                                          // '',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Punch-In',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: width * .03,
                                ),
                                Expanded(
                                  child: Container(
                                    // width: width,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color.fromARGB(
                                              78, 123, 158, 177)),
                                      color: Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          times == null
                                              ? '--/--'
                                              : '${times['lastOut']}',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Punch-Out',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: height * .016,
                            ),

                            Visibility(
                              visible: _authBox.get('punchedIn') == null,
                              child: InkWell(
                                onTap: _punchIn,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.lightGreen, Colors.green],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Center(
                                    child: _isLoadingPI
                                        ? SizedBox(
                                            height: height * 0.02,
                                            width: width * 0.05,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeCap: StrokeCap.round,
                                              strokeWidth: 2,
                                            ))
                                        : Text(
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
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _updatePunchLocation,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        child: Center(
                                          child: _isLoadingUP
                                              ? SizedBox(
                                                  height: height * 0.02,
                                                  width: width * 0.05,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeCap: StrokeCap.round,
                                                    strokeWidth: 2,
                                                  ))
                                              : Text(
                                                  'Update Location',
                                                  style: TextStyle(
                                                      fontSize: height * 0.015,
                                                      color:
                                                          AppColor.mainFGColor),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * .03,
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _punchOut,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        child: Center(
                                          child: _isLoadingPO
                                              ? SizedBox(
                                                  height: height * 0.02,
                                                  width: width * 0.05,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeCap: StrokeCap.round,
                                                    strokeWidth: 2,
                                                  ))
                                              : Text(
                                                  'Punch Out',
                                                  style: TextStyle(
                                                      fontSize: height * 0.015,
                                                      color:
                                                          AppColor.mainFGColor),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                 Padding(
                   padding: const EdgeInsets.only(top: 25, left: 15),
                   child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(178, 216, 225, 231),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.chevron_left,
                              color: AppColor.mainTextColor,
                              size: height * 0.02,
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
