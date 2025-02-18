import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rise_java/janus/janus_sip_manager.dart';

class MyRegistrationWidget extends StatefulWidget {
  const MyRegistrationWidget({super.key});

  @override
  State<MyRegistrationWidget> createState() => _MyRegistrationWidgetState();
}

class _MyRegistrationWidgetState extends State<MyRegistrationWidget> {


  final TextEditingController _extensionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          TextField(
            controller: _extensionController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter extension number",
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _passwordController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Enter extension number",
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  FlutterBackgroundService().invoke('register');
                },
                child: const Text("Register"),
              ),
              ElevatedButton(
                onPressed: () {
                  FlutterBackgroundService().invoke('unregister');
                },
                child: const Text("Unregister"),
              ),
              ElevatedButton(
                onPressed: () {
                  FlutterBackgroundService().invoke('callAccept');
                },
                child: const Text("Unregister"),
              ), 
              ElevatedButton(
                onPressed: () {
                  IsolateNameServer.lookupPortByName("event_port")?.send({
                    "event" : "accepted",
                  });
                },
                child: const Text("Playground"),
              ),
            ],
          )

        ],
      ),
    );
  }
}
