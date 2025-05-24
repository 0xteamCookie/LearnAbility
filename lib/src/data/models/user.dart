import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;
  final String standard;
  final List<String> interests;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.standard,
    required this.interests,
  });

  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'standard': standard,
      'interests': interests,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      standard: json['standard'] as String,
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  factory User.fromJsonString(String source) {
    return User.fromJson(json.decode(source));
  }

  String toJson() => json.encode(toJsonMap());

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      standard: map['standard'] as String,
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}
