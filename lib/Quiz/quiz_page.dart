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

  final Logger logger = Logger();

  //EXAMPLE JSON DATA
  final Map<String, dynamic> _quizData = {
    "title" : "Photosynthesis",
    "subtitle": "Science - Chapter 4",
    "quiz": [
      {
        "question": "Where does photosynthesis primarily take place in plant cells?",
        "image" : "<url to some green leaf>",
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

      if (_selectedAnswer == correctOption) {
        logger.d("Correct!");
      } else {
        logger.d("Incorrect!");
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final quiz = (_quizData["quiz"] as List)[_currentPage];

    final correctOption = (quiz["options"] as List)
        .firstWhere((option) => option["isCorrect"] == true)["text"];
    
    final isLastQuestion = _currentPage == (_quizData["quiz"] as List).length - 1;

    return Scaffold(

      //TOP APPBAR
      appBar: AppBar(
          backgroundColor: Colors.blue,

          //APP NAME
          title: Text(
            "LearnAbility",
              style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
          ),
        ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //LESSON NAME
              Text(
                _quizData["title"],
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 16),

              //PROGRESS BAR
              LinearProgressIndicator(
                value: (_currentPage + 1) / (_quizData["quiz"] as List).length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 20),

              //QUIZ CARD
              Card(
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
                              _submitAnswer();
                            } else if (_isAnswerSubmitted) {
                              _goToNextPage();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            _isAnswerSubmitted
                            ? (isLastQuestion ? "Finish" : "Next")
                             : 'Submit',
                            style: TextStyle(
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
            ],
          ),
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
              },);
            },
    );
  }

}