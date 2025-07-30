

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

StreamSubscription<geo.Position>? _iosPositionStream;

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
  await Hive.initFlutter();

  final Box trackBox = await Hive.openBox('trackBox');   
  final Box markerBox = await Hive.openBox('markerBox');   

  LatLng? _previousLocation;
  LatLng? _lastStationaryLocation;
  DateTime? _stationaryStartTime;
  DateTime? _lastStopTime;
  bool _isStopped = false;
  bool _hasLoggedStart = false;
  bool _hasLoggedMovingAfterStop = false;

  void handleLocationUpdate(geo.Position position) async {
    final now = DateTime.now();
    final current = LatLng(position.latitude, position.longitude);
    final timestamp = now.toIso8601String();

    final distance = _previousLocation != null
        ? Distance().as(LengthUnit.Meter, _previousLocation!, current)
        : 0.0;

    if (_previousLocation != null && distance < 10) {
      print('Ignored GPS jitter: $distance m');
      return;
    }

 
    await trackBox.add({
      'lat': current.latitude,
      'lng': current.longitude,
      'timestamp': timestamp,
    });

    final placemarks = await placemarkFromCoordinates(
      current.latitude,
      current.longitude,
    );
    final mark = placemarks.first;
    final locality = mark.locality ?? mark.subAdministrativeArea ?? 'Unknown';
    final subLocality = mark.subLocality ?? mark.subAdministrativeArea ?? 'Unknown';

    final isStationary = _lastStationaryLocation != null &&
        Distance().as(LengthUnit.Meter, _lastStationaryLocation!, current) <= 50;


    if (!_hasLoggedStart) {
      await markerBox.add({
        'type': 'start',
        'lat': current.latitude,
        'lng': current.longitude,
        'time': DateFormat.Hm().format(now),
        'locality': locality,
        'subLocality': subLocality,
        'timestamp': timestamp,
      });
      print(' Start marker at $current');
      _hasLoggedStart = true;
      _previousLocation = current;
      _stationaryStartTime = now;
      _lastStationaryLocation = current;
      return;
    }

    if (isStationary) {
      _stationaryStartTime ??= now;

      if (!_isStopped && now.difference(_stationaryStartTime!).inMinutes >= 5) {
        final stopDuration = _lastStopTime != null
            ? now.difference(_lastStopTime!)
            : Duration.zero;

        await markerBox.add({
          'type': 'stopped',
          'lat': current.latitude,
          'lng': current.longitude,
          'time': DateFormat.Hm().format(now),
          'locality': locality,
          'subLocality': subLocality,
          'duration': '${stopDuration.inMinutes}m ${stopDuration.inSeconds % 60}s',
          'timestamp': timestamp,
        });

        print(' Stopped marker at $current');
        _lastStopTime = now;
        _isStopped = true;
        _hasLoggedMovingAfterStop = false;
      }
    } else {
      _stationaryStartTime = now;
      _lastStationaryLocation = current;

      if (_isStopped || !_hasLoggedMovingAfterStop) {
        await markerBox.add({
          'type': 'moving',
          'lat': current.latitude,
          'lng': current.longitude,
          'time': DateFormat.Hm().format(now),
          'locality': locality,
          'subLocality': subLocality,
          'distance': distance.toStringAsFixed(2),
          'timestamp': timestamp,
        });
        print('🚶 Moving marker at $current');
        _hasLoggedMovingAfterStop = true;
      }

      _isStopped = false;
    }

    _previousLocation = current;

    await plugin.show(
      0,
      'DD HRMS',
      'Tracking: ${trackBox.length} points',
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
      distanceFilter: 30,
    ),
  ).listen((position) {
    handleLocationUpdate(position);
    print(' New position: ${position.latitude}, ${position.longitude}');
  }, onError: (e) {
    debugPrint("❌ Location error: $e");
  });
}


void startIosForegroundTracking() async {
  final trackBox = await Hive.openBox('trackBox');
  final markerBox = await Hive.openBox('markerBox');

  LatLng? _previousLocation;
  LatLng? _lastStationaryLocation;
  DateTime? _stationaryStartTime;
  DateTime? _lastStopTime;
  bool _isStopped = false;
  bool _hasLoggedStart = false;
  bool _hasLoggedMovingAfterStop = false;

  _iosPositionStream = geo.Geolocator.getPositionStream(
    locationSettings: geo.LocationSettings(
      accuracy: geo.LocationAccuracy.bestForNavigation,
      distanceFilter: 50,
    ),
  ).listen((position) async {
    final now = DateTime.now();
    final current = LatLng(position.latitude, position.longitude);
    final timestamp = now.toIso8601String();

    final distance = _previousLocation != null
        ? Distance().as(LengthUnit.Meter, _previousLocation!, current)
        : 0.0;

    if (_previousLocation != null && distance < 10) {
      print('📉 Ignored jitter: $distance m');
      return;
    }

    await trackBox.add({
      'lat': current.latitude,
      'lng': current.longitude,
      'timestamp': timestamp,
    });

    final placemarks = await placemarkFromCoordinates(
      current.latitude,
      current.longitude,
    );
    final mark = placemarks.first;
    final locality = mark.locality ?? mark.subAdministrativeArea ?? 'Unknown';
    final subLocality =
        mark.subLocality ?? mark.subAdministrativeArea ?? 'Unknown';

    final isStationary = _lastStationaryLocation != null &&
        Distance().as(LengthUnit.Meter, _lastStationaryLocation!, current) <= 50;

    if (!_hasLoggedStart) {
      await markerBox.add({
        'type': 'start',
        'lat': current.latitude,
        'lng': current.longitude,
        'time': DateFormat.Hm().format(now),
        'locality': locality,
        'subLocality': subLocality,
        'timestamp': timestamp,
      });
      print('📍 iOS Start marker at $current');
      _hasLoggedStart = true;
      _previousLocation = current;
      _stationaryStartTime = now;
      _lastStationaryLocation = current;
      return;
    }

    if (isStationary) {
      _stationaryStartTime ??= now;
      if (!_isStopped && now.difference(_stationaryStartTime!).inMinutes >= 5) {
        final stopDuration = _lastStopTime != null
            ? now.difference(_lastStopTime!)
            : Duration.zero;

        await markerBox.add({
          'type': 'stopped',
          'lat': current.latitude,
          'lng': current.longitude,
          'time': DateFormat.Hm().format(now),
          'locality': locality,
          'subLocality': subLocality,
          'duration':
              '${stopDuration.inMinutes}m ${stopDuration.inSeconds % 60}s',
          'timestamp': timestamp,
        });

        print('🛑 iOS Stopped marker at $current');
        _lastStopTime = now;
        _isStopped = true;
        _hasLoggedMovingAfterStop = false;
      }
    } else {
      _stationaryStartTime = now;
      _lastStationaryLocation = current;

      if (_isStopped || !_hasLoggedMovingAfterStop) {
        await markerBox.add({
          'type': 'moving',
          'lat': current.latitude,
          'lng': current.longitude,
          'time': DateFormat.Hm().format(now),
          'locality': locality,
          'subLocality': subLocality,
          'distance': distance.toStringAsFixed(2),
          'timestamp': timestamp,
        });
        print('🚶 iOS Moving marker at $current');
        _hasLoggedMovingAfterStop = true;
      }

      _isStopped = false;
    }

    _previousLocation = current;
  }, onError: (e) {
    debugPrint("❌ iOS tracking error: $e");
  });
}

void stopIosForegroundTracking() {
  _iosPositionStream?.cancel();
  _iosPositionStream = null;
  print("🛑 iOS foreground tracking stopped");
}