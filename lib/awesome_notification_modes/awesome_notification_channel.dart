import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class AwesomeNotificationChannel{

  AwesomeNotificationChannel._();
  static final AwesomeNotificationChannel _instance = AwesomeNotificationChannel._();
  static AwesomeNotificationChannel get instance => _instance;

  final NotificationChannel _sipChannel = NotificationChannel(
    channelKey: 'sip_channel',
    channelName: 'SIP Calls',
    channelDescription: 'Notifications for incoming VoIP calls',
    defaultColor: Colors.purple,
    ledColor: Colors.purple,
    playSound: true,
    enableVibration: true,
    defaultRingtoneType: DefaultRingtoneType.Ringtone,
    importance: NotificationImportance.Max,
    criticalAlerts: true,
  );

  NotificationChannel get sipChannelInstance => _sipChannel;
}