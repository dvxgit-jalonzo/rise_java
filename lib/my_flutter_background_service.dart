import 'dart:async';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:rise_java/awesome_notification_modes/awesome_notification_channel.dart';
import 'package:rise_java/awesome_notification_modes/awesome_notification_handler.dart';
import 'package:rise_java/janus/janus_sip_manager.dart';
import 'package:rise_java/my_http_overrides.dart';
import 'package:rise_java/my_local_storage.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {

    await service.setAsForegroundService();
    if (await service.isForegroundService()) {
      await service.setForegroundNotificationInfo(
          title: "RISE",
          content: "Background service is running..."
      );
      debugPrint("Background service is running...");
    }
    HttpOverrides.global = MyHttpOverrides();

    List<NotificationChannel> channels = [AwesomeNotificationChannel.instance.sipChannelInstance];

    await AwesomeNotifications().initialize(null, channels, debug: true);
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: AwesomeNotificationHandler.onActionReceivedMethod,
      onNotificationCreatedMethod: AwesomeNotificationHandler.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: AwesomeNotificationHandler.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: AwesomeNotificationHandler.onDismissActionReceivedMethod,
    );

    Timer.periodic(const Duration(seconds: 3), (timer) async {
      var mailboxNumber = await MyLocalStorage().get("string", "mailbox_number");
      var sipPassword = await MyLocalStorage().get("string", "sip_password");
      if (mailboxNumber != null && mailboxNumber.isNotEmpty && sipPassword != null && sipPassword.isNotEmpty) {
        await JanusSipManager().initializeSip();
        var sendRegistration = JanusSipManager().sendRegistration;
        await JanusSipManager().autoRegister(sendRegister: sendRegistration);
      }else{
        debugPrint("mailbox number is ${mailboxNumber ?? 'Empty'}");
        debugPrint("sip password is ${sipPassword ?? 'Empty'}");
      }

    });



    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('register').listen((event) async {
      await JanusSipManager().autoRegister(sendRegister: true);
    });

    service.on('callAccept').listen((event) async {
      debugPrint("Accepted call");
      await JanusSipManager().accept();
    });

    service.on('dtmf').listen((event) async {
      Map<String, dynamic> dtmf = {"tones": "${event?['key']}"};
      debugPrint("$dtmf DTMF trigger");
      await JanusSipManager().sendDtmf(dtmf);
    });

    service.on('speakerPhoneState').listen((event) async {
      var speakerState = event?['state'];
      await JanusSipManager().speakerPhoneState(speakerState);
    });

    service.on('speakerModeState').listen((event) async {
      var state = event?['state'];
      await JanusSipManager().speakerModeState(state);
    });


    service.on('muteState').listen((event) async {
      var state = event?['state'];
      await JanusSipManager().muteState(state);
    });

    service.on('call').listen((event) async {
      debugPrint("make call triggered");
      final mailboxNumber = event?['mailbox_number'];
      await JanusSipManager().call(mailboxNumber);
      debugPrint("make call executed.");
    });

    service.on('decline').listen((event) async {
      debugPrint("[background] decline");
      await JanusSipManager().decline();
    });

    service.on('setUsernameAndPassword').listen((event) async {
      var username = event?['mailbox_number'];
      var password = event?['password'];
      await MyLocalStorage().save("string", "mailbox_number", username);
      await MyLocalStorage().save("string", "sip_password", password);
      debugPrint("[background] SIP credentials saved!");
    });

    service.on('hangup').listen((event) async {
      debugPrint("[background] sending hangup");
      await JanusSipManager().hangup();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}
