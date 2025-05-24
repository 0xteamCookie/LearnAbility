import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/src/core/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/src/data/models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  /// ✅ Load user from local storage (SharedPreferences) on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final String? userJson = prefs.getString('user_data'); // ✅ Get stored user

    if (token == null || token.isEmpty) {
      print("No token found, setting user to null.");
      _user = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['user']);
        await prefs.setString(
          'user_data',
          jsonEncode(data['user']),
        ); // ✅ Store user data
        print("User authenticated: ${_user?.toJson()}");
      } else {
        print("Invalid token, logging out.");
        _user = null;
        await prefs.remove('jwt_token');
        await prefs.remove(
          'user_data',
        ); // ✅ Remove user data if token is invalid
      }
    } catch (e) {
      print("Error checking auth status: $e");
      if (userJson != null) {
        _user = User.fromJson(
          jsonDecode(userJson),
        ); // ✅ Load user from local storage
        print("Loaded user from local storage: ${_user?.toJson()}");
      } else {
        _user = null;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Logout and remove user from storage
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    _user = null;
    notifyListeners();
  }

  /// ✅ Set user after login & store in SharedPreferences
  Future<void> setUser(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    print("🔍 Before setting user: ${_user?.toJson()}");

    await prefs.setString("jwt_token", token);
    await prefs.setString(
      "user_data",
      jsonEncode(user.toJson()),
    ); // ✅ Store user data

    _user = user; // ✅ Store user in memory
    notifyListeners(); // ✅ Notify UI updates

    print("✅ After setting user: ${_user?.toJson()}");
  }
}
