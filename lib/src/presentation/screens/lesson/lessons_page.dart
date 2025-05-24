import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/src/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lesson_page.dart';
import 'package:my_first_app/src/presentation/providers/accessibility_settings_provider.dart';
import 'package:my_first_app/src/core/app_constants.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String level;
  final int order;
  final int progress;
  final String image;
  final String subjectId;
  final List<Map<String, String>> prerequisites;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.order,
    required this.progress,
    required this.image,
    required this.subjectId,
    required this.prerequisites,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> prereqs = [];
    if (json['prerequisites'] != null) {
      prereqs =
          (json['prerequisites'] as List)
              .map((prereq) {
                return {'id': prereq['id'], 'title': prereq['title']};
              })
              .toList()
              .cast<Map<String, String>>();
    }

    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      level: json['level'],
      order: json['order'],
      progress: json['progress'],
      image: json['image'] ?? '/placeholder.svg?height=200&width=400',
      subjectId: json['subjectId'],
      prerequisites: prereqs,
    );
  }
}

class LessonsPage extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const LessonsPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  List<Lesson> lessons = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchLessons();
  }

  Future<void> fetchLessons() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${Constants.uri}/api/v1/pyos/subjects/${widget.subjectId}/lessons',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          lessons =
              (data['lessons'] as List)
                  .map((json) => Lesson.fromJson(json))
                  .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.subjectName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchLessons,
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchLessons,
                child: CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Available Lessons",
                              style: TextStyle(
                                fontSize: 22 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Complete lessons in order to master the subject",
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                                color: Colors.grey.shade700,
                                fontFamily: fontFamily(),
                              ),
                            ),
                            SizedBox(height: 16),
                            if (hasError)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Failed to load lessons. Pull down to refresh.",
                                        style: TextStyle(
                                          fontSize: 14 * settings.fontSize,
                                          color: Colors.red.shade700,
                                          fontFamily: fontFamily(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver:
                          lessons.isEmpty && !isLoading
                              ? SliverToBoxAdapter(
                                child: _buildEmptyState(settings, fontFamily()),
                              )
                              : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildLessonCard(
                                    lessons[index],
                                    settings,
                                    fontFamily(),
                                  ),
                                  childCount: lessons.length,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildEmptyState(AccessibilitySettings settings, String fontFamily) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No lessons available",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Lessons are being generated or not available yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * settings.fontSize,
              fontFamily: fontFamily,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFF6366F1),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: fetchLessons,
            icon: Icon(Icons.refresh),
            label: Text(
              "Refresh",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(
    Lesson lesson,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                lesson.image.startsWith('http')
                    ? lesson.image
                    : '${Constants.uri}${lesson.image}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Lesson Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson Number and Level
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0XFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Lesson ${lesson.order}",
                        style: TextStyle(
                          fontSize: 12 * settings.fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                          color: Color(0XFF6366F1),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLevelColor(lesson.level).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        lesson.level,
                        style: TextStyle(
                          fontSize: 12 * settings.fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                          color: _getLevelColor(lesson.level),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Lesson Title
                Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                SizedBox(height: 8),

                // Lesson Description
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize,
                    color: Colors.grey.shade700,
                    fontFamily: fontFamily,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),

                // Duration and Prerequisites
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      lesson.duration,
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        color: Colors.grey.shade600,
                        fontFamily: fontFamily,
                      ),
                    ),
                    if (lesson.prerequisites.isNotEmpty) ...[
                      SizedBox(width: 16),
                      Icon(
                        Icons.list_alt,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "${lesson.prerequisites.length} prerequisites",
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize,
                          color: Colors.grey.shade600,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16),

                // Start Lesson Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => LessonContentPage(
                                lessonId: lesson.id,
                                subjectId: widget.subjectId,
                              ),
                        ),
                      );
                    },
                    child: Text(
                      "Start Lesson",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green.shade700;
      case 'intermediate':
        return Colors.amber.shade700;
      case 'advanced':
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }
}
