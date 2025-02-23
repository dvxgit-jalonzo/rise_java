import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rise_java/janus/janus_sip_manager.dart';
import 'package:rise_java/my_local_storage.dart';

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var username = _extensionController.text;
                    var password = _passwordController.text;
                    debugPrint("saving SIP credentials!");
                    debugPrint("username $username!");
                    debugPrint("password $password!");
                    FlutterBackgroundService().invoke("setUsernameAndPassword", {
                      "mailbox_number" : username,
                      "password" : password
                    });
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
                  onPressed: () async {
                    try {
                      await JanusSipManager().testTobeDelete();
                      debugPrint('Call button pressed for mailbox');
                    } catch (e) {
                      debugPrint('Error calling: $e');
                    }
                  },
                  child: const Text("Make Call"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await MyLocalStorage().clear();
                    debugPrint("storage cleared");
                  },
                  child: const Text("clear storage"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final mailboxNumber = await MyLocalStorage().get("string", "mailbox_number");
                    final password = await MyLocalStorage().get("string", "sip_password");
                    debugPrint(mailboxNumber);
                    debugPrint(password);
                  },
                  child: const Text("Playground"),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
