import 'package:shared_preferences/shared_preferences.dart';

class MyLocalStorage {



/*
    <string name="flutter.gateway">
    <string name="flutter.base">
    <string name="flutter.app_key">
    <string name="flutter.app_id">
*/

  Future<void> save(String dataType, String name, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (dataType) {
      case 'string':
        await prefs.setString(name, value as String);
        break;
      case 'int':
        await prefs.setInt(name, value as int);
        break;
      case 'bool':
        await prefs.setBool(name, value as bool);
        break;
      case 'double':
        await prefs.setDouble(name, value as double);
        break;
      case 'list':
        await prefs.setStringList(name, value as List<String>);
        break;
      default:
        throw Exception("Unsupported data type");
    }
  }

  Future<dynamic> get(String dataType, String name) async {
    final prefs = await SharedPreferences.getInstance();

    switch (dataType) {
      case 'string':
        return prefs.getString(name);
      case 'int':
        return prefs.getInt(name);
      case 'bool':
        return prefs.getBool(name);
      case 'double':
        return prefs.getDouble(name);
      case 'list':
        return prefs.getStringList(name);
      default:
        return null;
    }
  }

  Future<void> remove(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(name);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Removes all keys and values
    print("All shared preferences cleared!");
  }
}
