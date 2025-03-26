import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/domain/constants/appcolors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/utils/constants.dart';
import 'quiz_page.dart';
import 'create_quiz_page.dart';

class QuizSummary {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int questionCount;
  final String? subjectName;
  final String? subjectColor;
  final String? lessonTitle;
  final int timeLimit;
  final int passingScore;
  final String createdAt;

  QuizSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questionCount,
    this.subjectName,
    this.subjectColor,
    this.lessonTitle,
    required this.timeLimit,
    required this.passingScore,
    required this.createdAt,
  });

  factory QuizSummary.fromJson(Map<String, dynamic> json) {
    return QuizSummary(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      difficulty: json['difficulty'],
      questionCount: json['questionCount'],
      subjectName: json['subjectName'],
      subjectColor: json['subjectColor'],
      lessonTitle: json['lessonTitle'],
      timeLimit: json['timeLimit'],
      passingScore: json['passingScore'],
      createdAt: json['createdAt'],
    );
  }
}

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage>
    with SingleTickerProviderStateMixin {
  List<QuizSummary> _quizzes = [];
  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchQuizzes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchQuizzes() async {
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
        Uri.parse('${Constants.uri}/api/v1/quizzes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _quizzes =
              (data['quizzes'] as List)
                  .map((json) => QuizSummary.fromJson(json))
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print("Error fetching quizzes: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Color _getSubjectColor(String? colorName) {
    if (colorName == null) return Color(0xFF3B82F6); // Default blue

    switch (colorName.toLowerCase()) {
      case 'blue':
        return Color(0xFF3B82F6);
      case 'red':
        return Color(0xFFEF4444);
      case 'green':
        return Color(0xFF10B981);
      case 'purple':
        return Color(0xFF8B5CF6);
      case 'yellow':
        return Color(0xFFF59E0B);
      case 'pink':
        return Color(0xFFEC4899);
      default:
        return Color(0xFF3B82F6);
    }
  }

  IconData _getSubjectIcon(String? subjectName) {
    if (subjectName == null) return Icons.quiz;

    switch (subjectName.toLowerCase()) {
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
          "Quizzes",
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
            onPressed: fetchQuizzes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color.fromARGB(255, 255, 255, 255),
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: Color.fromARGB(255, 255, 255, 255),
          tabs: [
            Tab(text: "Available", icon: Icon(Icons.quiz)),
            Tab(text: "Completed", icon: Icon(Icons.check_circle)),
            Tab(text: "Analytics", icon: Icon(Icons.bar_chart)),
          ],
          labelStyle: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? _buildErrorState(settings, fontFamily())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildAvailableQuizzes(settings, fontFamily()),
                  _buildCompletedQuizzes(settings, fontFamily()),
                  _buildAnalytics(settings, fontFamily()),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateQuizPage()),
          ).then((_) => fetchQuizzes());
        },
        backgroundColor: Color(0XFF6366F1),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState(AccessibilitySettings settings, String fontFamily) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
            SizedBox(height: 16),
            Text(
              "Failed to load quizzes",
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "There was a problem loading the quizzes. Please try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
                color: Colors.grey.shade700,
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
              onPressed: fetchQuizzes,
              icon: Icon(Icons.refresh),
              label: Text(
                "Try Again",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableQuizzes(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    if (_quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              "No quizzes available",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Create a new quiz to get started",
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateQuizPage()),
                ).then((_) => fetchQuizzes());
              },
              icon: Icon(Icons.add),
              label: Text(
                "Create Quiz",
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

    return RefreshIndicator(
      onRefresh: fetchQuizzes,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _quizzes.length,
        itemBuilder: (context, index) {
          final quiz = _quizzes[index];
          return _buildQuizCard(quiz, settings, fontFamily);
        },
      ),
    );
  }

  Widget _buildCompletedQuizzes(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    // This would show quizzes the user has completed
    // For now, we'll show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            "No completed quizzes",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Complete a quiz to see your results here",
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

  Widget _buildAnalytics(AccessibilitySettings settings, String fontFamily) {
    // This would show analytics about the user's quiz performance
    // For now, we'll show a placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No analytics available",
            style: TextStyle(
              fontSize: 18 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Complete quizzes to see your performance analytics",
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

  Widget _buildQuizCard(
    QuizSummary quiz,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final Color subjectColor = _getSubjectColor(quiz.subjectColor);
    final IconData subjectIcon = _getSubjectIcon(quiz.subjectName);

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QuizPage(quizId: quiz.id)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child:
              MediaQuery.of(context).size.width > 600
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: subjectColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(subjectIcon, color: subjectColor, size: 32),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.title,
                              style: TextStyle(
                                fontSize: 18 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
                              ),
                            ),
                            SizedBox(height: 4),
                            if (quiz.subjectName != null) ...[
                              Text(
                                quiz.subjectName!,
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontFamily: fontFamily,
                                  color: subjectColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                            Text(
                              quiz.description,
                              style: TextStyle(
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8, // horizontal space between chips
                              runSpacing: 8, // vertical space between lines
                              children: [
                                _buildQuizInfoChip(
                                  "${quiz.questionCount} questions",
                                  Icons.help_outline,
                                  settings,
                                  fontFamily,
                                ),
                                _buildQuizInfoChip(
                                  "${quiz.timeLimit} min",
                                  Icons.timer,
                                  settings,
                                  fontFamily,
                                ),
                                _buildQuizInfoChip(
                                  quiz.difficulty,
                                  Icons.trending_up,
                                  settings,
                                  fontFamily,
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFF6366F1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              QuizPage(quizId: quiz.id),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Start Quiz",
                                  style: TextStyle(
                                    fontSize: 14 * settings.fontSize,
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
                  )
                  : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: subjectColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              subjectIcon,
                              color: subjectColor,
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz.title,
                                  style: TextStyle(
                                    fontSize: 18 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                                if (quiz.subjectName != null) ...[
                                  Text(
                                    quiz.subjectName!,
                                    style: TextStyle(
                                      fontSize: 14 * settings.fontSize,
                                      fontFamily: fontFamily,
                                      color: subjectColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        quiz.description,
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize,
                          fontFamily: fontFamily,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuizInfoChip(
                            "${quiz.questionCount} questions",
                            Icons.help_outline,
                            settings,
                            fontFamily,
                          ),
                          _buildQuizInfoChip(
                            "${quiz.timeLimit} min",
                            Icons.timer,
                            settings,
                            fontFamily,
                          ),
                          _buildQuizInfoChip(
                            quiz.difficulty,
                            Icons.trending_up,
                            settings,
                            fontFamily,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0XFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(quizId: quiz.id),
                              ),
                            );
                          },
                          child: Text(
                            "Start Quiz",
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildQuizInfoChip(
    String label,
    IconData icon,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12 * settings.fontSize,
              fontFamily: fontFamily,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
