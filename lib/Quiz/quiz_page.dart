import "package:flutter/material.dart";
import "package:logger/logger.dart";

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
  List<String?> _userAnswers = []; // Track user's answers for each question

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
    final quiz = (_quizData["quiz"] as List)[_currentPage];
    final correctOption = (quiz["options"] as List)
        .firstWhere((option) => option["isCorrect"] == true)["text"];
    final isLastQuestion = _currentPage == (_quizData["quiz"] as List).length - 1;

    return Scaffold(
      // TOP APPBAR
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white),
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
              style: const TextStyle(
                fontSize: 32.0,
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
                  ? _buildScoreCard() // Show score card at the end
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
                              const Text(
                                'Quick Check',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                quiz["question"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: (quiz["options"] as List).map((option) {
                                  return _buildMCQOption(
                                    option["text"],
                                    option["isCorrect"],
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
                                    style: const TextStyle(
                                      fontSize: 16,
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
                                      fontSize: 16,
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

  Widget _buildMCQOption(String option, bool isCorrect) {
    return RadioListTile<String>(
      title: Text(
        option,
        style: const TextStyle(
          fontSize: 16,
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

  Widget _buildScoreCard() {
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
                const Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 24,
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Score: $_score / $totalQuestions',
                  style: const TextStyle(
                    fontSize: 20,
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Answer: ${userAnswer ?? "Not answered"}',
                        style: TextStyle(
                          fontSize: 16,
                          color: userAnswer == correctOption ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Correct Answer: $correctOption',
                        style: const TextStyle(
                          fontSize: 16,
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
            child: const Text(
              'Restart Quiz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}