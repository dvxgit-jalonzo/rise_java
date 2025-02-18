import 'dart:isolate';
import 'dart:ui';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';


class MyIncomingCallWidget extends StatefulWidget {
  final String caller;
  const MyIncomingCallWidget({super.key, required this.caller});

  @override
  State<MyIncomingCallWidget> createState() => _MyIncomingCallWidgetState();
}

class _MyIncomingCallWidgetState extends State<MyIncomingCallWidget> {

  final port = ReceivePort();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String text = "";

  onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
    FlutterBackgroundService().invoke('dtmf', {
      "key" : value
    });
  }



  Future<void> _onWillPop(BuildContext context) async {
    bool? shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit"),
        content: const Text("Do you really want to go back?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(), // Exit
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldPop ?? false) {
      Navigator.of(context).pop(); // Close the screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _onWillPop(context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Incoming Call from ${widget.caller}"),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(), // Pushes everything to the top
              Center( // Centers the entire row horizontally and vertically
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distributes space evenly
                  children: [
                    GestureDetector(
                      onTap: () {
                        FlutterBackgroundService().invoke('callAccept');
                      },
                      child: Container( // No need for Align, Container centers Icon by default
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          Icons.call,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // End Call Button
                    GestureDetector(
                      onTap: () {
                        FlutterBackgroundService().invoke('decline');
                      },
                      child: Container( // No need for Align, Container centers Icon by default
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          Icons.call_end,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60)
            ],
          ),
        )
    );
  }
}
