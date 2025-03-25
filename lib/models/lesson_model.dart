import 'package:flutter/material.dart';

class Lesson {
  final String id;
  final String title;
  final String subject;
  final String time;
  final String status;
  final Color color;
  final Color accentColor;
  
  Lesson({
    required this.id,
    required this.title,
    required this.subject,
    this.time = '',
    this.status = '',
    this.color = Colors.white,
    required this.accentColor,
  });
  
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'Ready',
      color: Color(int.parse(json['color'] ?? '0xFFFAF5FF', radix: 16)),
      accentColor: Color(int.parse(json['accent_color'] ?? '0xFF7E22CE', radix: 16)),
    );
  }
}