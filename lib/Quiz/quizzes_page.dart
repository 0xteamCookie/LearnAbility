import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/utils/constants.dart';
import 'quiz_page.dart';
import 'create_quiz_page.dart';

// Model for quiz summary
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

// Model for quiz attempt answer
class QuizAttemptAnswer {
  final bool isCorrect;
  final String questionId;
  final String givenAnswer;
  final int pointsEarned;

  QuizAttemptAnswer({
    required this.isCorrect,
    required this.questionId,
    required this.givenAnswer,
    required this.pointsEarned,
  });

  factory QuizAttemptAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAttemptAnswer(
      isCorrect: json['isCorrect'],
      questionId: json['questionId'],
      givenAnswer: json['givenAnswer'],
      pointsEarned: json['pointsEarned'],
    );
  }
}

// Model for quiz attempt
class QuizAttempt {
  final String id;
  final int score;
  final bool passed;
  final String userId;
  final List<QuizAttemptAnswer> answers;
  final int maxScore;
  final DateTime startedAt;
  final double percentage;
  final DateTime completedAt;

  QuizAttempt({
    required this.id,
    required this.score,
    required this.passed,
    required this.userId,
    required this.answers,
    required this.maxScore,
    required this.startedAt,
    required this.percentage,
    required this.completedAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      score: json['score'],
      passed: json['passed'],
      userId: json['userId'],
      answers:
          (json['answers'] as List)
              .map((a) => QuizAttemptAnswer.fromJson(a))
              .toList(),
      maxScore: json['maxScore'],
      startedAt: DateTime.parse(json['startedAt']),
      percentage: json['percentage'].toDouble(),
      completedAt: DateTime.parse(json['completedAt']),
    );
  }

  // Calculate duration in minutes
  int get durationInMinutes {
    return completedAt.difference(startedAt).inMinutes;
  }

  // Format the completion date
  String get formattedCompletionDate {
    return DateFormat('MMM d, yyyy • h:mm a').format(completedAt.toLocal());
  }
}

// Model for question analytics
class QuestionAnalytics {
  final String questionId;
  final String content;
  final double correctRate;
  final int attemptCount;

  QuestionAnalytics({
    required this.questionId,
    required this.content,
    required this.correctRate,
    required this.attemptCount,
  });

  factory QuestionAnalytics.fromJson(Map<String, dynamic> json) {
    return QuestionAnalytics(
      questionId: json['questionId'],
      content: json['content'],
      correctRate: json['correctRate'].toDouble(),
      attemptCount: json['attemptCount'],
    );
  }
}

// Model for progress trend
class ProgressTrend {
  final DateTime date;
  final double score;
  final bool passed;

  ProgressTrend({
    required this.date,
    required this.score,
    required this.passed,
  });

  factory ProgressTrend.fromJson(Map<String, dynamic> json) {
    return ProgressTrend(
      date: DateTime.parse(json['date']),
      score: json['score'].toDouble(),
      passed: json['passed'],
    );
  }
}

// Model for quiz analytics
class QuizAnalytics {
  final int attemptsCount;
  final double averageScore;
  final double bestScore;
  final double worstScore;
  final double passRate;
  final List<QuestionAnalytics> questionAnalytics;
  final List<ProgressTrend> progressTrend;

  QuizAnalytics({
    required this.attemptsCount,
    required this.averageScore,
    required this.bestScore,
    required this.worstScore,
    required this.passRate,
    required this.questionAnalytics,
    required this.progressTrend,
  });

  factory QuizAnalytics.fromJson(Map<String, dynamic> json) {
    return QuizAnalytics(
      attemptsCount: json['attemptsCount'],
      averageScore: json['averageScore'].toDouble(),
      bestScore: json['bestScore'].toDouble(),
      worstScore: json['worstScore'].toDouble(),
      passRate: json['passRate'].toDouble(),
      questionAnalytics:
          (json['questionAnalytics'] as List)
              .map((q) => QuestionAnalytics.fromJson(q))
              .toList(),
      progressTrend:
          (json['progressTrend'] as List)
              .map((p) => ProgressTrend.fromJson(p))
              .toList(),
    );
  }
}

// Model for subject performance
class SubjectPerformance {
  final String subjectId;
  final String subjectName;
  final String subjectColor;
  final double averageScore;
  final int attemptCount;

