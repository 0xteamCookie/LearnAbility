import "package:flutter/material.dart";
import 'quiz_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const QuizPage(),
              ));
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 10),
          const Text(
            'Quizzes',
            style: TextStyle(fontSize: 34, color: Colors.black),
          ),
          const SizedBox(height: 10),
          const Text(
            'Test your knowledge with interactive quizzes',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuizCategory('Available'),
                _buildQuizCategory('Completed'),
                _buildQuizCategory('Results & Analytics'),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCategory(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
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
  }) {
    return Card(
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
                size: 100,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 15.0),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    topic,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    '$questions Questions',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    'Duration: $duration',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality for starting the quiz
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Start Quiz',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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