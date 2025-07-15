// import 'dart:async';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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

  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  final Box movementBox = await Hive.openBox('movementBox');

  LatLng? _previousLocation;
  LatLng? _lastStationaryLocation;
  DateTime? _stationaryStartTime;
  DateTime? _lastStopTime;
  bool _isStopped = false;
  Timer? _timer;

  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: "DD HRMS",
      content: "Tracking location in background",
    );
  }

  service.on('stopService').listen((event) {
    _timer?.cancel();
    service.stopSelf();
  });

  _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.bestForNavigation,
      );

      final now = DateTime.now();
      final current = LatLng(position.latitude, position.longitude);
      final timestamp = now.toIso8601String();

      final placemarks = await placemarkFromCoordinates(
        current.latitude,
        current.longitude,
      );
      final mark = placemarks.first;
      final locality = mark.locality ?? mark.subAdministrativeArea ?? 'Unknown';
      final subLocality = mark.subLocality ?? mark.subAdministrativeArea ?? 'Unknown';

      if (_previousLocation == null) {
        _previousLocation = current;
        _stationaryStartTime = now;
        _lastStationaryLocation = current;
        return;
      }

      final distance = Distance().as(
        LengthUnit.Meter,
        _previousLocation!,
        current,
      );

      final isStationary = Distance().as(
            LengthUnit.Meter,
            _lastStationaryLocation!,
            current,
          ) <=
          25;

      if (isStationary) {
        _stationaryStartTime ??= now;

        if (!_isStopped &&
            now.difference(_stationaryStartTime!).inMinutes >= 2) {
          final stopDuration = _lastStopTime != null
              ? now.difference(_lastStopTime!)
              : Duration.zero;

          _lastStopTime = now;

          await movementBox.add({
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

          _isStopped = true;
        }
      } else {
        _stationaryStartTime = now;
        _lastStationaryLocation = current;

        if (_isStopped) {
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

          _isStopped = false;
        }
      }

      _previousLocation = current;

      if (service is AndroidServiceInstance &&
          await service.isForegroundService()) {
        await service.setForegroundNotificationInfo(
          title: "DD HRMS",
          content: "Auto Location Update",
        );
      }

      service.invoke('update', {
        "lat": current.latitude,
        "lng": current.longitude,
      });
    } catch (e) {
      debugPrint("Error in background tracking with Timer: $e");
    }
  });
}


// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();

//   final appDir = await getApplicationDocumentsDirectory();
//   Hive.init(appDir.path);

//   final Box trackBox = await Hive.openBox('trackBox');
//   final Box movementBox = await Hive.openBox('movementBox');
//   final Box markerBox = await Hive.openBox('markerBox');

//   LatLng? _previousLocation;
//   LatLng? _lastStationaryLocation;
//   DateTime? _stationaryStartTime;
//   DateTime? _lastStopTime;
//   bool _isStopped = false;
//   Timer? _timer;

//   if (service is AndroidServiceInstance) {
//     await service.setForegroundNotificationInfo(
//       title: "DD HRMS",
//       content: "Tracking location in background",
//     );
//   }

//   service.on('stopService').listen((event) {
//     _timer?.cancel();
//     service.stopSelf();
//   });

//   _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
//     try {
//       final position = await geo.Geolocator.getCurrentPosition(
//         desiredAccuracy: geo.LocationAccuracy.bestForNavigation,
//       );

//       LatLng current = LatLng(position.latitude, position.longitude);
//       DateTime now = DateTime.now();
//       String timestamp = now.toIso8601String();

//       if (_previousLocation == null) {
//         _previousLocation = current;
//         _stationaryStartTime = now;
//         _lastStationaryLocation = current;
//         return;
//       }

//       final distance = Distance().as(
//         LengthUnit.Meter,
//         _previousLocation!,
//         current,
//       );

//       final placemarks = await placemarkFromCoordinates(
//         current.latitude,
//         current.longitude,
//       );
//       final mark = placemarks.first;
//       final locality = mark.locality ?? mark.subAdministrativeArea ?? 'Unknown';
//       final subLocality = mark.subLocality ?? mark.subAdministrativeArea ?? 'Unknown';

//       await trackBox.add({
//         'lat': current.latitude,
//         'lng': current.longitude,
//         'timestamp': timestamp,
//       });

//       final isStationary = Distance().as(LengthUnit.Meter, _lastStationaryLocation!, current) <= 0.5;

//       if (isStationary) {
//         _stationaryStartTime ??= now;

//         if (!_isStopped && now.difference(_stationaryStartTime!).inSeconds >= 10) {
//           if (_lastStopTime != null) {
//             final stopDuration = now.difference(_lastStopTime!);

//             await movementBox.add({
//               'type': 'stopped',
//               'lat': current.latitude,
//               'lng': current.longitude,
//               'time': DateFormat.Hm().format(now),
//               'locality': locality,
//               'subLocality': subLocality,
//               'duration': '${stopDuration.inMinutes}m ${stopDuration.inSeconds % 60}s',
//               'timestamp': timestamp,
//             });

//             await markerBox.add({
//               'type': 'stop',
//               'lat': current.latitude,
//               'lng': current.longitude,
//               'timestamp': timestamp,
//             });
//           }

//           _lastStopTime = now;
//           _isStopped = true;
//         }
//       } else {
//         _stationaryStartTime = now;
//         _lastStationaryLocation = current;

//         if (_isStopped) {
//           await movementBox.add({
//             'type': 'moving',
//             'lat': current.latitude,
//             'lng': current.longitude,
//             'time': DateFormat.Hm().format(now),
//             'locality': locality,
//             'subLocality': subLocality,
//             'distance': distance.toStringAsFixed(2),
//             'timestamp': timestamp,
//           });

//           await markerBox.add({
//             'type': 'move',
//             'lat': current.latitude,
//             'lng': current.longitude,
//             'timestamp': timestamp,
//           });

//           _isStopped = false;
//         }
//       }

//       _previousLocation = current;

//       if (service is AndroidServiceInstance && await service.isForegroundService()) {
//         await service.setForegroundNotificationInfo(
//           title: "DD HRMS",
//           content: "Location: ${current.latitude}, ${current.longitude}",
//         );
//       }

//       service.invoke('update', {
//         "lat": current.latitude,
//         "lng": current.longitude,
//       });
//     } catch (e) {
//       debugPrint("Error in background tracking with Timer: $e");
//     }
//   });
// }
