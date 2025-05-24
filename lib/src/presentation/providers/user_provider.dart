// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:my_first_app/models/user.dart';

// class UserProvider extends ChangeNotifier {
//   User? _user;

//   User? get user => _user;

//   void setUser(String userJson) {
//     final Map<String, dynamic> userMap = jsonDecode(userJson);
//     _user = User.fromJson(userMap);
//     notifyListeners();
//   }

//   String get username => _user?.name ?? 'Guest';
// }
