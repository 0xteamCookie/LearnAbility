import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/home_page.dart';
import 'package:my_first_app/models/user.dart';
import 'package:my_first_app/repository/screens/login/loginscreen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:my_first_app/providers/auth_provider.dart';
import 'package:my_first_app/utils/constants.dart';

class AuthServices {
  Future<void> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'];
        final user = User.fromJson(data['user']);

        // ✅ Set user state & store in SharedPreferences
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).setUser(user, token);

        print("Login Successful!");

        // ✅ Navigate to HomePage after login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Login Failed: $e");
    }
  }
  // Future<void> loginUser({
  //   required String email,
  //   required String password,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('${Constants.uri}/api/v1/auth/login'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'email': email, 'password': password}),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final String token = data['token'];

  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString("jwt_token", token);

  //       await Provider.of<AuthProvider>(
  //         context,
  //         listen: false,
  //       ).checkAuthStatus();

  //       print("Login Successful!");

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomePage()),
  //       );
  //     } else {
  //       print("Error: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Login Failed: $e");
  //   }
  // }

  Future<void> signupUser({
    required String name,
    required String email,
    required String password,
    required String standard,
    required List<String> interests,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'standard': standard,
          'interests': interests,
        }),
      );

      if (response.statusCode == 201) {
        print("Signup Successful!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Signup Failed: $e");
    }
  }
}
