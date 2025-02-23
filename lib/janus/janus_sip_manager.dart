
import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:rise_java/my_local_storage.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'janus_client.dart';


class JanusSipManager {
  JanusSession? _session; // Add a private field to store the session instance
  JanusSipPlugin? _sip;
  RTCSessionDescription? rtc;
  MediaStream? mediaStream;
  var _sendRegistration = true;

  // Private constructor to prevent direct instantiation
  JanusSipManager._internal();
  static final JanusSipManager _instance = JanusSipManager._internal();
  factory JanusSipManager() {
    return _instance;
  }


  @pragma('vm:entry-point')
  Future<void> createCallNotification(caller) async {
    await AwesomeNotifications().cancel(10);
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'sip_channel',
            title: 'Incoming Call',
            body: 'From: $caller',
            fullScreenIntent: true,
            wakeUpScreen: true,
            payload: {
              "caller" : caller
            } ,
            locked: true,
            category: NotificationCategory.Call,
            displayOnBackground: true,
            displayOnForeground: true,
            backgroundColor: Colors.green,
            autoDismissible: false,
            notificationLayout: NotificationLayout.Default
        ),
        actionButtons: [
          NotificationActionButton(key: 'ACCEPT', label: 'Accept', actionType: ActionType.Default, color: Colors.green, autoDismissible: true),
          NotificationActionButton(key: 'DECLINE', label: 'Decline', actionType: ActionType.DismissAction, color: Colors.red, autoDismissible: true),
        ]
    );
  }

  @pragma('vm:entry-point')
  Future<void> initializeSip() async {
    try {
      var gateway = await MyLocalStorage().get("string", "gateway");
      if (_sip == null) {
        debugPrint("initializing sip");
        debugPrint("gateway : $gateway");
        var servers = [
          RTCIceServer(
              urls: "stun:stun.l.google.com",
              username: "",
              credential: ""// Free public STUN server
          ),
          RTCIceServer(
              urls: "stun:stun2.l.google.com",
              username: "",
              credential: ""// Free public STUN server
          ),
          RTCIceServer(
              urls: "stun:stun3.l.google.com",
              username: "",
              credential: ""// Free public STUN server
          ),
        ];

        final ws = WebSocketJanusTransport(url: gateway);
        final j = JanusClient(transport: ws, iceServers: null, isUnifiedPlan: false);
        _session = await j.createSession(); // Store the session instance
        _sip = await _session!.attach<JanusSipPlugin>();

        _sip?.typedMessages?.listen((result) async {
          Object data = result.event.plugindata?.data;
          if(data is SipIncomingCallEvent){
            await _sip?.initializeWebRTCStack();
            rtc = result.jsep;
            var incomingCallData = data.toJson();
            var caller = incomingCallData['result']['username'].split(":")[1].split('@')[0];
            //sip:6005@192.168.33.53
            debugPrint("incoming call event receive");
            final SendPort? sendPort = IsolateNameServer.lookupPortByName('event_port');
            sendPort?.send({
              "event" : "incoming_call",
              "caller" : caller
            });

            await createCallNotification(caller);

          }
          if(data is SipAcceptedEvent){
            RTCSessionDescription? remoteOffer = result.jsep;
            await _sip?.handleRemoteJsep(remoteOffer);
            var receivers = await _sip?.webRTCHandle?.peerConnection?.receivers;
            receivers?.forEach((element) {
              if (element.track?.kind == 'audio') {
                element.track?.enableSpeakerphone(false);
              }
            });


            debugPrint("accepted event receive");


            final SendPort? sendPort = IsolateNameServer.lookupPortByName('event_port');
            sendPort?.send({
              "event" : "accepted",
            });
          }
          if(data is SipUnRegisteredEvent){
            debugPrint("unregister event receive");
          }
          if(data is SipHangupEvent){
            debugPrint("hangup event receive");
            final SendPort? sendPort = IsolateNameServer.lookupPortByName('event_port');
            sendPort?.send({
              "event" : "hangup"
            });

            AwesomeNotifications().cancel(10);
            await _sip?.webRTCHandle?.peerConnection?.close();
            await stopAllTracksAndDispose(mediaStream);

          }
          if(data is SipRegisteredEvent){
            debugPrint("registered event received");
          }
          if(data is SipCallingEvent){
            final SendPort? sendPort = IsolateNameServer.lookupPortByName('event_port');
            sendPort?.send({
              "event" : "${data.toJson()['result']['event']}",
            });
            debugPrint("[manager] ${data.toJson()['result']['event']} event");
          }
          if(data is SipMissedCallEvent){
            debugPrint("missed call event receive");
          }
          if(data is SipProceedingEvent){
            await _sip?.handleRemoteJsep(result.jsep);
            debugPrint("proceeding event receive");
          }
          if(data is SipProgressEvent){
            await _sip?.handleRemoteJsep(result.jsep);
            debugPrint("progress event receive");
          }
          if(data is SipRingingEvent){
            await _sip?.handleRemoteJsep(result.jsep);
            debugPrint("ringing event receive");
          }
          if(data is SipAcceptedEventResult){
            await _sip?.handleRemoteJsep(result.jsep);
            debugPrint("accepted event result receive");
          }
        }, onError:(error) async {
          if(error is JanusError) {
            // if(error.error.contains("Invalid user address")){
            //   final mailboxNumber = await MyLocalStorage().get('string', 'mailboxNumber');
            //   final androidHost = await MyLocalStorage().get('string', 'androidHost');
            //   if(mailboxNumber == null){
            //     FlutterBackgroundService().invoke('error', {
            //       'message' : 'mailbox number not exists.'
            //     });
            //   }
            //   if(androidHost == null){
            //     FlutterBackgroundService().invoke('error', {
            //       'message' : 'android host number not exists.'
            //     });
            //   }
            //    await _sip?.register("sip:$mailboxNumber@192.168.228.142",
            //      forceUdp: true,
            //      rfc2543Cancel: true,
            //      proxy: "sip:192.168.228.142",
            //      secret:"2241"
            //    );
            // }

            if(error.error.contains("Already registered")){
              _sendRegistration = false;
            }
          }
        });

      }else{
        debugPrint("SIP Okay!");
      }
    } catch (e){
      debugPrint("[on-start-error] $e");
    }
  }

  @pragma('vm:entry-point')
  Future<void> accept() async{
    await _sip?.initializeMediaDevices(mediaConstraints: {'audio': true, 'video': false});
    await _sip?.handleRemoteJsep(rtc);
    var answer = await _sip?.createAnswer();
    await _sip?.accept(sessionDescription: answer);
  }

  @pragma('vm:entry-point')
  Future<void> sendDtmf(dtmf) async{
    await _sip?.sendDtmf(dtmf);
  }

  @pragma('vm:entry-point')
  Future<void> decline() async{
    debugPrint("[manager] declined");
    await _sip?.decline();
  }

  @pragma('vm:entry-point')
  Future<void> testTobeDelete() async {
    debugPrint("test triggered");
    debugPrint("print $_sip");
    debugPrint("print $_session");
    final androidHost = await MyLocalStorage().get("string", "android_host");
    await _sip?.initializeWebRTCStack();
    await _sip?.initializeMediaDevices(mediaConstraints: {'audio': true, 'video': false});
    var offer = await _sip?.createOffer(videoRecv: false, audioRecv: true);
    await _sip?.call("sip:820@$androidHost", offer: offer, autoAcceptReInvites: false);
    debugPrint("test triggered done");
  }

  @pragma('vm:entry-point')
  Future<void> call(mailboxNumber) async{
    final androidHost = await MyLocalStorage().get("string", "android_host");
    await _sip?.initializeWebRTCStack();
    await _sip?.initializeMediaDevices(mediaConstraints: {'audio': true, 'video': false});
    var offer = await _sip?.createOffer(videoRecv: false, audioRecv: true);
    await _sip?.call("sip:$mailboxNumber@$androidHost", offer: offer, autoAcceptReInvites: false);
  }
  
  @pragma('vm:entry-point')
  Future<void> hangup() async{
    debugPrint("[manager] hangup");
    await _sip?.hangup();
  }

  @pragma('vm:entry-point')
  Future<void> speakerPhoneState(state) async{
    var receivers = await _sip?.webRTCHandle?.peerConnection?.receivers;
    receivers?.forEach((element) {
      if (element.track?.kind == 'audio') {
        element.track?.enabled = state;
      }
    });
  }

 @pragma('vm:entry-point')
  Future<void> speakerModeState(state) async{
   var receivers = await _sip?.webRTCHandle?.peerConnection?.receivers;
   receivers?.forEach((element) {
     if (element.track?.kind == 'audio') {
       element.track?.enableSpeakerphone(state);
     }
   });
  }

 @pragma('vm:entry-point')
  Future<void> muteState(state) async{
   var senders = await _sip?.webRTCHandle?.peerConnection?.senders;
   senders?.forEach((element) {
     if (element.track?.kind == 'audio') {
       element.track?.enabled = state;
     }
   });
  }



  @pragma('vm:entry-point')
  Future<void> autoRegister({required bool sendRegister}) async{
    final androidHost = await MyLocalStorage().get("string", "android_host");
    final mailboxNumber = await MyLocalStorage().get("string", "mailbox_number");
    final sipPassword = await MyLocalStorage().get("string", "sip_password");
    await _sip?.register("sip:$mailboxNumber@$androidHost",
        forceUdp: true,
        sendRegister: sendRegister,
        rfc2543Cancel: true,
        proxy: "sip:$androidHost",
        secret:"$sipPassword");
    if(sendRegister){
      debugPrint("Requesting registration");
    }else{
      debugPrint("Registration Okay!");
    }
  }

  bool get sendRegistration => _sendRegistration;
}
