import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rise_java/janus/janus_sip_manager.dart';
import 'package:rise_java/my_http_overrides.dart';
import 'package:rise_java/my_local_storage.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

SendPort? sendPortToMainFrame;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
  );

  service.startService();
}


@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {

  if (service is AndroidServiceInstance) {
    HttpOverrides.global = MyHttpOverrides();
    await JanusSipManager.instance.initializeSip();
    final sip = JanusSipManager.instance.sipInstance;

    await JanusSipManager.instance.autoRegister();

    // Timer.periodic(const Duration(seconds: 3), (timer) async {
    //   await JanusSipManager.instance.initializeSip();
    //   await sip?.checkRegistration("6002", sendRegister: false );
    // });

    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('register').listen((event) async {
      final androidHost = await MyLocalStorage().get("string", "android_host");

      debugPrint("Sending registration");
      debugPrint("android host $androidHost");
      await sip?.register("sip:6002@$androidHost",
          forceUdp: true,
          sendRegister: true,
          rfc2543Cancel: true,
          proxy: "sip:$androidHost",
          secret:"2241");
      debugPrint("Sending done");
    });

    service.on('callAccept').listen((event) async {
      debugPrint("Accepted call");
        await JanusSipManager.instance.accept();
    });

    service.on('dtmf').listen((event) async {
      Map<String, dynamic> dtmf = {"tones": "${event?['key']}"};
      debugPrint("$dtmf DTMF trigger");
      await sip?.sendDtmf(dtmf);
    });

    service.on('speakerPhoneState').listen((event) async {
      var speakerState = event?['state'];
      var receivers = await sip?.webRTCHandle?.peerConnection?.receivers;
      receivers?.forEach((element) {
        if (element.track?.kind == 'audio') {
          element.track?.enabled = speakerState;
        }
      });
    });

    service.on('speakerModeState').listen((event) async {
      var state = event?['state'];
      var receivers = await sip?.webRTCHandle?.peerConnection?.receivers;
      receivers?.forEach((element) {
        if (element.track?.kind == 'audio') {
          element.track?.enableSpeakerphone(state);
        }
      });
    });


    service.on('muteState').listen((event) async {
      var state = event?['state'];
      var senders = await sip?.webRTCHandle?.peerConnection?.senders;
      senders?.forEach((element) {
        if (element.track?.kind == 'audio') {
          element.track?.enabled = state;
        }
      });
    });

    service.on('call').listen((event) async {
      debugPrint("make call triggered");
      final mailboxNUmber = event?['mailbox_number'];
      final androidHost = await MyLocalStorage().get("string", "android_host");
      await sip?.initializeWebRTCStack();
      await sip?.initializeMediaDevices(mediaConstraints: {'audio': true, 'video': false});
      var offer = await sip?.createOffer(videoRecv: false, audioRecv: true);
      await sip?.call("sip:$mailboxNUmber@$androidHost", offer: offer, autoAcceptReInvites: false);
      debugPrint("make call executed.");
    });

    service.on('decline').listen((event) async {
      debugPrint("sending decline");
      await sip?.decline();
    });

    service.on('hangup').listen((event) async {
      debugPrint("sending hangup");
      await sip?.webRTCHandle?.peerConnection?.close();
      await sip?.hangup();
    });
  }


  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      await service.setForegroundNotificationInfo(
          title: "RISE",
          content: "Background service is running..."
      );
      debugPrint("Background service is running...");
    }
  }
}

void setSendPortFromForeground(SendPort? port) {
  sendPortToMainFrame = port; // Store the received SendPort
}