  SubjectPerformance({
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.averageScore,
    required this.attemptCount,
  });

  factory SubjectPerformance.fromJson(Map<String, dynamic> json) {
    return SubjectPerformance(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectColor: json['subjectColor'],
      averageScore: json['averageScore'].toDouble(),
      attemptCount: json['attemptCount'],
    );
  }
}

// Model for recent activity
class RecentActivity {
  final String id;
  final String quizId;
  final String quizTitle;
  final DateTime completedAt;
  final int score;
  final int totalQuestions;
  final double percentage;
  final bool passed;

  RecentActivity({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.completedAt,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      quizId: json['quizId'],
      quizTitle: json['quizTitle'],
      completedAt: DateTime.parse(json['completedAt']),
      score: json['score'],
      totalQuestions: json['totalQuestions'] ?? 0,
      percentage: json['percentage'].toDouble(),
      passed: json['passed'],
    );
  }
}

// Model for overall quiz analytics
class OverallQuizAnalytics {
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final List<SubjectPerformance> subjectPerformance;
  final List<RecentActivity> recentActivity;

  OverallQuizAnalytics({
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    required this.subjectPerformance,
    required this.recentActivity,
  });

  factory OverallQuizAnalytics.fromJson(Map<String, dynamic> json) {
    return OverallQuizAnalytics(
      totalQuizzes: json['totalQuizzes'],
      completedQuizzes: json['completedQuizzes'],
      averageScore: json['averageScore'].toDouble(),
      subjectPerformance:
          (json['subjectPerformance'] as List)
              .map((s) => SubjectPerformance.fromJson(s))
              .toList(),
      recentActivity:
          (json['recentActivity'] as List)
              .map((r) => RecentActivity.fromJson(r))
              .toList(),
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
  Map<String, List<QuizAttempt>> _quizAttempts = {};
  Map<String, QuizAnalytics> _quizAnalytics = {};
  OverallQuizAnalytics? _overallAnalytics;

  bool _isLoading = true;
  bool _hasError = false;
  late TabController _tabController;

  String? _selectedQuizId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchQuizzes();
    fetchOverallAnalytics();
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
        print("Fetched quizzes: ${data['quizzes'].length}");
        setState(() {
          _quizzes =
              (data['quizzes'] as List)
                  .map((json) => QuizSummary.fromJson(json))
                  .toList();
          _isLoading = false;
        });
      } else {
        print("Failed to fetch quizzes: ${response.statusCode}");
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

  Future<void> fetchQuizAttempts(String quizId) async {
    // Skip if we already have the attempts for this quiz
    if (_quizAttempts.containsKey(quizId)) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/quizzes/$quizId/attempts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Fetched attempts for quiz $quizId: ${data['attempts'].length}");
        setState(() {
          _quizAttempts[quizId] =
              (data['attempts'] as List)
                  .map((json) => QuizAttempt.fromJson(json))
                  .toList();
        });
      } else {
        print(
          "Failed to fetch attempts for quiz $quizId: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching attempts for quiz $quizId: $e");
    }
  }

  Future<void> fetchQuizAnalytics(String quizId) async {
    // Skip if we already have the analytics for this quiz
    if (_quizAnalytics.containsKey(quizId)) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/analytics/quizzes/$quizId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Fetched analytics for quiz $quizId");
        setState(() {
          _quizAnalytics[quizId] = QuizAnalytics.fromJson(data['analytics']);
        });
      } else {
        print(
          "Failed to fetch analytics for quiz $quizId: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching analytics for quiz $quizId: $e");
    }
  }

