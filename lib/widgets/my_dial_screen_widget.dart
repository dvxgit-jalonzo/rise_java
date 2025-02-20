
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:onscreen_num_keyboard/onscreen_num_keyboard.dart';
import 'package:rise_java/widgets/my_call_history_widget.dart';
import 'package:rise_java/widgets/my_message_widget.dart';
import 'package:rise_java/widgets/my_port.dart';
import 'package:rise_java/widgets/my_registration_widget.dart';

class MyDialPadWidget extends StatefulWidget {
  const MyDialPadWidget({super.key});

  @override
  State<MyDialPadWidget> createState() => _MyDialPadWidgetState();
}

class _MyDialPadWidgetState extends State<MyDialPadWidget> {

  ReceivePort? port;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    MyPort.instance.initializePort(context);
    port = MyPort.instance.portInstance;
  }


  @override
  void dispose() {
    debugPrint("close everything on dial screen.");
    IsolateNameServer.removePortNameMapping('event_port');
    port?.close();
    super.dispose();
  }

  String text = "";

  onKeyboardTap(String value) {
    setState(() {
      text = text + value;
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
            title: const Text("Dial Pad"),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                text,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              NumericKeyboard(
                onKeyboardTap: onKeyboardTap,
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                ),
                rightButtonFn: () {
                  if (text.isEmpty) return;
                  setState(() {
                    text = text.substring(0, text.length - 1);
                  });
                },
                rightButtonLongPressFn: () {
                  if (text.isEmpty) return;
                  setState(() {
                    text = '';
                  });
                },
                rightIcon: const Icon(
                  Icons.backspace_outlined,
                  color: Colors.blueGrey,
                ),
                leftButtonFn: (){
                  FlutterBackgroundService().invoke('call', {
                    "mailbox_number" : text
                  });
                  setState(() {
                    text = '';
                  });
                },
                leftIcon: Container(
                  padding: const EdgeInsets.all(10), // You can adjust the padding as needed
                  decoration: BoxDecoration(
                    color: Colors.green, // Set the background color here
                    borderRadius: BorderRadius.circular(100), // Optional: Add rounded corners
                  ),
                  child: const Icon(
                    Icons.call,
                    color: Colors.white, // Set the icon color
                  ),
                ),

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              const SizedBox(height: 20)
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0, // Highlight the active tab
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dialpad),
              label: 'Dial Pad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Call History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.app_registration),
              label: 'Registration',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                debugPrint("Nothing to worry!");
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyCallHistoryWidget()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyMessageWidget()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyRegistrationWidget()),
                );
                break;
              default:
                return; // Do nothing if an invalid index is passed
            }
          },
        )
        )
    );
  }
}
