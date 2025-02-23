import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rise_java/my_local_storage.dart';
import 'package:http/http.dart' as http;

class MyControllers{

  Future<void> storageLoad() async {
   try{
     final accessTokenResult = await generateAccessToken();
     if(accessTokenResult == 200) {
       debugPrint("access token successfully generated.");
     }else{
       debugPrint("something error on generating access token.");
     }
     final androidHostResult = await fetchAndroidHost();
     if(androidHostResult == 200) {
       debugPrint("android host successfully fetch.");
     }else{
       debugPrint("something error on fetching android host.");
     }

     final reverbKeyResult = await fetchReverbAppKey();
     if(reverbKeyResult == 200) {
       debugPrint("reverb key successfully fetch.");
     }else{
       debugPrint("something error on fetching reverb key.");
     }
   }catch(e){
     debugPrint("error on storage load : $e");
   }
  }


  Future<dynamic> generateAccessToken() async{

    final appId = await MyLocalStorage().get("string", "app_id");
    final appKey = await MyLocalStorage().get("string","app_key");
    final base = await MyLocalStorage().get("string","base");
    final tokenUrl = '$base/oauth/token';
    final Map<String, String> body = {
      "grant_type": "client_credentials",
      "client_id": appId,
      "client_secret": appKey,
      "scope": ""
    };

    final response = await http.post(
      Uri.parse(tokenUrl),
      body: body,
    );

    if(response.statusCode == 200){
      Map<String, dynamic> data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      MyLocalStorage().save('string', 'access_token', accessToken);
    }

    return response.statusCode;
  }

  Future<Map<String, String>> getHeaders() async{
    final accessToken = await MyLocalStorage().get('string', 'access_token');
    final dynamic headers =  {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    return headers;
  }


  Future<dynamic> fetchReverbAppKey() async {
    final base = await MyLocalStorage().get('string', 'base');
    final route = "$base/api/mobile/reverb_app_key";
    final response = await http.get(Uri.parse(route), headers: await getHeaders());
    if(response.statusCode == 200){
      final androidHost = response.body;
      await MyLocalStorage().save("string", "reverb_key", androidHost);
    }
    return response.statusCode;
  }

  Future<dynamic> fetchAndroidHost() async {
      final base = await MyLocalStorage().get('string', 'base');
      final route = "$base/api/mobile/android_host";
      final response = await http.get(Uri.parse(route), headers: await getHeaders());
      if(response.statusCode == 200){
        final androidHost = response.body;
        await MyLocalStorage().save("string", "android_host", androidHost);
      }
      return response.statusCode;
    }
  }