  Future<void> fetchOverallAnalytics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/analytics/quizzes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Fetched overall analytics");
        setState(() {
          _overallAnalytics = OverallQuizAnalytics.fromJson(data['analytics']);
        });
      } else {
        print("Failed to fetch overall analytics: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching overall analytics: $e");
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Quizzes",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              fetchQuizzes();
              fetchOverallAnalytics();
              // Clear cached data to force refresh
              setState(() {
                _quizAttempts.clear();
                _quizAnalytics.clear();
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0XFF6366F1),
          unselectedLabelColor: Colors.grey.shade700,
          indicatorColor: Color(0XFF6366F1),
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
          _isLoading && _quizzes.isEmpty
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
        child: Icon(Icons.add, color: Colors.white),
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
    // If no quiz is selected, show a list of quizzes with attempts
    if (_selectedQuizId == null) {
      // First, fetch attempts for all quizzes
      for (var quiz in _quizzes) {
        fetchQuizAttempts(quiz.id);
      }

      // Filter quizzes that have attempts
      List<QuizSummary> quizzesWithAttempts = [];
      for (var quiz in _quizzes) {
        if (_quizAttempts.containsKey(quiz.id) &&
            _quizAttempts[quiz.id]!.isNotEmpty) {
          quizzesWithAttempts.add(quiz);
        }
      }

      if (quizzesWithAttempts.isEmpty) {
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

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: quizzesWithAttempts.length,
        itemBuilder: (context, index) {
          final quiz = quizzesWithAttempts[index];
          final attempts = _quizAttempts[quiz.id] ?? [];
          final lastAttempt = attempts.isNotEmpty ? attempts.last : null;

          return Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedQuizId = quiz.id;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getSubjectColor(
                              quiz.subjectColor,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getSubjectIcon(quiz.subjectName),
                            color: _getSubjectColor(quiz.subjectColor),
                            size: 24,
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
                                    color: _getSubjectColor(quiz.subjectColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0XFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${attempts.length} attempts",
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                              color: Color(0XFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (lastAttempt != null) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              lastAttempt.passed
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                lastAttempt.passed
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  lastAttempt.passed
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 20,
                                  color:
                                      lastAttempt.passed
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Last Attempt",
                                  style: TextStyle(
                                    fontSize: 14 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "${lastAttempt.percentage.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 16 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                    color:
                                        lastAttempt.passed
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.score,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Score: ${lastAttempt.score}/${lastAttempt.maxScore}",
                                        style: TextStyle(
                                          fontSize: 14 * settings.fontSize,
                                          fontFamily: fontFamily,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(
                                          lastAttempt.completedAt.toLocal(),
                                        ),
                                        style: TextStyle(
                                          fontSize: 14 * settings.fontSize,
                                          fontFamily: fontFamily,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Color(0XFF6366F1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedQuizId = quiz.id;
                              });
                            },
                            icon: Icon(Icons.history),
                            label: Text(
                              "View History",
                              style: TextStyle(
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0XFF6366F1),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => QuizPage(quizId: quiz.id),
                                ),
                              );
                            },
                            icon: Icon(Icons.play_arrow),
                            label: Text(
                              "Try Again",
                              style: TextStyle(
                                fontSize: 14 * settings.fontSize,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Show attempts for the selected quiz
      fetchQuizAttempts(_selectedQuizId!);
      final attempts = _quizAttempts[_selectedQuizId] ?? [];
      final quiz = _quizzes.firstWhere((q) => q.id == _selectedQuizId);

      return Column(
        children: [
          // Header with back button
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedQuizId = null;
                    });
                  },
                ),
                SizedBox(width: 8),
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
                      Text(
                        "${attempts.length} attempts",
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize,
                          fontFamily: fontFamily,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Attempts list
          Expanded(
            child:
                attempts.isEmpty
                    ? Center(
                      child: Text(
                        "No attempts for this quiz",
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontFamily: fontFamily,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: attempts.length,
                      itemBuilder: (context, index) {
                        // Show attempts in reverse chronological order
                        final attempt = attempts[attempts.length - 1 - index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            attempt.passed
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        attempt.passed
                                            ? Icons.check
                                            : Icons.close,
                                        color:
                                            attempt.passed
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Attempt ${index + 1}",
                                            style: TextStyle(
                                              fontSize: 16 * settings.fontSize,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: fontFamily,
                                            ),
                                          ),
                                          Text(
                                            attempt.formattedCompletionDate,
                                            style: TextStyle(
                                              fontSize: 14 * settings.fontSize,
                                              fontFamily: fontFamily,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            attempt.passed
                                                ? Colors.green.shade50
                                                : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              attempt.passed
                                                  ? Colors.green.shade200
                                                  : Colors.red.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        "${attempt.percentage.toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          fontSize: 16 * settings.fontSize,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily,
                                          color:
                                              attempt.passed
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Divider(),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildAttemptStatItem(
                                        "Score",
                                        "${attempt.score}/${attempt.maxScore}",
                                        Icons.score,
                                        settings,
                                        fontFamily,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildAttemptStatItem(
                                        "Time Taken",
                                        "${attempt.durationInMinutes} min",
                                        Icons.timer,
                                        settings,
                                        fontFamily,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildAttemptStatItem(
                                        "Correct",
                                        "${attempt.answers.where((a) => a.isCorrect).length}/${attempt.answers.length}",
                                        Icons.check_circle_outline,
                                        settings,
                                        fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                ExpansionTile(
                                  title: Text(
                                    "Question Details",
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: attempt.answers.length,
                                      itemBuilder: (context, qIndex) {
                                        final answer = attempt.answers[qIndex];
                                        return ListTile(
                                          leading: Icon(
                                            answer.isCorrect
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color:
                                                answer.isCorrect
                                                    ? Colors.green.shade600
                                                    : Colors.red.shade600,
                                          ),
                                          title: Text(
                                            "Question ${qIndex + 1}",
                                            style: TextStyle(
                                              fontSize: 14 * settings.fontSize,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: fontFamily,
                                            ),
                                          ),
                                          subtitle: Text(
                                            answer.isCorrect
                                                ? "Correct (+${answer.pointsEarned} points)"
                                                : "Incorrect (0 points)",
                                            style: TextStyle(
                                              fontSize: 14 * settings.fontSize,
                                              fontFamily: fontFamily,
                                              color:
                                                  answer.isCorrect
                                                      ? Colors.green.shade600
                                                      : Colors.red.shade600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      );
    }
  }

  Widget _buildAttemptStatItem(
    String title,
    String value,
    IconData icon,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Column(
      children: [
        Icon(icon, color: Color(0XFF6366F1), size: 24),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12 * settings.fontSize,
            fontFamily: fontFamily,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalytics(AccessibilitySettings settings, String fontFamily) {
    // If no quiz is selected, show overall analytics
    if (_selectedQuizId == null) {
      if (_overallAnalytics == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Loading analytics...",
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

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall stats
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0XFF6366F1), Color(0XFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Quiz Performance",
                    style: TextStyle(
                      fontSize: 20 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverallStatItem(
                          "Total Quizzes",
                          "${_overallAnalytics!.totalQuizzes}",
                          Icons.quiz,
                          settings,
                          fontFamily,
                        ),
                      ),
                      Expanded(
                        child: _buildOverallStatItem(
                          "Completed",
                          "${_overallAnalytics!.completedQuizzes}",
                          Icons.check_circle,
                          settings,
                          fontFamily,
                        ),
                      ),
                      Expanded(
                        child: _buildOverallStatItem(
                          "Avg. Score",
                          "${_overallAnalytics!.averageScore.toStringAsFixed(1)}%",
                          Icons.score,
                          settings,
                          fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Subject performance
            Text(
              "Performance by Subject",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            SizedBox(height: 12),
            if (_overallAnalytics!.subjectPerformance.isEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "No subject data available",
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _overallAnalytics!.subjectPerformance.length,
                itemBuilder: (context, index) {
                  final subject = _overallAnalytics!.subjectPerformance[index];
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getSubjectColor(
                                subject.subjectColor,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getSubjectIcon(subject.subjectName),
                              color: _getSubjectColor(subject.subjectColor),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.subjectName,
                                  style: TextStyle(
                                    fontSize: 16 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "${subject.attemptCount} attempts",
                                  style: TextStyle(
                                    fontSize: 14 * settings.fontSize,
                                    fontFamily: fontFamily,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(
                                subject.averageScore,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${subject.averageScore.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
                                color: _getScoreColor(subject.averageScore),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            SizedBox(height: 24),

            // Recent activity
            Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            SizedBox(height: 12),
            if (_overallAnalytics!.recentActivity.isEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "No recent activity",
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontFamily: fontFamily,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _overallAnalytics!.recentActivity.length,
                itemBuilder: (context, index) {
                  final activity = _overallAnalytics!.recentActivity[index];
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      activity.passed
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  activity.passed ? Icons.check : Icons.close,
                                  color:
                                      activity.passed
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  activity.quizTitle,
                                  style: TextStyle(
                                    fontSize: 16 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      activity.passed
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        activity.passed
                                            ? Colors.green.shade200
                                            : Colors.red.shade200,
                                  ),
                                ),
                                child: Text(
                                  "${activity.percentage.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 14 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                    color:
                                        activity.passed
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'MMM d, yyyy • h:mm a',
                                ).format(activity.completedAt.toLocal()),
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontFamily: fontFamily,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.score,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Score: ${activity.score}/${activity.totalQuestions}",
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontFamily: fontFamily,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    } else {
      // Show analytics for the selected quiz
      fetchQuizAnalytics(_selectedQuizId!);
      final analytics = _quizAnalytics[_selectedQuizId];
      final quiz = _quizzes.firstWhere((q) => q.id == _selectedQuizId);

      if (analytics == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Loading quiz analytics...",
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

      return Column(
        children: [
          // Header with back button
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedQuizId = null;
                    });
                  },
                ),
                SizedBox(width: 8),
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
                      Text(
                        "Analytics",
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize,
                          fontFamily: fontFamily,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Quiz analytics
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Performance summary
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0XFF6366F1), Color(0XFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Performance Summary",
                          style: TextStyle(
                            fontSize: 18 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuizAnalyticsItem(
                                "Attempts",
                                "${analytics.attemptsCount}",
                                Icons.repeat,
                                settings,
                                fontFamily,
                              ),
                            ),
                            Expanded(
                              child: _buildQuizAnalyticsItem(
                                "Avg. Score",
                                "${analytics.averageScore.toStringAsFixed(1)}%",
                                Icons.score,
                                settings,
                                fontFamily,
                              ),
                            ),
                            Expanded(
                              child: _buildQuizAnalyticsItem(
                                "Pass Rate",
                                "${(analytics.passRate * 100).toStringAsFixed(0)}%",
                                Icons.check_circle,
                                settings,
                                fontFamily,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuizAnalyticsItem(
                                "Best Score",
                                "${analytics.bestScore.toStringAsFixed(1)}%",
                                Icons.emoji_events,
                                settings,
                                fontFamily,
                              ),
                            ),
                            Expanded(
                              child: _buildQuizAnalyticsItem(
                                "Worst Score",
                                "${analytics.worstScore.toStringAsFixed(1)}%",
                                Icons.trending_down,
                                settings,
                                fontFamily,
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Progress trend
                  Text(
                    "Progress Trend",
                    style: TextStyle(
                      fontSize: 18 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (analytics.progressTrend.isEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "No progress data available",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontFamily: fontFamily,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
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
                      child: Center(
                        child: Text(
                          "Progress chart would be displayed here",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontFamily: fontFamily,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 24),

                  // Question analytics
                  Text(
                    "Question Performance",
                    style: TextStyle(
                      fontSize: 18 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                    ),
                  ),
                  SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: analytics.questionAnalytics.length,
                    itemBuilder: (context, index) {
                      final question = analytics.questionAnalytics[index];
                      return Card(
                        elevation: 1,
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _getCorrectRateColor(
                                        question.correctRate,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${(index + 1)}",
                                        style: TextStyle(
                                          fontSize: 14 * settings.fontSize,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily,
                                          color: _getCorrectRateColor(
                                            question.correctRate,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Question ${index + 1}",
                                      style: TextStyle(
                                        fontSize: 16 * settings.fontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getCorrectRateColor(
                                        question.correctRate,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${(question.correctRate * 100).toStringAsFixed(0)}% correct",
                                      style: TextStyle(
                                        fontSize: 14 * settings.fontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: fontFamily,
                                        color: _getCorrectRateColor(
                                          question.correctRate,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                question.content,
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontFamily: fontFamily,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Attempted ${question.attemptCount} times",
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontFamily: fontFamily,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildOverallStatItem(
    String title,
    String value,
    IconData icon,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizAnalyticsItem(
    String title,
    String value,
    IconData icon,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12 * settings.fontSize,
            fontFamily: fontFamily,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: Colors.white,
          ),
        ),
      ],
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

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 60) return Colors.amber.shade700;
    return Colors.red.shade700;
  }

  Color _getCorrectRateColor(double rate) {
    if (rate >= 0.8) return Colors.green.shade700;
    if (rate >= 0.6) return Colors.amber.shade700;
    return Colors.red.shade700;
  }
}
