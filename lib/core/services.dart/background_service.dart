import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // ✅ Only show a notification; do NOT initialize here
  await plugin.show(
    0,
    'DD HRMS',
    'Tracking Started',
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
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Tracking Location',
      initialNotificationContent: 'Running in background',
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
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

  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: "DD HRMS",
      content: "Tracking location in background",
    );

    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (service is AndroidServiceInstance &&
          await service.isForegroundService()) {
        await service.setForegroundNotificationInfo(
          title: 'DD HRMS',
          content: 'Location: ${position.latitude}, ${position.longitude}',
        );
      }

      service.invoke('update', {
        "lat": position.latitude,
        "lng": position.longitude,
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  });
}
