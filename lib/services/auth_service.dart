import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _isLoggedInKey = 'is_logged_in';
  static const _usernameKey = 'username';
  static const _usersKey = 'registered_users';
  static const _profilePhotoPrefix = 'profile_photo_';
  static late final SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static bool get isLoggedIn => _preferences.getBool(_isLoggedInKey) ?? false;
  static String get username => _preferences.getString(_usernameKey) ?? '';
  static String get profilePhotoPath =>
      _preferences.getString('$_profilePhotoPrefix$username') ?? '';

  static Map<String, String> get _users {
    final raw = _preferences.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};

    return decoded.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  static Future<bool> register(String username, String password) async {
    final users = _users;
    if (users.containsKey(username)) return false;

    users[username] = password;
    await _preferences.setString(_usersKey, jsonEncode(users));
    // tidak auto login — user harus login manual
    return true;
  }

  static bool canLogin(String username, String password) {
    final users = _users;
    if (users.isEmpty) return false; // belum ada user → wajib register dulu
    return users[username] == password;
  }

  static Future<void> login(String username, String password) async {
    await _preferences.setBool(_isLoggedInKey, true);
    await _preferences.setString(_usernameKey, username);
  }

  static Future<void> logout() async {
    await _preferences.setBool(_isLoggedInKey, false);
    await _preferences.remove(_usernameKey);
  }

  static Future<void> saveProfilePhotoPath(String path) async {
    if (username.isEmpty) return;
    await _preferences.setString('$_profilePhotoPrefix$username', path);
  }
}
