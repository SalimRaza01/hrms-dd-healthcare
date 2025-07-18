import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';

void showBackgroundPermissionDialog(BuildContext context) {
  final String imageAsset = Platform.isAndroid
      ? 'assets/image/android.png'
      : 'assets/image/ios.png';

  final String title = Platform.isAndroid
      ? 'Enable Background Activity'
      : 'Enable Background App Refresh';

  final String description = Platform.isAndroid
      ? 'To track your location in the background, please allow the app to run without battery restrictions.'
      : 'To track your location while the app is in background, enable Background App Refresh in settings.';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, textAlign: TextAlign.center, ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imageAsset, height: 250),
          const SizedBox(height: 20),
          Text(description, textAlign: TextAlign.center),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
    final settings = OpenSettingsPlus.shared;

    if (settings is OpenSettingsPlusAndroid) {
      await settings.applicationDetails();
    } else if (settings is OpenSettingsPlusIOS) {
      await settings.appSettings();
    } else {
      throw Exception('Platform not supported');
    }
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}
