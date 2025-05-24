import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StatsService {
  // Fetch user stats
  static Future<Map<String, dynamic>?> getUserStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    
    if (token == null || token.isEmpty) {
      return null;
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
        return data['data'];
      } else {
        print("Failed to fetch user stats: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching user stats: $e");
      return null;
    }
  }
  
  // Mark lesson as completed
  static Future<bool> markLessonAsCompleted(String lessonId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    
    if (token == null || token.isEmpty) {
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/v1/stats/lesson/$lessonId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print("Error marking lesson as completed: $e");
      return false;
    }
  }
  
  // Track user activity
  static Future<bool> trackActivity(String activityType, int duration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    
    if (token == null || token.isEmpty) {
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/v1/stats/track'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'activityType': activityType,
          'duration': duration,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print("Error tracking activity: $e");
      return false;
    }
  }
}

