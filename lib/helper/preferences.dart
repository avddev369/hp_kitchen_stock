import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _preferences;
  static String token = "";
  static String email = "";

  static const String _userNameKey = 'userName';
  static const String _tokenKey = 'token';
  static const String _emailKey = 'email';

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

  /// **Clear All Preferences (Logout)**
  static Future<void> clearAll() async {
    if (_preferences == null) await init();
    await _preferences!.clear();
    token = "";
    email = "";
  }
}
