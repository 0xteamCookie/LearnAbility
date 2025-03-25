import "package:flutter/material.dart";
import 'quiz_page.dart';
import 'package:provider/provider.dart';
import '../accessibility_model.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  final List<Map<String, dynamic>> _quizCards = [
    {
      "subject": "Biology",
      "topic": "Photosynthesis",
      "questions": "10",
      "duration": "15 minutes",
    },
    {
      "subject": "Mathematics",
      "topic": "Linear Equations",
      "questions": "12",
      "duration": "20 minutes",
    },
    {
      "subject": "Chemistry",
      "topic": "Periodic Table",
      "questions": "8",
      "duration": "10 minutes",
    },
    {
      "subject": "Physics",
      "topic": "Newton's Laws of Motion",
      "questions": "15",
      "duration": "25 minutes",
    },
    {
      "subject": "English",
      "topic": "Grammar and Punctuation",
      "questions": "10",
      "duration": "15 minutes",
    },
    {
      "subject": "Computer",
      "topic": "Programming Basics",
      "questions": "12",
      "duration": "20 minutes",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                IconButton(
                            icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                Text(
                    'Quizzes',
                    style: TextStyle(
                      fontSize: 30 * settings.fontSize, // Updated
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
            ),
              ],
            ),
            const SizedBox(height: 10),
            
            
            const SizedBox(height: 10),
      
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuizCategory('Available', settings.fontSize),
                  _buildQuizCategory('Completed', settings.fontSize),
                  _buildQuizCategory('Analytics', settings.fontSize),
                ],
              ),
            ),
            
      
            // List of Quiz Cards
            ListView.builder(
              shrinkWrap: true, // Allow ListView to shrink-wrap its content
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
              itemCount: _quizCards.length,
              itemBuilder: (context, index) {
                final quiz = _quizCards[index];
                return _buildQuizItem(
                  subject: quiz["subject"],
                  topic: quiz["topic"],
                  questions: quiz["questions"],
                  duration: quiz["duration"],
                  fontSize: settings.fontSize, // Pass fontSize
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCategory(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Color(0xFFD1C4E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16 * fontSize, // Updated
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizItem({
    required String subject,
    required String topic,
    required String questions,
    required String duration,
    required double fontSize, // Added fontSize parameter
  }) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: Icon(
                _getSubjectIcon(subject),
                size: 100 * fontSize, // Updated
                color: Colors.deepPurple.withAlpha(150),
              ),
            ),
            const SizedBox(width: 15.0),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 20 * fontSize, // Updated
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    topic,
                    style: TextStyle(
                      fontSize: 16 * fontSize, // Updated
                      color: const Color.fromARGB(223, 0, 0, 0),
                    ),
                  ),
                  Text(
                    '$questions Questions',
                    style: TextStyle(
                      fontSize: 14 * fontSize, // Updated
                      color: const Color.fromARGB(223, 0, 0, 0),
                    ),
                  ),
                  Text(
                    'Duration: $duration',
                    style: TextStyle(
                      fontSize: 14 * fontSize, // Updated
                      color: const Color.fromARGB(223, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.withAlpha(150),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      'Start Quiz',
                      style: TextStyle(
                        fontSize: 16 * fontSize, // Updated
                        color: Colors.white,
                      ),
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

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'biology':
        return Icons.eco;
      case 'mathematics':
        return Icons.calculate;
      case 'chemistry':
        return Icons.science;
      case 'computer':
        return Icons.computer;
      case 'english':
        return Icons.menu_book;
      case 'physics':
        return Icons.bolt;
      default:
        return Icons.book;
    }
  }
}