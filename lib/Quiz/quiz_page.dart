  import "package:flutter/material.dart";
  import "package:logger/logger.dart";
  import "package:provider/provider.dart";
  import "../accessibility_model.dart";
  import "dart:async";

  class QuizPage extends StatefulWidget {
    const QuizPage({super.key});

    @override
    State<QuizPage> createState() => _QuizPageState();
  }

  class _QuizPageState extends State<QuizPage> {
    int _currentPage = 0;
    String? _selectedAnswer;
    int _score = 0;
    List<String?> _userAnswers = []; // Initialize as empty
    final Logger logger = Logger();
    int _timeRemaining = 300; // 5 minutes timer
    late Timer _timer;

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

    @override
    void initState() {
      super.initState();
      _startTimer();
      // Initialize _userAnswers with null values for each question
      _userAnswers = List.filled((_quizData["quiz"] as List).length, null);
    }

    @override
    void dispose() {
      _timer.cancel();
      super.dispose();
    }

    void _startTimer() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeRemaining > 0) {
          setState(() {
            _timeRemaining--;
          });
        } else {
          _timer.cancel();
          _autoSubmit(); // Auto-submit when time is up
        }
      });
    }

    void _autoSubmit() {
      // Submit all unanswered questions as null
      for (int i = 0; i < _userAnswers.length; i++) {
        if (_userAnswers[i] == null) {
          _userAnswers[i] = null; // Mark as unanswered
        }
      }
      setState(() {
        _currentPage = (_quizData["quiz"] as List).length; // Move to score card
      });
      _submitAnswer();
}

    void _goToNextPage() {
      setState(() {
        if (_currentPage < (_quizData["quiz"] as List).length - 1) {
          _currentPage++;
          _selectedAnswer = _userAnswers[_currentPage]; // Safe access
        }
      });
    }

    void _goToPreviousPage() {
      setState(() {
        if (_currentPage > 0) {
          _currentPage--;
          _selectedAnswer = _userAnswers[_currentPage]; // Safe access
        }
      });
    }

    void _submitAnswer() {
      setState(() {
        final quiz = (_quizData["quiz"] as List)[_currentPage];
        final correctOption = (quiz["options"] as List)
            .firstWhere((option) => option["isCorrect"] == true)["text"];

        _userAnswers[_currentPage] = _selectedAnswer; // Update user's answer

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
        _score = 0; // Reset the score
        _userAnswers = List.filled((_quizData["quiz"] as List).length, null); // Reset answers
        _timeRemaining = 300; // Reset timer
        _startTimer(); // Restart timer
      });
    }

    @override
    Widget build(BuildContext context) {
      final settings = Provider.of<AccessibilitySettings>(context);
      final isQuizCompleted = _currentPage == (_quizData["quiz"] as List).length;
      final quiz = isQuizCompleted ? null : (_quizData["quiz"] as List)[_currentPage]; // Safe access
      final isLastQuestion = _currentPage == (_quizData["quiz"] as List).length - 1;

      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Back Button - Timer - Submit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 28, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 20 * settings.fontSize,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // PROGRESS BAR
              LinearProgressIndicator(
                value: (_currentPage + 1) / (_quizData["quiz"] as List).length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF2F2F2F)),
                minHeight: 6,
              ),
              const SizedBox(height: 40),

              // QUIZ CARD OR SCORE CARD
              isQuizCompleted
                ? _buildScoreCard(settings.fontSize) // Show score card at the end
                : Container(
                    constraints: BoxConstraints(minHeight: 700),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Container for Question Number, Question, and Options
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_currentPage + 1}.',
                                  style: TextStyle(
                                    fontSize: 28 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 5, 13, 100),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  quiz["question"],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22 * settings.fontSize,
                                    height: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 21),
                                Column(
                                  children: (quiz["options"] as List).map((option) {
                                    final index = (quiz["options"] as List).indexOf(option);
                                    final label = String.fromCharCode(65 + index); // A, B, C, D
                                    return _buildMCQOption(
                                      option["text"],
                                      settings.fontSize,
                                      label,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Container for Previous and Next Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    backgroundColor: const Color.fromARGB(204, 33, 75, 243),
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  ),
                                  child: Text(
                                    'Previous',
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_selectedAnswer != null) {
                                      _submitAnswer();
                                      if (!isLastQuestion) {
                                        _goToNextPage();
                                      } else {
                                        _autoSubmit(); // Submit and go to score card
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 33, 75, 243),
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    isLastQuestion ? 'Submit' : 'Next',
                                    style: TextStyle(
                                      fontSize: 16 * settings.fontSize,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      );


    }

    Widget _buildMCQOption(String option, double fontSize, String label) {
      bool isSelected = _selectedAnswer == option;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedAnswer = option;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(11),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromARGB(255, 0, 175, 91) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? const Color.fromARGB(255, 2, 78, 35) : Colors.grey,
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18 * fontSize,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 18 * fontSize,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildScoreCard(double fontSize) {
  final totalQuestions = (_quizData["quiz"] as List).length;
  final percentage = (_score / totalQuestions) * 100;

  return SingleChildScrollView(
    child: Column(
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
                    fontSize: 24 * fontSize,
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
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 7,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage >= 50 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24 * fontSize,
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
                    fontSize: 20 * fontSize,
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
        SizedBox(
          height: 400, // Set a fixed height or use MediaQuery to calculate dynamic height
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
                          fontSize: 18 * fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Answer: ${userAnswer ?? "Not answered"}',
                        style: TextStyle(
                          fontSize: 16 * fontSize,
                          color: userAnswer == correctOption ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Correct Answer: $correctOption',
                        style: TextStyle(
                          fontSize: 16 * fontSize,
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
                fontSize: 16 * fontSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
    
  }