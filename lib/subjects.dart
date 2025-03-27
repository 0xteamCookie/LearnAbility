import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/domain/constants/appcolors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Lesson/lessons_page.dart';
import 'accessibility_model.dart';
import 'utils/constants.dart';

class Subject {
  final String id;
  final String name;
  final String color;
  final String status;
  final int materialCount;
  final String createdAt;
  final String updatedAt;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.status,
    required this.materialCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? 'blue',
      status: json['status'],
      materialCount: json['materialCount'] ?? 0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<Subject> subjects = [];
  bool isLoading = true;
  bool hasError = false;
  bool isGeneratingLessons = false;
  String? generatingSubjectId;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
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
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          subjects =
              (data['subjects'] as List)
                  .map((json) => Subject.fromJson(json))
                  .toList();
          isLoading = false;
        });

        // Start polling for processing subjects
        _checkProcessingSubjects();
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

  void _checkProcessingSubjects() {
    // Check if any subjects are in PROCESSING state
    bool hasProcessingSubjects = subjects.any(
      (subject) => subject.status == 'PROCESSING',
    );

    if (hasProcessingSubjects) {
      // Poll every 5 seconds for updates
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          fetchSubjects();
        }
      });
    }
  }

  Future<void> generateLessons(String subjectId) async {
    setState(() {
      isGeneratingLessons = true;
      generatingSubjectId = subjectId;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        isGeneratingLessons = false;
        generatingSubjectId = null;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects/$subjectId/lessons'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully started generating lessons
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generating lessons for this subject")),
        );

        // Refresh subjects to get updated status
        fetchSubjects();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to generate lessons")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating lessons: $e")));
    } finally {
      setState(() {
        isGeneratingLessons = false;
        generatingSubjectId = null;
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
          "Explore Subjects",
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
            onPressed: fetchSubjects,
          ),
        ],
      ),
      body:
          isLoading && subjects.isEmpty
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchSubjects,
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
                              "Start your learning journey",
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
                                        "Failed to load subjects. Pull down to refresh.",
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
                          subjects.isEmpty && !isLoading
                              ? SliverToBoxAdapter(
                                child: _buildEmptyState(settings, fontFamily()),
                              )
                              : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildSubjectCard(
                                    subjects[index],
                                    settings,
                                    fontFamily(),
                                  ),
                                  childCount: subjects.length,
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
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No subjects available",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Check back later or contact your administrator",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * settings.fontSize,
              fontFamily: fontFamily,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    Subject subject,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final bool isProcessing = subject.status == 'PROCESSING';
    final bool isGenerating =
        isGeneratingLessons && generatingSubjectId == subject.id;

    Color getSubjectColor() {
      switch (subject.color.toLowerCase()) {
        case 'blue':
          return Color(0xFF3B82F6);
        case 'red':
          return Color(0xFFEF4444);
        case 'green':
          return Color(0xFF10B981);
        case 'purple':
          return Color(0XFF6366F1);
        case 'yellow':
          return Color(0xFFF59E0B);
        case 'pink':
          return Color(0xFFEC4899);
        default:
          return Color(0xFF3B82F6);
      }
    }

    IconData getSubjectIcon() {
      switch (subject.name.toLowerCase()) {
        case 'mathematics':
          return Icons.calculate;
        case 'science':
          return Icons.science;
        case 'english':
          return Icons.menu_book;
        case 'history':
          return Icons.history_edu;
        case 'geography':
          return Icons.public;
        case 'physics':
          return Icons.bolt;
        case 'chemistry':
          return Icons.science;
        case 'biology':
          return Icons.eco;
        case 'computer science':
          return Icons.computer;
        default:
          return Icons.school;
      }
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: getSubjectColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    getSubjectIcon(),
                    color: getSubjectColor(),
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: 18 * settings.fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          if (isProcessing) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Processing",
                                    style: TextStyle(
                                      fontSize: 12 * settings.fontSize,
                                      fontFamily: fontFamily,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              child: Text(
                                "Ready",
                                style: TextStyle(
                                  fontSize: 12 * settings.fontSize,
                                  fontFamily: fontFamily,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(width: 8),
                          Text(
                            "${subject.materialCount} materials",
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              color: Colors.grey.shade600,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (isProcessing) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed:
                      isGenerating ? null : () => generateLessons(subject.id),
                  child:
                      isGenerating
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Generating Lessons...",
                                style: TextStyle(
                                  fontSize: 16 * settings.fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            "Generate Lessons",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBackground,
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
                            (context) => LessonsPage(
                              subjectId: subject.id,
                              subjectName: subject.name,
                            ),
                      ),
                    );
                  },
                  child: Text(
                    "Start Learning",
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
