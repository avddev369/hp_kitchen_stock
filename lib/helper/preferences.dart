import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _preferences;
  static String token = "";
  static String email = "";

  static const String _userNameKey = 'userName';
  static const String _tokenKey = 'token';
  static const String _emailKey = 'email';
  static const String _userIdKey = 'userId';
  static const String _isMasterKey = 'isMaster';
  static const String _mobileKey = 'mobile';
  static const String _godownsKey = 'godowns';
  static const String _godownIdsKey = 'godownIds';

  /// **Initialize SharedPreferences (Must Call in `main.dart`)**
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// **Save the Token**
  static Future<void> saveToken(String newToken) async {
    if (_preferences == null) await init();
    await _preferences!.setString(_tokenKey, newToken);
    token = newToken; // Save in memory for quick access
  }

  /// **Get the Token**
  static Future<String?> getToken() async {
    if (_preferences == null) await init();
    return _preferences!.getString(_tokenKey);
  }

  /// **Remove Token (Logout)**
  static Future<void> removeToken() async {
    if (_preferences == null) await init();
    await _preferences!.remove(_tokenKey);
    token = ""; // Clear memory cache
  }

  /// **Save User Name**
  static Future<void> saveUserName(String name) async {
    if (_preferences == null) await init();
    await _preferences!.setString(_userNameKey, name);
  }

  /// **Get User Name**
  static Future<String?> getUserName() async {
    if (_preferences == null) await init();
    return _preferences!.getString(_userNameKey);
  }

  /// **Remove User Name**
  static Future<void> removeUser() async {
    if (_preferences == null) await init();
    await _preferences!.remove(_userNameKey);
  }

  /// **Save Email**
  static Future<void> saveEmail(String newEmail) async {
    if (_preferences == null) await init();
    await _preferences!.setString(_emailKey, newEmail);
    email = newEmail; // Save in memory
  }

  /// **Get Email**
  static Future<String?> getEmail() async {
    if (_preferences == null) await init();
    return _preferences!.getString(_emailKey);
  }

  /// **Remove Email**
  static Future<void> removeEmail() async {
    if (_preferences == null) await init();
    await _preferences!.remove(_emailKey);
    email = ""; // Clear memory cache
  }

  /// **Save User Id**
  static Future<void> saveUserId(int id) async {
    if (_preferences == null) await init();
    await _preferences!.setInt(_userIdKey, id);
  }

  /// **Get User Id**
  static Future<int?> getUserId() async {
    if (_preferences == null) await init();
    return _preferences!.getInt(_userIdKey);
  }

  /// **Save Is Master flag**
  static Future<void> saveIsMaster(bool isMaster) async {
    if (_preferences == null) await init();
    await _preferences!.setBool(_isMasterKey, isMaster);
  }

  /// **Get Is Master flag**
  static Future<bool> getIsMaster() async {
    if (_preferences == null) await init();
    return _preferences!.getBool(_isMasterKey) ?? false;
  }

  /// **Save Mobile**
  static Future<void> saveMobile(String mobile) async {
    if (_preferences == null) await init();
    await _preferences!.setString(_mobileKey, mobile);
  }

  /// **Get Mobile**
  static Future<String?> getMobile() async {
    if (_preferences == null) await init();
    return _preferences!.getString(_mobileKey);
  }

  /// **Save Godowns (list of {id, godown_name})**
  static Future<void> saveGodowns(List<Map<String, dynamic>> godowns) async {
    if (_preferences == null) await init();
    await _preferences!.setString(_godownsKey, jsonEncode(godowns));
  }

  /// **Get Godowns (list of {id, godown_name})**
  static Future<List<Map<String, dynamic>>> getGodowns() async {
    if (_preferences == null) await init();
    final raw = _preferences!.getString(_godownsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// **Save Godown Ids**
  static Future<void> saveGodownIds(List<int> godownIds) async {
    if (_preferences == null) await init();
    await _preferences!.setString(_godownIdsKey, jsonEncode(godownIds));
  }

  /// **Get Godown Ids**
  static Future<List<int>> getGodownIds() async {
    if (_preferences == null) await init();
    final raw = _preferences!.getString(_godownIdsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => int.parse(e.toString())).toList();
  }

  /// **Clear All Preferences (Logout)**
  static Future<void> clearAll() async {
    if (_preferences == null) await init();
    await _preferences!.clear();
    token = "";
    email = "";
  }
}
