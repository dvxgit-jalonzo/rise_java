import 'dart:convert';

import 'package:flutter_encrypt_plus/flutter_encrypt_plus.dart';
import 'package:rise_java/my_local_storage.dart';

class MyGeneralConfigurations{
  static const String saltKey = 'diavox-risemobileapp-passwordkey';
  String get getSaltKey => saltKey;

  bool verifyQr(String qr){
    try{
      dynamic decodedResponse = encrypt.decodeString(qr, getSaltKey);
      Map<String, dynamic> data = jsonDecode(decodedResponse);

      String appId = data['app_id'];
      if(appId.isNotEmpty){
        return true;
      }else{
        return false;
      }
    }catch(e){
      print("Error : $e");
      return false;
    }
  }

  Future<bool> isAlreadyHaveQrCode() async {
    var app_id = await MyLocalStorage().get("string", "app_id");
    if(app_id != null){
      return true;
    }
    return false;
  }

  Future<void> saveVerifiedQr(qr) async {
    dynamic decodedResponse = encrypt.decodeString(qr, getSaltKey);
    Map<String, dynamic> data = jsonDecode(decodedResponse);
    List<dynamic> key = ['app_id', 'app_key', 'base', 'gateway'];
    for (var item in key) {
      if (data.containsKey(item)) {
        dynamic value = data[item];

        String dataType;
        if (value is String) {
          dataType = 'string';
        } else if (value is int) {
          dataType = 'int';
        } else if (value is bool) {
          dataType = 'bool';
        } else if (value is double) {
          dataType = 'double';
        } else if (value is List<String>) {
          dataType = 'list';
        } else {
          throw Exception("Unsupported data type for key: $item");
        }

        // Now we pass the correct type
        await MyLocalStorage().save(dataType, item, value);
      }
    }
  }
}