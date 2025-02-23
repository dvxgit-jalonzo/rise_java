
import 'dart:convert';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:rise_java/my_local_storage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyWebsocket{
  MyWebsocket._internal();
  static final MyWebsocket _instance = MyWebsocket._internal();
  factory MyWebsocket(){
    return _instance;
  }

  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> listen() async {
    if(_isConnected) return;

    final androidHost = await MyLocalStorage().get('string', 'android_host');
    final reverbKey = await MyLocalStorage().get('string', 'reverb_key');
    debugPrint("Websocket Connecting...");
    _channel = IOWebSocketChannel.connect(Uri.parse('wss://$androidHost:6002/app/$reverbKey?protocol=7&client=js&version=4.4.0&flash=false'));
    _channel?.sink.add(json.encode({
      "event": "pusher:subscribe",
      "data": {
        "channel": "mobileChannel"
      }
    }));
    _isConnected = true;
    debugPrint("*********************************************************");
    debugPrint("***        Websocket connection established           ***");
    debugPrint("*********************************************************");

    _channel!.stream.listen((data) async {
      final lifecycle = await AwesomeNotifications().getAppLifeCycle();
      final mailboxNumber = await MyLocalStorage().get('string', 'mailbox_number');
      Map<String, dynamic> jsonMap = jsonDecode(data);
      try {
        String dataString = jsonMap['data'];
        if (jsonMap['channel'] == 'mobileChannel') {
          Map<String, dynamic> dataMap = jsonDecode(dataString);
          debugPrint('Origin: ${dataMap['origin']}');
          final extension = dataMap['extension'];
          final alarmType = dataMap['alarm_type'];
          final origin = dataMap['origin'];
          debugPrint("Message Received: $dataMap");

          debugPrint("Mailbox Number: $mailboxNumber");
          if (mailboxNumber == extension) {
            debugPrint("Mailbox Number: $mailboxNumber is equal to $extension");
            if(alarmType == "MW"){
              IsolateNameServer.lookupPortByName('mainIsolate')?.send('MessageWaitingEvent');
            }else if(alarmType == "FA"){
              if (lifecycle == NotificationLifeCycle.Background) {
                await AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: 1,
                    channelKey: 'fire_channel',
                    title: "Fire Notification",
                    body: 'Fire alarm on $origin!',
                    wakeUpScreen: true,
                    fullScreenIntent: true,
                    criticalAlert: true,
                    autoDismissible: false,
                    locked: true,
                    notificationLayout: NotificationLayout.Default,
                    displayOnForeground: true,
                    displayOnBackground: true,
                    category: NotificationCategory.Alarm,
                  ),
                  actionButtons: [
                    NotificationActionButton(key: 'STOP', label: 'Stop', actionType: ActionType.Default),
                  ],
                );
              } else if (lifecycle == NotificationLifeCycle.Foreground) {
                IsolateNameServer.lookupPortByName('mainIsolate')?.send('FireAlarmEvent-$extension');
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Websocket Initialization Error: $e");
      }
    },
      onDone: () {
        // Log when the WebSocket connection is closed
        _isConnected = false;
        debugPrint("WebSocket connection closed.");
      },
      onError: (error) {
        // Log errors
        debugPrint("WebSocket error: $error");
      },
    );
  }

  disconnect(){
    channel!.sink.close();
  }

  Stream get stream => _channel!.stream;
  WebSocketChannel? get channel => _channel;
}