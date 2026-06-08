import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _isLoggedInKey = 'is_logged_in';
  static const _usernameKey = 'username';
  static const _usersKey = 'registered_users';
  static late final SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static bool get isLoggedIn => _preferences.getBool(_isLoggedInKey) ?? false;
  static String get username => _preferences.getString(_usernameKey) ?? '';

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
    await login(username, password);
    return true;
  }

  static bool canLogin(String username, String password) {
    final users = _users;
    if (users.isEmpty) return true;
    return users[username] == password;
  }

  static Future<void> login(String username, String password) async {
    await _preferences.setBool(_isLoggedInKey, true);
    await _preferences.setString(_usernameKey, username);
  }

  static Future<void> logout() async {
    await _preferences.remove(_isLoggedInKey);
    await _preferences.remove(_usernameKey);
  }
}
