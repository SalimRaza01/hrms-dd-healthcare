

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

final FlutterLocalNotificationsPlugin plugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await plugin.show(
    0,
    'DD HRMS',
    'Ready to Track Location',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'my_foreground',
        'Foreground Service',
        channelDescription: 'Used for background location tracking',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Tracking Location',
      initialNotificationContent: 'Running in background',
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}



@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  // final appDir = await getApplicationDocumentsDirectory();
  // Hive.init(appDir.path);
  await Hive.initFlutter();
  final Box movementBox = await Hive.openBox('movementBox');

  LatLng? _previousLocation;
  LatLng? _lastStationaryLocation;
  DateTime? _stationaryStartTime;
  DateTime? _lastStopTime;
  bool _isStopped = false;


  void handleLocationUpdate(geo.Position position) async {
  final now = DateTime.now();
  final current = LatLng(position.latitude, position.longitude);
  final timestamp = now.toIso8601String();
  print('Update at $timestamp: $current');

  final placemarks = await placemarkFromCoordinates(
    current.latitude,
    current.longitude,
  );
  final mark = placemarks.first;
  final locality = mark.locality ?? mark.subAdministrativeArea ?? 'Unknown';
  final subLocality = mark.subLocality ?? mark.subAdministrativeArea ?? 'Unknown';

  final distance = _previousLocation != null
      ? Distance().as(LengthUnit.Meter, _previousLocation!, current)
      : 0.0;

  final isStationary = _lastStationaryLocation != null &&
      Distance().as(LengthUnit.Meter, _lastStationaryLocation!, current) <= 15;

  print(' Distance: ${distance.toStringAsFixed(2)}m | Stationary: $isStationary');

  if (_previousLocation == null) {

    _previousLocation = current;
    _stationaryStartTime = now;
    _lastStationaryLocation = current;
    return;
  }

  if (isStationary) {
    _stationaryStartTime ??= now;

    if (!_isStopped &&
        now.difference(_stationaryStartTime!).inMinutes >= 2) {
      final stopDuration = _lastStopTime != null
          ? now.difference(_lastStopTime!)
          : Duration.zero;

      await movementBox.add({
        'type': 'stopped',
        'lat': current.latitude,
        'lng': current.longitude,
        'time': DateFormat.Hm().format(now),
        'locality': locality,
        'subLocality': subLocality,
        'duration': '${stopDuration.inMinutes}m ${stopDuration.inSeconds % 60}s',
        'timestamp': timestamp,
      });

      print('Stopped logged at $current');
      _lastStopTime = now;
      _isStopped = true;
    }
  } else {

    _stationaryStartTime = now;
    _lastStationaryLocation = current;

  
    await movementBox.add({
      'type': 'moving',
      'lat': current.latitude,
      'lng': current.longitude,
      'time': DateFormat.Hm().format(now),
      'locality': locality,
      'subLocality': subLocality,
      'distance': distance.toStringAsFixed(2),
      'timestamp': timestamp,
    });

    print('Movement logged at $current');
    _isStopped = false;
  }

  _previousLocation = current;


  await plugin.show(
    0,
    'DD HRMS',
    'Auto Location Update at ${movementBox.length}',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'my_foreground',
        'Foreground Service',
        channelDescription: 'Used for background location tracking',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );

  service.invoke('update', {
    "lat": current.latitude,
    "lng": current.longitude,
  });
}



  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: "DD HRMS",
      content: "Tracking location in background",
    );
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  geo.Geolocator.getPositionStream(
    locationSettings: geo.LocationSettings(
      accuracy: geo.LocationAccuracy.bestForNavigation,
      distanceFilter: 15,
      timeLimit: null
    ),
  ).listen((position) {
        
    handleLocationUpdate(position);
    print(' Update received at ${DateTime.now()}: ${position.latitude}, ${position.longitude}');

  }, onError: (e) {
    debugPrint(" Position Stream Error: $e");
  });
}


