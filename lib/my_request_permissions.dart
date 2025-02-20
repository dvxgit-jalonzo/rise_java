

import 'package:permission_handler/permission_handler.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';


Future<void> requestCameraPermission() async {
  var status = await Permission.camera.status;

  if (status.isDenied) {
    // If permission is denied, request it
    status = await Permission.camera.request();
  }

  if (status.isPermanentlyDenied) {
    // Open app settings if permission is permanently denied
    await openAppSettings();
  }
}

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;

  if (status.isDenied) {
    // If permission is denied, request it
    status = await Permission.notification.request();
  }

  if (status.isPermanentlyDenied) {
    // Open app settings if permission is permanently denied
    await openAppSettings();
  }
}


Future<void> checkAndRequestBatteryOptimization() async {
  bool? isDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;

  if (!isDisabled!) {
    print("Battery optimization is enabled. Asking user to disable...");
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  } else {
    print("Battery optimization is already disabled.");
  }
}


Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.status;

  if (status.isDenied) {
    // If permission is denied, request it
    status = await Permission.microphone.request();
  }

  if (status.isPermanentlyDenied) {
    // Open app settings if permission is permanently denied
    await openAppSettings();
  }
}


Future<void> requestAudioPermission() async {
  var status = await Permission.audio.status;

  if (status.isDenied) {
    // If permission is denied, request it
    status = await Permission.audio.request();
  }

  if (status.isPermanentlyDenied) {
    // Open app settings if permission is permanently denied
    await openAppSettings();
  }
}

