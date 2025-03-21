import "package:flutter/material.dart";
import "package:logger/logger.dart";
import 'package:provider/provider.dart';
import '../accessibility_model.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentPage = 0;
  String? _selectedAnswer;
  bool _isAnswerSubmitted = false;
  int _score = 0; // Track the user's score
  final List<String?> _userAnswers = []; // Track user's answers for each question

  final Logger logger = Logger();

  // EXAMPLE JSON DATA
  final Map<String, dynamic> _quizData = {
    "title": "Photosynthesis",
    "subtitle": "Science - Chapter 4",
    "quiz": [
      {
        "question": "Where does photosynthesis primarily take place in plant cells?",
        "image": "<url to some green leaf>",
        "options": [
          {"text": "Cell wall", "isCorrect": false},
          {"text": "Chloroplasts", "isCorrect": true},
          {"text": "Mitochondria", "isCorrect": false},
          {"text": "Nucleus", "isCorrect": false},
        ],
      },
      {
        "question": "What is the primary source of energy for photosynthesis?",
        "options": [
          {"text": "Water", "isCorrect": false},
          {"text": "Sunlight", "isCorrect": true},
          {"text": "Carbon dioxide", "isCorrect": false},
          {"text": "Oxygen", "isCorrect": false}
        ],
      },
      {
        "question": "Which gas is released as a byproduct of photosynthesis?",
        "options": [
          {"text": "Carbon dioxide", "isCorrect": false},
          {"text": "Nitrogen", "isCorrect": false},
          {"text": "Oxygen", "isCorrect": true},
          {"text": "Hydrogen", "isCorrect": false}
        ],
      },
      {
        "question": "Which of the following is NOT required for photosynthesis?",
        "options": [
          {"text": "Sunlight", "isCorrect": false},
          {"text": "Carbon dioxide", "isCorrect": false},
          {"text": "Water", "isCorrect": false},
          {"text": "Glucose", "isCorrect": true}
        ],
      },
    ],
  };

  void _goToNextPage() {
    setState(() {
      if (_currentPage < (_quizData["quiz"] as List).length - 1) {
        _currentPage++;
        _selectedAnswer = null;
        _isAnswerSubmitted = false;
      }
    });
  }

  void _submitAnswer() {
    setState(() {
      _isAnswerSubmitted = true;
      final quiz = (_quizData["quiz"] as List)[_currentPage];
      final correctOption = (quiz["options"] as List)
          .firstWhere((option) => option["isCorrect"] == true)["text"];

      _userAnswers.add(_selectedAnswer); // Save the user's answer

      if (_selectedAnswer == correctOption) {
        _score++; // Increment score if the answer is correct
        logger.d("Correct! Score: $_score");
      } else {
        logger.d("Incorrect!");
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentPage = 0;
      _selectedAnswer = null;
      _isAnswerSubmitted = false;
      _score = 0; // Reset the score
      _userAnswers.clear(); // Clear user's answers
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final quiz = (_quizData["quiz"] as List)[_currentPage];
    final correctOption = (quiz["options"] as List)
        .firstWhere((option) => option["isCorrect"] == true)["text"];
    final isLastQuestion = _currentPage == (_quizData["quiz"] as List).length - 1;

    return Scaffold(
      // TOP APPBAR
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24 * settings.fontSize, // Updated
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LESSON NAME
            Text(
              _quizData["title"],
              style: TextStyle(
                fontSize: 32.0 * settings.fontSize, // Updated
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // PROGRESS BAR
            LinearProgressIndicator(
              value: (_currentPage + 1) / (_quizData["quiz"] as List).length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),

            // QUIZ CARD OR SCORE CARD
            Expanded(
              child: isLastQuestion && _isAnswerSubmitted
                  ? _buildScoreCard(settings.fontSize) // Show score card at the end
                  : SingleChildScrollView(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Check',
                                style: TextStyle(
                                  fontSize: 24 * settings.fontSize, // Updated
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                quiz["question"],
                                style: TextStyle(
                                  fontSize: 18 * settings.fontSize, // Updated
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: (quiz["options"] as List).map((option) {
                                  return _buildMCQOption(
                                    option["text"],
                                    option["isCorrect"],
                                    settings.fontSize, // Pass fontSize
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!_isAnswerSubmitted && _selectedAnswer != null) {
                                      _submitAnswer(); // Submit the answer
                                    } else if (_isAnswerSubmitted) {
                                      _goToNextPage(); // Go to the next question
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  ),
                                  child: Text(
                                    _isAnswerSubmitted
                                        ? (isLastQuestion ? 'Finish' : 'Next')
                                        : 'Submit',
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize, // Updated
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (_isAnswerSubmitted)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    _selectedAnswer == correctOption
                                        ? 'Good Job! You\'re correct!!'
                                        : 'Incorrect! The correct answer is $correctOption.',
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize, // Updated
                                      color: _selectedAnswer == correctOption ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQOption(String option, bool isCorrect, double fontSize) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: TextStyle(
          fontSize: 16 * fontSize, // Updated
        ),
      ),
      value: option,
      groupValue: _selectedAnswer,
      onChanged: _isAnswerSubmitted
          ? null
          : (String? newValue) {
              setState(() {
                _selectedAnswer = newValue;
              });
            },
    );
  }

  Widget _buildScoreCard(double fontSize) {
    final totalQuestions = (_quizData["quiz"] as List).length;
    final percentage = (_score / totalQuestions) * 100;

    return Column(
      children: [
        // Pie Chart and Score Summary
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 24 * fontSize, // Updated
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 150,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 7,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage >= 50 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24 * fontSize, // Updated
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Score: $_score / $totalQuestions',
                  style: TextStyle(
                    fontSize: 20 * fontSize, // Updated
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Scrollable List of MCQ Questions
        Expanded(
          child: ListView.builder(
            itemCount: totalQuestions,
            itemBuilder: (context, index) {
              final quiz = (_quizData["quiz"] as List)[index];
              final correctOption = (quiz["options"] as List)
                  .firstWhere((option) => option["isCorrect"] == true)["text"];
              final userAnswer = _userAnswers[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz["question"],
                        style: TextStyle(
                          fontSize: 18 * fontSize, // Updated
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Answer: ${userAnswer ?? "Not answered"}',
                        style: TextStyle(
                          fontSize: 16 * fontSize, // Updated
                          color: userAnswer == correctOption ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Correct Answer: $correctOption',
                        style: TextStyle(
                          fontSize: 16 * fontSize, // Updated
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Restart Quiz Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _resetQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Restart Quiz',
              style: TextStyle(
                fontSize: 16 * fontSize, // Updated
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}