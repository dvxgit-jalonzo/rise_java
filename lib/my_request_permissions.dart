

import 'package:permission_handler/permission_handler.dart';

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

