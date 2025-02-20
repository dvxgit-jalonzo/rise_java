import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rise_java/janus/janus_sip_manager.dart';

class AwesomeNotificationHandler {
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    try{
      AwesomeNotifications().cancel(10);
    }catch(e){
      debugPrint(e as String);
    }
    if(receivedAction.buttonKeyPressed == 'ACCEPT'){
      debugPrint("[awesome] accept");
      FlutterBackgroundService().invoke('callAccept');
    }
  }

  // Optionally handle notification created event
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification created
    debugPrint("Handle notification created");
  }

  // Optionally handle notification displayed event
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification displayed
    debugPrint("Handle notification displayed");
  }

  // Optionally handle notification dismissed event
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    if(receivedAction.buttonKeyPressed == 'DECLINE'){
      debugPrint("[awesome] declined");
      FlutterBackgroundService().invoke('decline');
    }
  }
}
