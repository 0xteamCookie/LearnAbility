import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/utils/constants.dart';

class QuizQuestion {
  final String id;
  final String content;
  final String type;
  final int points;
  final List<QuizAnswer> answers;
  final String difficulty;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.content,
    required this.type,
    required this.points,
    required this.answers,
    required this.difficulty,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    var answersList = <QuizAnswer>[];

    // Safely handle answers field which might be null or not a list
    if (json['answers'] != null) {
      try {
        final answersJson = json['answers'];
        if (answersJson is List) {
          answersList =
              answersJson
                  .where((a) => a != null)
                  .map((a) => QuizAnswer.fromJson(a))
                  .toList();
        }
      } catch (e) {
        print("Error parsing answers for question ${json['id']}: $e");
      }
    }

    return QuizQuestion(
      id: json['id'],
      content: json['content'],
      type: json['type'],
      points: json['points'],
      answers: answersList,
      difficulty: json['difficulty'],
      explanation: json['explanation'] ?? '',
    );
  }
}

class QuizAnswer {
  final String id;
  final String content;
  final bool isCorrect;
  final String explanation;

  QuizAnswer({
    required this.id,
    required this.content,
    required this.isCorrect,
    required this.explanation,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json['id'],
      content: json['content'],
      isCorrect: json['isCorrect'],
      explanation: json['explanation'] ?? '',
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int questionCount;
  final int timeLimit;
  final int passingScore;
  final String? subjectName;
  final String? subjectColor;
  final String? lessonTitle;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questionCount,
    required this.timeLimit,
    required this.passingScore,
    this.subjectName,
    this.subjectColor,
    this.lessonTitle,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      difficulty: json['difficulty'],
      questionCount: json['questionCount'],
      timeLimit: json['timeLimit'],
      passingScore: json['passingScore'],
      subjectName: json['subjectName'] ?? json['subject']?['name'],
      subjectColor: json['subjectColor'] ?? json['subject']?['color'],
      lessonTitle: json['lessonTitle'] ?? json['lesson']?['title'],
      questions:
          json['questions'] != null
              ? (json['questions'] as List)
                  .map((q) => QuizQuestion.fromJson(q))
                  .toList()
              : [],
    );
  }
}

class QuizPage extends StatefulWidget {
  final String quizId;

