// // ignore_for_file: use_key_in_widget_ructors, depend_on_referenced_packages, must_be_immutable

// ignore_for_file: use_key_in_widget_constructors, prefer_if_null_operators, prefer_final_fields, prefer_conditional_assignment, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hrms/core/services/background_service.dart';
import 'package:hrms/core/utils/dialogbox_for_punchin.dart';
import 'package:hrms/core/utils/export_track_report.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../core/api/api.dart';
import '../../core/api/api_config.dart';
import '../../core/provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
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
  CameraController? _cameraController;

  File? _selfie;
  LatLng defaultLocation = LatLng(40.4168, -3.7038);
  LatLng? _currentLocation;
  String selectedStyleUrl = 'navigation-day-v1';
  String? filepath;
  bool cameraGranted = false;
  bool locationGranted = false;
  bool _isLoading = false;
  bool _loadingTrackPath = false;
  bool _isLoadingPO = false;
  bool _isLoadingUP = false;
  bool _isLoadingPI = false;
  List<Placemark>? placemarks;
  Placemark? place;
  MapController mapController = MapController();
  List<LatLng> _polylines = [];
  List<Marker> _markers = [];
  List<Map<String, dynamic>> _movementHistory = [];

  final List<Map<String, String>> mapStyles = [
    {
      'name': 'Outdoors',
      'url': 'outdoors-v12',
      'image': 'assets/image/outdoors-v12.png'
    },
    {
      'name': 'Satellite Streets',
      'url': 'satellite-streets-v12',
      'image': 'assets/image/satellite-streets-v12.png'
    },
    {
      'name': 'Navigation Night',
      'url': 'navigation-night-v1',
      'image': 'assets/image/navigation-night-v1.png'
    },
    {
      'name': 'Navigation Day',
      'url': 'navigation-day-v1',
      'image': 'assets/image/navigation-day-v1.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAndHandlePermissions();
    });
    _loadTrackedPathFromHive();
    _fitMapView();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authBox.get('bgActivityEnable') == false ||
        _authBox.get('bgActivityEnable') == null) {
      _authBox.put('bgActivityEnable', true);
      Future.delayed(Duration.zero, () {
        showBackgroundPermissionDialog(context);
      });
    }
  }

  void _fitMapView() {
    Future.delayed(Duration(seconds: 10), () {
      if (_polylines.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_polylines);

        final cameraFit = CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        );

        mapController.fitCamera(cameraFit);
      }
    });
  }

  void _loadTrackedPathFromHive() async {
    setState(() => _loadingTrackPath = true);
    try {
      final trackBox = Hive.box('trackBox');
      final markerBox = Hive.box('markerBox');

      List<LatLng> polylinePoints = [];
      for (int i = 0; i < trackBox.length; i++) {
        final entry = trackBox.getAt(i);
        if (entry is Map && entry['lat'] != null && entry['lng'] != null) {
          polylinePoints.add(LatLng(entry['lat'], entry['lng']));
        }
      }

      List<Map<String, dynamic>> markerList = [];
      for (int i = 0; i < markerBox.length; i++) {
        final entry = markerBox.getAt(i);
        if (entry is Map && entry['type'] != null) {
          markerList.add(Map<String, dynamic>.from(entry));
        }
      }

      markerList.sort((a, b) => DateTime.parse(a['timestamp'])
          .compareTo(DateTime.parse(b['timestamp'])));

      if (markerList.isNotEmpty) {
        markerList.last['type'] = 'last';
      }

      final markers = markerList.map((e) {
        final type = e['type'];
        IconData icon;
        Color color;

        switch (type) {
          case 'start':
            icon = CupertinoIcons.flag_fill;
            color = Colors.green;
            break;
          case 'moving':
            icon = Icons.directions_walk;
            color = Colors.green;
            break;
          case 'stopped':
            icon = CupertinoIcons.stop_circle_fill;
            color = Colors.red;
            break;
          case 'last':
            icon = CupertinoIcons.location_solid;
            color = Colors.red;
            break;
          default:
            icon = CupertinoIcons.location_solid;
            color = Colors.red;
        }

        return Marker(
          width: 32,
          height: 32,
          point: LatLng(e['lat'], e['lng']),
          child: Icon(icon, color: color, size: 28),
        );
      }).toList();

      setState(() {
        _polylines = polylinePoints;
        _markers = markers;
        _movementHistory = List.from(markerList);
        _loadingTrackPath = false;
      });
    } catch (e, stack) {
      debugPrint('❌ Failed loading Hive data: $e\n$stack');
    }
  }

  Future<void> _requestAndHandlePermissions() async {
    setState(() {
      _isLoading = true;
    });

    var status = await Permission.location.request();

    if (status.isGranted) {
      final pos = await geo.Geolocator.getCurrentPosition();

      geo.Position position = await geo.Geolocator.getCurrentPosition(
        locationSettings:
            geo.LocationSettings(accuracy: geo.LocationAccuracy.high),
      );

      placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        place = placemarks![0];
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapController.move(_currentLocation!, 17.0);
      });
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Please Enable Location'),
          content: Text('Enable Location or set it to always'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isLoading = true;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
    } catch (e) {
      print("Camera init failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to initialize camera")),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    geo.Position position = await geo.Geolocator.getCurrentPosition(
      locationSettings:
          geo.LocationSettings(accuracy: geo.LocationAccuracy.high),
    );

    placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      place = placemarks![0];
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(_currentLocation!, 17.0);
    });
  }

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selfie = File(pickedFile.path);
        filepath = pickedFile.path;
      });
      final fileSize = await _selfie!.length();

      await uplaodSelfie([
        PlatformFile(
          path: filepath,
          name: pickedFile.name,
          size: fileSize,
        ),
      ]);
    }
  }

  Future<void> uplaodSelfie(List<PlatformFile> files) async {
    final dio = Dio();

    for (var file in files) {
      if (file.path != null) {
        try {
          var formData = FormData.fromMap({
            'file':
                await MultipartFile.fromFile(file.path!, filename: file.name),
          });

          Response response = await dio.post(selfieUplaod, data: formData);

          if (response.statusCode == 200) {
            _authBox.put('selfie', response.data['location']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Selfie Uplaoded'),
                  backgroundColor: Colors.green),
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

  Future<void> _punchIn() async {
    setState(() => _isLoadingPI = true);
    var status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    }
    await _getCurrentLocation();

    if (_selfie == null) {
      await _takeSelfie();
    }

    if (_selfie != null && _currentLocation != null) {
      String location = place!.subLocality!.isNotEmpty
          ? '(IN)${place!.subLocality}, ${place!.locality}'
          : '(IN)${place!.locality}';

      _authBox.put('punchLocation', location);
      await manualPunchIn(context, location, _authBox.get('selfie'));

      if (Platform.isAndroid) {
        print('android detected');
        FlutterBackgroundService().invoke('setAsForeground');
        FlutterBackgroundService().startService();
      } else {
        startIosForegroundTracking();
      }
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
    setState(() => _isLoadingPO = true);
    await _getCurrentLocation();

    if (_currentLocation != null) {
      String location = place!.subLocality!.isNotEmpty
          ? '(OUT)${place!.subLocality}, ${place!.locality}'
          : '(OUT)${place!.locality}';
      String punchId = _authBox.get('Punch-In-id');

      final now = DateTime.now();
      final timestamp = now.toIso8601String();

      final markerBox = Hive.box('markerBox');
      await markerBox.add({
        'type': 'last',
        'lat': _currentLocation!.latitude,
        'lng': _currentLocation!.longitude,
        'time': DateFormat.Hm().format(now),
        'locality': place?.locality ?? '',
        'subLocality': place?.subLocality ?? '',
        'timestamp': timestamp,
      });

      if (Platform.isAndroid) {
        FlutterBackgroundService().invoke('stopService');
      } else {
        stopIosForegroundTracking();
      }
      await addPunchTrackHistory(context);
      await manualPunchOut(context, punchId, location);

      setState(() => _isLoadingPO = false);
    } else {
      setState(() => _isLoadingPO = false);
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
        final punchProvider = Provider.of<PunchedIN>(context, listen: false);
        await punchProvider.fetchAndSetPunchRecord();

        setState(() {
          _isLoadingPI = false;
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

    try {
      final response = await dio.post('$punchOutAction/$punchInId',
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }),
          data: {"location": location});

      if (response.statusCode == 200 || response.statusCode == 201) {
        _authBox.put('punchedIn', null);
        // _authBox.put('selfie', null);

        final punchProvider = Provider.of<PunchedIN>(context, listen: false);
        await punchProvider.fetchAndSetPunchRecord();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Punch-Out Success'),
          backgroundColor: Colors.green,
        ));
      }
    } on DioException catch (e) {
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

  Future<void> addPunchTrackHistory(BuildContext context) async {
    final String empID = _authBox.get('employeeId');
    final trackBox = Hive.box('trackBox');
    final markerBox = Hive.box('markerBox');

    List<Map<String, dynamic>> pathToSend = [];
    List<Map<String, dynamic>> markersToSend = [];

    // Prepare track path
    for (int i = 0; i < trackBox.length; i++) {
      final entry = trackBox.getAt(i);
      if (entry is Map &&
          entry['lat'] != null &&
          entry['lng'] != null &&
          entry['timestamp'] != null) {
        pathToSend.add({
          "lat": entry['lat'],
          "lng": entry['lng'],
          "timestamp": entry['timestamp'],
        });
      }
    }

    // Prepare markers
    for (int i = 0; i < markerBox.length; i++) {
      final entry = markerBox.getAt(i);
      if (entry is Map &&
          entry['lat'] != null &&
          entry['lng'] != null &&
          entry['type'] != null &&
          entry['timestamp'] != null) {
        markersToSend.add({
          "type": entry['type'],
          "lat": entry['lat'],
          "lng": entry['lng'],
          "time": entry['time'] ?? "",
          "locality": entry['locality'] ?? "",
          "subLocality": entry['subLocality'] ?? "",
          "duration": entry['duration'] ?? "",
          "timestamp": entry['timestamp'],
        });
      }
    }

    print('TrackPath Data : $pathToSend');
    print('Markers Data : $markersToSend');

    if (pathToSend.isEmpty && markersToSend.isEmpty) return;

    try {
      final response = await dio.post(
        postTrackHistory,
        queryParameters: {
          "employeeId": empID,
        },
        data: {
          "employeeId": empID,
          "trackPath": pathToSend,
          "markers": markersToSend,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Track data uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              e.response?.data['message'] ?? 'Failed to upload track data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String exportMovementHistoryToJson(List<Map<String, dynamic>> trackList) {
    return jsonEncode(trackList);
  }

  @override
  void dispose() {
    if (_cameraController?.value.isInitialized ?? false) {
      _cameraController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // locationService.invoke('stopService');
    //  Hive.box('movementBox').clear();
    //   Hive.box('markerBox').clear();
    //      Hive.box('trackBox').clear();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox(
            height: height / 1.4,
            child: _isLoading
                ? Container(
                    color: const Color.fromARGB(255, 198, 198, 198),
                    height: height / 1.4,
                    width: double.infinity,
                    child: Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.green,
                        size: height * 0.03,
                      ),
                    ),
                  )
                : FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation != null
                          ? _currentLocation!
                          : LatLng(28.6139, 77.2090),
                      initialZoom: 10.0,
                    ),
                    children: [
                      TileLayer(
                        // urlTemplate:
                        //     "https://api.mapbox.com/styles/v1/mapbox/$selectedStyleUrl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYWVyb2ZpdCIsImEiOiJjbWN5cWF3ZzMwcGVmMnJxeGM1OHY0OWljIn0.MdIEJmSfJFwcTElUoetFUA",
                        // userAgentPackageName: 'com.ddhealthcare.hrms_app',

                        // additionalOptions: {
                        //   'accessToken':
                        //       'pk.eyJ1IjoiYWVyb2ZpdCIsImEiOiJjbWN5cWF3ZzMwcGVmMnJxeGM1OHY0OWljIn0.MdIEJmSfJFwcTElUoetFUA',
                        // },
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      Visibility(
                        visible: _polylines.isNotEmpty,
                        child: PolylineLayer(
                          // polylineCulling: false,
                          polylines: [
                            Polyline(
                              points: _polylines,
                              color: const Color.fromARGB(255, 10, 100, 255),
                              strokeWidth: 10.0,
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: _markers.isNotEmpty,
                          child: MarkerLayer(markers: _markers)),
                      CurrentLocationLayer(
                        style: LocationMarkerStyle(
                          markerSize: Size.fromRadius(10),
                          accuracyCircleColor:
                              Color.fromARGB(120, 153, 207, 232),
                        ),
                      ),
                    ],
                  ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Consumer<PunchedIN>(
              builder: (context, punchProvider, _) {
                final record = punchProvider.record;

                final times = record?.getLastPunchTimes();
                if (record == null ||
                    !DateUtils.isSameDay(DateTime.now(), record.createdAt)) {
                  return _emptypunchinwidget(context, height, width);
                } else {
                  return _punchinWdiget(context, height, width, times!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Column _punchinWdiget(BuildContext context, double height, double width,
      Map<String, String> times) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.chevron_left,
                      color: AppColor.mainTextColor,
                      size: height * 0.023,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _movementHistory.isNotEmpty,
                child: InkWell(
                  onTap: () {
                    generateTrackingPdf(_movementHistory);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text(
                            "Export Track Record",
                            style: TextStyle(
                              fontSize: height * .015,
                            ),
                          ),
                          SizedBox(width: width * 0.015),
                          Icon(
                            CupertinoIcons.paperclip,
                            color: AppColor.mainTextColor,
                            size: height * 0.018,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  barrierColor: const Color.fromARGB(130, 0, 0, 0),
                  backgroundColor: Colors.transparent,
                  builder: (context) => Scaffold(
                    body: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColor.newgredient1,
                            const Color.fromARGB(52, 96, 125, 139),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Map Style (unavailable)",
                              style: TextStyle(
                                  fontSize: height * .018,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: height * 0.015),
                            SizedBox(
                              height: height * 0.1,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: mapStyles.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: width * 0.022),
                                itemBuilder: (context, index) {
                                  final style = mapStyles[index];
                                  final isSelected =
                                      style['url'] == selectedStyleUrl;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedStyleUrl = style['url']!;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          // width: 80,
                                          height: height * 0.08,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              style['image']!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          style['name']!,
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: height * 0.024),
                            Text(
                              "Navigations",
                              style: TextStyle(
                                  fontSize: height * .018,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: height * 0.012),
                            Expanded(
                              child: _movementHistory.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No movement data yet',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _movementHistory.length,
                                      itemBuilder: (context, index) {
                                        final entry = _movementHistory[index];
                                        final String type = entry['type'];
                                        final String time = entry['time'] ?? '';
                                        final String locality =
                                            entry['locality'] ?? '';
                                        final String subLocality =
                                            entry['subLocality'] ?? '';
                                        final String duration =
                                            entry['duration'] ?? '';
                                        final bool isMoving = type == 'moving';
                                        final bool isStopped =
                                            type == 'stopped';
                                        final bool isStart = type == 'start';
                                        final bool isLast = type == 'last';

                                        IconData icon;
                                        Color iconColor;

                                        if (isStart) {
                                          icon = CupertinoIcons.flag_fill;
                                          iconColor = Colors.green;
                                        } else if (isMoving) {
                                          icon = Icons.directions_walk;
                                          iconColor = Colors.green;
                                        } else if (isLast) {
                                          icon = CupertinoIcons.location_solid;
                                          iconColor = Colors.red;
                                        } else {
                                          icon =
                                              CupertinoIcons.stop_circle_fill;
                                          iconColor = Colors.red;
                                        }

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(icon,
                                                  color: iconColor, size: 28),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      isStart
                                                          ? 'Started at $time'
                                                          : isLast
                                                              ? 'Ended at $time'
                                                              : isMoving
                                                                  ? 'Moving at $time'
                                                                  : 'Stopped at $time',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Location: $locality $subLocality',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    if (isStopped &&
                                                        duration.isNotEmpty)
                                                      Text(
                                                        'Stopped for: $duration',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.deepPurple,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      CupertinoIcons.timelapse,
                      color: AppColor.mainTextColor,
                      size: height * 0.023,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    border:
                        Border.all(color: Color.fromARGB(78, 123, 158, 177))),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: width * .2,
                        height: height * 0.09,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(78, 123, 158, 177)),
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xFFC9D9D5)),
                        child: _authBox.get('selfie') != null
                            ? Image.network(
                                _authBox.get('selfie'),
                                fit: BoxFit.fitWidth,
                              )
                            : Image.asset('assets/image/MaleAvatar.png'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: Color.fromARGB(255, 85, 85, 85),
                          ),
                        ),
                        SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            _getCurrentLocation();
                            _loadTrackedPathFromHive();
                          },
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
                                      ? place!.subLocality!.isNotEmpty
                                          ? ' ${place!.subLocality}, ${place!.locality} (Tap to Refresh)'
                                          : '${place!.locality!} (Tap to Refresh)'
                                      : 'Tap to Refresh',
                                  style: TextStyle(
                                    fontSize: height * .016,
                                    color: Color.fromARGB(255, 85, 85, 85),
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
                            color: Color.fromARGB(78, 123, 158, 177)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${times['lastIn']}',
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
                            color: Color.fromARGB(78, 123, 158, 177)),
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${times['lastOut']}',
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Center(
                      child: _isLoadingPI || _loadingTrackPath
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _updatePunchLocation,
                        child: Container(
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
                            child: _isLoadingUP || _loadingTrackPath
                                ? SizedBox(
                                    height: height * 0.02,
                                    width: width * 0.05,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeCap: StrokeCap.round,
                                      strokeWidth: 2,
                                    ))
                                : Text(
                                    'Update Location',
                                    style: TextStyle(
                                        fontSize: height * 0.015,
                                        color: AppColor.mainFGColor),
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
                              colors: [Colors.black45, Colors.black],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Center(
                            child: _isLoadingPO || _loadingTrackPath
                                ? SizedBox(
                                    height: height * 0.02,
                                    width: width * 0.05,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeCap: StrokeCap.round,
                                      strokeWidth: 2,
                                    ))
                                : Text(
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
                ),
              ),
              SizedBox(
                height: height * 0.02,
              )
            ],
          ),
        ),
      ],
    );
  }

  Column _emptypunchinwidget(
      BuildContext context, double height, double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.chevron_left,
                      color: AppColor.mainTextColor,
                      size: height * 0.023,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _movementHistory.isNotEmpty,
                child: InkWell(
                  onTap: () {
                    generateTrackingPdf(_movementHistory);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Text(
                            "Export Track Record",
                            style: TextStyle(
                              fontSize: height * .015,
                            ),
                          ),
                          SizedBox(width: width * 0.015),
                          Icon(
                            CupertinoIcons.paperclip,
                            color: AppColor.mainTextColor,
                            size: height * 0.018,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  barrierColor: const Color.fromARGB(130, 0, 0, 0),
                  backgroundColor: Colors.transparent,
                  builder: (context) => Scaffold(
                    body: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColor.newgredient1,
                            const Color.fromARGB(52, 96, 125, 139),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                       "Map Style (unavailable)",
                              style: TextStyle(
                                  fontSize: height * .018,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: height * 0.015),
                            SizedBox(
                              height: height * 0.1,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: mapStyles.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: width * 0.022),
                                itemBuilder: (context, index) {
                                  final style = mapStyles[index];
                                  final isSelected =
                                      style['url'] == selectedStyleUrl;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedStyleUrl = style['url']!;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          // width: 80,
                                          height: height * 0.08,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              style['image']!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          style['name']!,
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: height * 0.024),
                            Text(
                              "Navigations",
                              style: TextStyle(
                                  fontSize: height * .018,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: height * 0.012),
                            Expanded(
                              child: _movementHistory.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No movement data yet ',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _movementHistory.length,
                                      itemBuilder: (context, index) {
                                        final entry = _movementHistory[index];
                                        final isMoving =
                                            entry['type'] == 'moving';

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isMoving
                                                    ? Icons.directions_walk
                                                    : Icons.stop_circle,
                                                color: isMoving
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 28,
                                              ),
                                              SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isMoving
                                                        ? 'Moving ${entry['time']}'
                                                        : 'Stopped ${entry['time']}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Location : ${entry['locality']} ${entry['subLocality']}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      CupertinoIcons.timelapse,
                      color: AppColor.mainTextColor,
                      size: height * 0.023,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    border:
                        Border.all(color: Color.fromARGB(78, 123, 158, 177))),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                          width: width * .2,
                          height: height * 0.09,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(78, 123, 158, 177)),
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFFC9D9D5)),
                          child: Image.asset('assets/image/MaleAvatar.png')),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: Color.fromARGB(255, 85, 85, 85),
                          ),
                        ),
                        SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            _getCurrentLocation();
                            _loadTrackedPathFromHive();
                          },
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
                                      ? place!.subLocality!.isNotEmpty
                                          ? ' ${place!.subLocality}, ${place!.locality} (Tap to Refresh)'
                                          : '${place!.locality!} (Tap to Refresh)'
                                      : 'Tap to Refresh',
                                  style: TextStyle(
                                    fontSize: height * .016,
                                    color: Color.fromARGB(255, 85, 85, 85),
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
                            color: Color.fromARGB(78, 123, 158, 177)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '--/--',
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
                            color: Color.fromARGB(78, 123, 158, 177)),
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '--/--',
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

              InkWell(
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

              SizedBox(
                height: height * 0.02,
              )
            ],
          ),
        ),
      ],
    );
  }
}
