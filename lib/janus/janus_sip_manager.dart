
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rise_java/my_local_storage.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'janus_client.dart';


class JanusSipManager {
  JanusSession? _session; // Add a private field to store the session instance
  JanusSipPlugin? _sip;
  RTCSessionDescription? rtc;
  MediaStream? mediaStream;

  // Private constructor to prevent direct instantiation
  JanusSipManager._();

  static final JanusSipManager _instance = JanusSipManager._();

  static JanusSipManager get instance => _instance;

  Future<void> initializeSip() async {
    var gateway = await MyLocalStorage().get("string", "gateway");
    if (_sip == null) {
      debugPrint("initializing sip");
      final ws = WebSocketJanusTransport(url: gateway);
      final j = JanusClient(transport: ws, iceServers: null, isUnifiedPlan: true);
      _session = await j.createSession(); // Store the session instance
      _sip = await _session!.attach<JanusSipPlugin>();

      _sip?.typedMessages?.listen((result) async {
        // debugPrint(result.event.plugindata?.data.toJson());
        Object data = result.event.plugindata?.data;
        if(data is SipIncomingCallEvent){
          var incomingCallData = data.toJson();
          //sip:6005@192.168.33.53
          debugPrint("incoming call event receive");
          IsolateNameServer.lookupPortByName("event_port")?.send({
            "event" : "incoming_call",
            "caller" : incomingCallData['result']['username'].split(":")[1].split('@')[0]
          });
          await _sip?.initializeWebRTCStack();
          rtc = result.jsep;
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
          IsolateNameServer.lookupPortByName("event_port")?.send({
            "event" : "accepted",
          });

        }
        if(data is SipUnRegisteredEvent){
          debugPrint("unregister event receive");
        }
        if(data is SipHangupEvent){
          debugPrint("hangup event receive");
          IsolateNameServer.lookupPortByName("event_port")?.send({
            "event" : "hangup"
          });
          await _sip?.webRTCHandle?.peerConnection?.close();
          await stopAllTracksAndDispose(mediaStream);
        }
        if(data is SipRegisteredEvent){
          debugPrint("registered event received");
        }
        if(data is SipCallingEvent){
          debugPrint("calling event receive");
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

         }
        }
      });

    }
  }

  Future<void> accept() async{
    await _sip?.initializeMediaDevices(mediaConstraints: {'audio': true, 'video': false});
    await _sip?.handleRemoteJsep(rtc);
    var answer = await _sip?.createAnswer();
    await _sip?.accept(sessionDescription: answer);
  }



  Future<void> autoRegister() async{
    final androidHost = await MyLocalStorage().get("string", "android_host");

    debugPrint("Sending auto registration");
    debugPrint("android host $androidHost");
    await _sip?.register("sip:6002@$androidHost",
        forceUdp: true,
        sendRegister: true,
        rfc2543Cancel: true,
        proxy: "sip:$androidHost",
        secret:"2241");
    debugPrint("Sending done");
  }




  JanusSipPlugin? get sipInstance => _sip;
  JanusSession? get sessionInstance => _session;
}