  const QuizPage({super.key, required this.quizId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentPage = 0;
  Map<String, int> _selectedAnswers = {};
  int _score = 0;
  int _timeRemaining = 0;
  Timer? _timer;
  bool _quizStarted = false;
  bool _isLoading = true;
  bool _hasError = false;
  Quiz? _quiz;

  @override
  void initState() {
    super.initState();
    fetchQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchQuiz() async {
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
        Uri.parse('${Constants.uri}/api/v1/quizzes/${widget.quizId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data);
        setState(() {
          _quiz = Quiz.fromJson(data['quiz']);
          _timeRemaining = _quiz!.timeLimit * 60; // Convert minutes to seconds
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print("Error fetching quiz: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer?.cancel();
        if (mounted) _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    if (!mounted) return;
    _calculateScore();
    setState(() {
      _currentPage = _quiz!.questions.length;
    });
  }

  void _goToNextPage() {
    if (!mounted) return;
    setState(() {
      if (_currentPage < _quiz!.questions.length - 1) {
        _currentPage++;
      }
    });
  }

  void _goToPreviousPage() {
    if (!mounted) return;
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  void _selectAnswer(String questionId, int answerIndex) {
    if (!mounted) return;
    setState(() {
      _selectedAnswers[questionId] = answerIndex;
    });
  }

  void _calculateScore() {
    if (_quiz == null) return;

    int totalScore = 0;
    for (var question in _quiz!.questions) {
      final selectedAnswerIndex = _selectedAnswers[question.id];
      if (selectedAnswerIndex != null) {
        if (question.answers[selectedAnswerIndex].isCorrect) {
          totalScore += question.points;
        }
      }
    }

    setState(() {
      _score = totalScore;
    });
  }

  void _submitQuiz() {
    _calculateScore();
    _autoSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    if (_isLoading) {
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
            "Loading Quiz...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily(),
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _quiz == null) {
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
            "Quiz Error",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily(),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              SizedBox(height: 16),
              Text(
                "Failed to load quiz",
                style: TextStyle(
                  fontSize: 20 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF6366F1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _quizStarted
        ? _buildQuizInterface(settings)
        : _buildQuizIntro(settings);
  }

  Widget _buildQuizIntro(AccessibilitySettings settings) {
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
          "Quiz Overview",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _quiz!.title,
                      style: TextStyle(
                        fontSize: 24 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily(),
                        color: Color(0XFF6366F1),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _quiz!.description,
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontFamily: fontFamily(),
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoCard(
                          "Questions",
                          "${_quiz!.questionCount}",
                          Icons.help_outline,
                          settings,
                          fontFamily(),
                        ),
                        _buildInfoCard(
                          "Time Limit",
                          "${_quiz!.timeLimit} min",
                          Icons.timer,
                          settings,
                          fontFamily(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoCard(
                          "Difficulty",
                          _quiz!.difficulty,
                          Icons.trending_up,
                          settings,
                          fontFamily(),
                        ),
                        _buildInfoCard(
                          "Passing Score",
                          "${_quiz!.passingScore}%",
                          Icons.check_circle_outline,
                          settings,
                          fontFamily(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Instructions",
                      style: TextStyle(
                        fontSize: 20 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInstructionItem(
                      "1",
                      "Read each question carefully before answering.",
                      settings,
                      fontFamily(),
                    ),
                    _buildInstructionItem(
                      "2",
                      "You can navigate between questions using the Previous and Next buttons.",
                      settings,
                      fontFamily(),
                    ),
                    _buildInstructionItem(
                      "3",
                      "Your answers are saved automatically.",
                      settings,
                      fontFamily(),
                    ),
                    _buildInstructionItem(
                      "4",
                      "The quiz will be submitted automatically when the time runs out.",
                      settings,
                      fontFamily(),
                    ),
                    _buildInstructionItem(
                      "5",
                      "You need ${_quiz!.passingScore}% to pass this quiz.",
                      settings,
                      fontFamily(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  setState(() {
                    _quizStarted = true;
                    _startTimer();
                  });
                },
                child: Text(
                  "Start Quiz",
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: Color(0XFF6366F1), size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14 * settings.fontSize,
                fontFamily: fontFamily,
                color: Colors.grey.shade700,
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
    );
  }

  Widget _buildInstructionItem(
    String number,
    String text,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color(0XFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInterface(AccessibilitySettings settings) {
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    final isQuizCompleted = _currentPage == _quiz!.questions.length;
    final isLastQuestion = _currentPage == _quiz!.questions.length - 1;
    print(isLastQuestion);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text(
                      "Exit Quiz?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily(),
                      ),
                    ),
                    content: Text(
                      "Are you sure you want to exit? Your progress will be lost.",
                      style: TextStyle(fontFamily: fontFamily()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontFamily: fontFamily()),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Exit quiz
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                        ),
                        child: Text(
                          "Exit",
                          style: TextStyle(fontFamily: fontFamily()),
                        ),
                      ),
                    ],
                  ),
            );
          },
        ),
        title: Text(
          isQuizCompleted
              ? "Quiz Results"
              : "Question ${_currentPage + 1}/${_quiz!.questions.length}",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
        actions: [
          if (!isQuizCompleted)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    color: _timeRemaining < 60 ? Colors.red : Colors.black,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!isQuizCompleted)
            LinearProgressIndicator(
              value: (_currentPage + 1) / _quiz!.questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0XFF6366F1)),
              minHeight: 4,
            ),
          Expanded(
            child:
                isQuizCompleted
                    ? _buildResultsScreen(settings)
                    : _buildQuestionScreen(settings),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(AccessibilitySettings settings) {
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    final question = _quiz!.questions[_currentPage];
    final isLastQuestion = _currentPage == _quiz!.questions.length - 1;
    final selectedAnswerIndex = _selectedAnswers[question.id];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(
                                  question.difficulty,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                question.difficulty,
                                style: TextStyle(
                                  fontSize: 12 * settings.fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily(),
                                  color: _getDifficultyColor(
                                    question.difficulty,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0XFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${question.points} points",
                                style: TextStyle(
                                  fontSize: 12 * settings.fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily(),
                                  color: Color(0XFF6366F1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          question.content,
                          style: TextStyle(
                            fontSize: 18 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (question.type == 'multiple-choice')
                  Column(
                    children:
                        question.answers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final answer = entry.value;
                          final isSelected = selectedAnswerIndex == index;

                          return GestureDetector(
                            onTap: () => _selectAnswer(question.id, index),
                            child: Card(
                              elevation: isSelected ? 4 : 1,
                              margin: EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? Color(0XFF6366F1)
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Color(0XFF6366F1)
                                                  : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        color:
                                            isSelected
                                                ? Color(0XFF6366F1)
                                                : Colors.transparent,
                                      ),
                                      child:
                                          isSelected
                                              ? Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        answer.content,
                                        style: TextStyle(
                                          fontSize: 16 * settings.fontSize,
                                          fontFamily: fontFamily(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  )
                else if (question.type == 'true-false')
                  Column(
                    children:
                        question.answers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final answer = entry.value;
                          final isSelected = selectedAnswerIndex == index;

                          return GestureDetector(
                            onTap: () => _selectAnswer(question.id, index),
                            child: Card(
                              elevation: isSelected ? 4 : 1,
                              margin: EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? Color(0XFF6366F1)
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Color(0XFF6366F1)
                                                  : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        color:
                                            isSelected
                                                ? Color(0XFF6366F1)
                                                : Colors.transparent,
                                      ),
                                      child:
                                          isSelected
                                              ? Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        answer.content,
                                        style: TextStyle(
                                          fontSize: 16 * settings.fontSize,
                                          fontFamily: fontFamily(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  )
                else if (question.type == 'fill-in-the-blank' ||
                    question.type == 'essay')
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.type == 'fill-in-the-blank'
                                ? "Enter your answer:"
                                : "Write your response:",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily(),
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            maxLines: question.type == 'essay' ? 5 : 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              hintText:
                                  question.type == 'fill-in-the-blank'
                                      ? "Type your answer here"
                                      : "Write your essay here",
                            ),
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade100,
                  disabledForegroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Previous",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed:
                    selectedAnswerIndex != null ||
                            question.type == 'essay' ||
                            question.type == 'fill-in-the-blank'
                        ? isLastQuestion
                            ? _submitQuiz
                            : _goToNextPage
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF6366F1),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isLastQuestion ? "Submit Quiz" : "Next",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen(AccessibilitySettings settings) {
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    final totalPoints = _quiz!.questions.fold(
      0,
      (sum, question) => sum + question.points,
    );
    final percentage = totalPoints > 0 ? (_score / totalPoints) * 100 : 0;
    final isPassed = percentage >= _quiz!.passingScore;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Quiz Completed!",
                    style: TextStyle(
                      fontSize: 24 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily(),
                      color: Color(0XFF6366F1),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPassed
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${percentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 28 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                                color:
                                    isPassed
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                              ),
                            ),
                            Text(
                              isPassed ? "Passed" : "Failed",
                              style: TextStyle(
                                fontSize: 16 * settings.fontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily(),
                                color:
                                    isPassed
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildResultInfoCard(
                        "Score",
                        "$_score / $totalPoints",
                        Icons.score,
                        settings,
                        fontFamily(),
                      ),
                      _buildResultInfoCard(
                        "Time Taken",
                        "${(_quiz!.timeLimit * 60 - _timeRemaining) ~/ 60} min ${(_quiz!.timeLimit * 60 - _timeRemaining) % 60} sec",
                        Icons.timer,
                        settings,
                        fontFamily(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Question Review",
            style: TextStyle(
              fontSize: 20 * settings.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily(),
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _quiz!.questions.length,
            itemBuilder: (context, index) {
              final question = _quiz!.questions[index];
              final selectedAnswerIndex = _selectedAnswers[question.id];

              bool isCorrect = false;
              if (selectedAnswerIndex != null &&
                  question.type != 'essay' &&
                  question.type != 'fill-in-the-blank') {
                isCorrect = question.answers[selectedAnswerIndex].isCorrect;
              }

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
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
                              shape: BoxShape.circle,
                              color:
                                  selectedAnswerIndex == null
                                      ? Colors.grey.shade400
                                      : isCorrect
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                            ),
                            child: Center(
                              child: Icon(
                                selectedAnswerIndex == null
                                    ? Icons.help_outline
                                    : isCorrect
                                    ? Icons.check
                                    : Icons.close,
                                size: 20,
                                color:
                                    selectedAnswerIndex == null
                                        ? Colors.grey.shade700
                                        : isCorrect
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
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
                                fontFamily: fontFamily(),
                              ),
                            ),
                          ),
                          Text(
                            "${question.points} pts",
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily(),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        question.content,
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontFamily: fontFamily(),
                        ),
                      ),
                      SizedBox(height: 12),
                      if (question.type != 'essay' &&
                          question.type != 'fill-in-the-blank') ...[
                        Text(
                          "Your Answer:",
                          style: TextStyle(
                            fontSize: 14 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          selectedAnswerIndex != null
                              ? question.answers[selectedAnswerIndex].content
                              : "Not answered",
                          style: TextStyle(
                            fontSize: 16 * settings.fontSize,
                            fontFamily: fontFamily(),
                            color:
                                selectedAnswerIndex == null
                                    ? Colors.grey.shade700
                                    : isCorrect
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (selectedAnswerIndex != null && !isCorrect) ...[
                          Text(
                            "Correct Answer:",
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily(),
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            question.answers
                                .firstWhere((a) => a.isCorrect)
                                .content,
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily(),
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ],
                      if (question.explanation.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Explanation:",
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily(),
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                question.explanation,
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontFamily: fontFamily(),
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Back to Quizzes",
                style: TextStyle(
                  fontSize: 18 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfoCard(
    String title,
    String value,
    IconData icon,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: Color(0XFF6366F1), size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14 * settings.fontSize,
                fontFamily: fontFamily,
                color: Colors.grey.shade700,
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
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'hard':
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }
}
