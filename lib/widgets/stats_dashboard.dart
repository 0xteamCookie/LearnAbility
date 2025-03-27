import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/utils/constants.dart';

class UserStats {
  final int studyStreak;
  final int completedLessons;
  final int weeklyProgress;
  final double? quizAverage;
  final DateTime? lastStudiedAt;

  UserStats({
    required this.studyStreak,
    required this.completedLessons,
    required this.weeklyProgress,
    this.quizAverage,
    this.lastStudiedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      studyStreak: json['studyStreak'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      weeklyProgress: json['weeklyProgress'] ?? 0,
      quizAverage: json['quizAverage']?.toDouble(),
      lastStudiedAt:
          json['lastStudiedAt'] != null
              ? DateTime.parse(json['lastStudiedAt'])
              : null,
    );
  }
}

class StatsDashboard extends StatefulWidget {
  const StatsDashboard({super.key});

  @override
  State<StatsDashboard> createState() => _StatsDashboardState();
}

class _StatsDashboardState extends State<StatsDashboard> {
  bool _isLoading = true;
  bool _hasError = false;
  UserStats? _stats;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _stats = UserStats.fromJson(data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError || _stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            SizedBox(height: 16),
            Text(
              "Failed to load stats",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily(),
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: fetchStats, child: Text("Retry")),
          ],
        ),
      );
    }

    String lastStudied =
        _stats!.lastStudiedAt != null
            ? DateFormat('MMMM d, yyyy').format(_stats!.lastStudiedAt!)
            : "Never";

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: TextStyle(
              fontSize: 20 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                "Study Streak",
                "${_stats!.studyStreak} days",
                Icons.local_fire_department,
                Colors.orange,
                settings,
                fontFamily(),
              ),
              SizedBox(width: 12),
              _buildStatItem(
                "Lessons",
                "${_stats!.completedLessons}",
                Icons.book,
                Colors.blue,
                settings,
                fontFamily(),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                "Weekly Progress",
                "${_stats!.weeklyProgress} pts",
                Icons.trending_up,
                Colors.green,
                settings,
                fontFamily(),
              ),
              SizedBox(width: 12),
              _buildStatItem(
                "Quiz Average",
                _stats!.quizAverage != null
                    ? "${_stats!.quizAverage!.toStringAsFixed(1)}%"
                    : "N/A",
                Icons.quiz,
                Color(0XFF6366F1),
                settings,
                fontFamily(),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Last studied: $lastStudied",
            style: TextStyle(
              fontSize: 14 * settings.fontSize,
              fontFamily: fontFamily(),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12 * settings.fontSize,
                      fontFamily: fontFamily,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
