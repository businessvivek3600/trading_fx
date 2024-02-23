import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SpUtil {
  SharedPreferences sharedPreferences;
  SpUtil({required this.sharedPreferences});

  //bool
  Future<void> setBool(String key, bool value) async =>
      await sharedPreferences.setBool(key, value);
  bool getBool(String key) => sharedPreferences.getBool(key) ?? false;
  //string
  Future<void> setString(String key, String value) async =>
      await sharedPreferences.setString(key, value);
  String? getString(String key) => sharedPreferences.getString(key);

  //int
  Future<void> setInt(String key, int value) async =>
      await sharedPreferences.setInt(key, value);
  int? getInt(String key) => sharedPreferences.getInt(key);

  //remove
  Future<bool> remove(String key) async => await sharedPreferences.remove(key);

  //check for exists or not
  bool exists(String key) => sharedPreferences.containsKey(key);

  /// set+get json data
  Future<Map<String, dynamic>?> getData(String key) async {
    var data = await sharedPreferences.getString(key);
    if (data != null) {
      return jsonDecode(data);
    } else {
      return null;
    }
  }

  /// set+get json data
  Future<Map<String, dynamic>?> setData(
      String key, Map<String, dynamic>? data) async {
    if (data != null) {
      await sharedPreferences.setString(key, jsonEncode(data));
      return data;
    } else if (exists(key) && data == null) {
      return jsonDecode(sharedPreferences.getString(key) ?? '{}');
    } else {
      return data;
    }
  }
}
