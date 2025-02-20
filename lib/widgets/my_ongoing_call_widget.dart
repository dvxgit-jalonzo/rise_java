import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onscreen_num_keyboard/onscreen_num_keyboard.dart';


class MyOngoingCallWidget extends StatefulWidget {
  const MyOngoingCallWidget({super.key});

  @override
  State<MyOngoingCallWidget> createState() => _MyOngoingCallWidgetState();
}

class _MyOngoingCallWidgetState extends State<MyOngoingCallWidget> {

  final port = ReceivePort();
  var speakerModeState = false;
  var speakerPhoneState = true;
  var muteState = false;

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


  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
             DangerAlertBox(
               context: context,
               title: "Warning!",
               messageText: "You are not able to close this while on call.",
            );
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Ongoing Call"),
              automaticallyImplyLeading: true,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(), // Pushes everything to the top
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        var message = "";
                        setState(() {
                          speakerPhoneState = !speakerPhoneState;
                        });
                        FlutterBackgroundService().invoke('speakerPhoneState', {
                          "state" : speakerPhoneState
                        });
                        message = speakerPhoneState ? "Speaker turned on." : "Speaker turned off.";

                        Fluttertoast.showToast(
                            msg: message,
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white
                        );
                      },
                      child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(100)
                            ),
                            child: Icon(
                              speakerPhoneState ? Icons.music_note : Icons.music_off,
                              size: 30,
                              color: Colors.white,
                            ),
                          )
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: (){
                        var message = "";
                        setState(() {
                          muteState = !muteState;
                        });
                        FlutterBackgroundService().invoke('muteState', {
                          "state" : muteState
                        });

                        message = muteState ? "Microphone turned off." : "Microphone turned on.";

                        Fluttertoast.showToast(
                            msg: message,
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white
                        );
                      },
                      child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(100)
                            ),
                            child: Icon(
                              muteState ? Icons.mic : Icons.mic_off,
                              size: 30,
                              color: Colors.white,
                            ),
                          )
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: (){
                        var message = "";
                        setState(() {
                          speakerModeState = !speakerModeState;
                        });
                        FlutterBackgroundService().invoke('speakerModeState', {
                          "state" : speakerModeState
                        });
                        message = speakerModeState ? "Speakerphone mode." : "Earpiece mode.";

                        Fluttertoast.showToast(
                            msg: message,
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white
                        );
                      },
                      child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(100)
                            ),
                            child: Icon(
                              speakerModeState ? Icons.volume_up : Icons.volume_down,
                              size: 30,
                              color: Colors.white,
                            ),
                          )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: (){
                    FlutterBackgroundService().invoke('hangup');
                  },
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(100)
                        ),
                        child: const Icon(
                          Icons.call_end,
                          size: 40,
                          color: Colors.white,
                        ),
                      )
                  ),
                ),
                NumericKeyboard(
                  onKeyboardTap: onKeyboardTap,
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                  ),
                  rightButtonFn: () {
                    onKeyboardTap("#");
                  },
                  rightButtonLongPressFn: () {
                    if (text.isEmpty) return;
                    setState(() {
                      text = '';
                    });
                  },
                  rightIcon: const Text(
                    "#",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                    ),
                  ),
                  leftButtonFn: (){
                    onKeyboardTap("*");
                  },
                  leftIcon: const Text(
                    "*",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                    ),
                  ),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                const SizedBox(height: 20)
              ],
            ),
        )
    );
  }
}
