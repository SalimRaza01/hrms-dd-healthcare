import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hrms/core/services/background_service.dart';

Future<void> initializeNotifications() async {
  const androidSettings =
      AndroidInitializationSettings('@drawable/ic_notification');
  const iosSettings = DarwinInitializationSettings();

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await plugin.initialize(initSettings);
}