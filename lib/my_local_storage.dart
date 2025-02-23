import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
    <string name="flutter.gateway">
    <string name="flutter.base">
    <string name="flutter.app_key">
    <string name="flutter.app_id">
*/

class MyLocalStorage {
  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> save(String dataType, String name, dynamic value) async {
    await init(); // Ensure initialization
    switch (dataType) {
      case 'string':
        await _prefs!.setString(name, value as String);
        break;
      case 'int':
        await _prefs!.setInt(name, value as int);
        break;
      case 'bool':
        await _prefs!.setBool(name, value as bool);
        break;
      case 'double':
        await _prefs!.setDouble(name, value as double);
        break;
      case 'list':
        await _prefs!.setStringList(name, value as List<String>);
        break;
      default:
        throw Exception("Unsupported data type");
    }
  }

  Future<dynamic> get(String dataType, String name) async {
    await init(); // Ensure initialization
    switch (dataType) {
      case 'string':
        return _prefs!.getString(name);
      case 'int':
        return _prefs!.getInt(name);
      case 'bool':
        return _prefs!.getBool(name);
      case 'double':
        return _prefs!.getDouble(name);
      case 'list':
        return _prefs!.getStringList(name);
      default:
        return null;
    }
  }

  Future<void> remove(String name) async {
    await init(); // Ensure initialization
    await _prefs!.remove(name);
  }

  Future<void> clear() async {
    await init(); // Ensure initialization
    await _prefs!.clear(); // Removes all keys and values
    debugPrint("All shared preferences cleared!");
  }
}