import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:rise_java/janus/janus_sip_manager.dart';

class AwesomeNotificationHandler {

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    try{
      AwesomeNotifications().cancel(10);
    }catch(e){
      debugPrint(e.toString());
    }
    if(receivedAction.buttonKeyPressed == 'ACCEPT'){
      debugPrint("[awesome] accept");
      await JanusSipManager().accept();
    }
  }

  // Optionally [handle] notification created event
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // [Handle] notification created
    debugPrint("[Handle] notification created");
  }

  // Optionally [handle] notification displayed event
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // [Handle] notification displayed
    debugPrint("[Handle] notification displayed");
  }

  // Optionally [handle] notification dismissed event
  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    if(receivedAction.buttonKeyPressed == 'DECLINE'){
      debugPrint("[awesome] declined");
      await JanusSipManager().decline();
    }
  }
}
