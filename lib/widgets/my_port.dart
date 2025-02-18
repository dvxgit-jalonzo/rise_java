import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rise_java/widgets/my_incoming_call_widget.dart';
import 'package:rise_java/widgets/my_ongoing_call_widget.dart';

class MyPort{
  MyPort._();

  static final MyPort _instance = MyPort._();

  static MyPort get instance => _instance;

  var port = ReceivePort();

  void watchPortEvents(ReceivePort port, BuildContext context) {
    port.listen((message) {
      debugPrint("Received message: $message");

      if (message['event'] == "incoming_call") {
        final caller = message['caller'];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyIncomingCallWidget(caller: caller)),
        ).then((_) => restartListener(context));
      }

      if (message['event'] == "accepted") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyOngoingCallWidget()),
        ).then((_) => restartListener(context));
      }

      if (message['event'] == "hangup") {
        Navigator.pop(context);
      }
    });
  }

  void restartListener(context) {
    debugPrint("Restarting port listener...");

    // Close the existing port
    port.close();
    IsolateNameServer.removePortNameMapping('event_port');

    // Reinitialize the port
    initializePort(context);
  }

  void initializePort(context) {
    debugPrint("Initializing port listener...");

    // Ensure no duplicate registration
    IsolateNameServer.removePortNameMapping('event_port');

    port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, 'event_port');

    watchPortEvents(port, context);
  }


  ReceivePort get portInstance => port;
}