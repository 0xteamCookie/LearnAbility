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
  List<String?> _userAnswers = [];
  final Logger logger = Logger();
  int _timeRemaining = 300;
  Timer _timer = Timer(Duration.zero, () {});
  bool _quizStarted = false;

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
    _userAnswers = List.filled((_quizData["quiz"] as List).length, null);
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer.cancel();
        if (mounted) _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    if (!mounted) return;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i] == null) {
        _userAnswers[i] = null;
      }
    }
    setState(() {
      _currentPage = (_quizData["quiz"] as List).length;
    });
  }

  void _goToNextPage() {
    if (!mounted) return;
    setState(() {
      if (_currentPage < (_quizData["quiz"] as List).length - 1) {
        _currentPage++;
        _selectedAnswer = _userAnswers[_currentPage];
      }
    });
  }

  void _goToPreviousPage() {
    if (!mounted) return;
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
        _selectedAnswer = _userAnswers[_currentPage];
      }
    });
  }

  void _submitAnswer() {
    if (!mounted) return;
    setState(() {
      if (_currentPage < (_quizData["quiz"] as List).length) {
        final quiz = (_quizData["quiz"] as List)[_currentPage];
        final correctOption = (quiz["options"] as List)
            .firstWhere((option) => option["isCorrect"] == true)["text"];

        _userAnswers[_currentPage] = _selectedAnswer;

        if (_selectedAnswer == correctOption) {
          _score++;
          logger.d("Correct! Score: $_score");
        } else {
          logger.d("Incorrect!");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    return _quizStarted ? _buildQuizInterface(settings.fontSize) : _buildQuizIntro(settings.fontSize);
  }

  Widget _buildQuizIntro(double fontSize) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                      onPressed: () {
                        _timer.cancel();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 40),
            Card(
              color: Colors.grey[100],
              elevation: 4,
              margin: EdgeInsets.only(top: 35.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Photosynthesis Quiz',
                        style: TextStyle(
                          fontSize: 24 * fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoCard('Questions', '${(_quizData["quiz"] as List).length}', fontSize),
                        _buildInfoCard('Time Limit', '5 minutes', fontSize),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 20 * fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Column(
                      children: [
                        _buildInstructionItem('1', 'Read each question carefully before answering', fontSize),
                        _buildInstructionItem('2', 'You can navigate between questions using the Previous and Next buttons', fontSize),
                        _buildInstructionItem('3', 'Your answers are saved automatically', fontSize),
                        _buildInstructionItem('4', 'You can review your answers before submitting the quiz', fontSize),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _quizStarted = true;
                            _startTimer();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Start Quiz',
                          style: TextStyle(
                            fontSize: 18 * fontSize,
                            color: Colors.white,
                          ),
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
    );
  }

  Widget _buildInfoCard(String title, String value, double fontSize) {
    return Card(
      color: Color(0xFFD1C4E9), 
      
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        color: Colors.grey[300],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
                    radius: 15,
                    child: Icon(
                      Icons.timer,
                      color: Colors.black,
                      size: 22,
        
                    ),
                  ),
              SizedBox(width:10),
              Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14 * fontSize,
                      color: const Color.fromARGB(201, 0, 0, 0),
                     
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16 * fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30 * fontSize,
            height: 30 * fontSize,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16 * fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInterface(double fontSize) {
    final isQuizCompleted = _currentPage == (_quizData["quiz"] as List).length;
    final quiz = isQuizCompleted ? null : (_quizData["quiz"] as List)[_currentPage];
    final isLastQuestion = _currentPage == (_quizData["quiz"] as List).length - 1;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                  onPressed: () {
                    _timer.cancel();
                    Navigator.pop(context);
                  },
                ),
                Text(
                  '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 20 * fontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (_currentPage + 1) / (_quizData["quiz"] as List).length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              minHeight: 6,
            ),
            const SizedBox(height: 40),
            isQuizCompleted
                ? _buildScoreCard(fontSize)
                : Container(
                    constraints: const BoxConstraints(minHeight: 700),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_currentPage + 1}.',
                                  style: TextStyle(
                                    fontSize: 28 * fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 5, 13, 100),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  quiz!["question"],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22 * fontSize,
                                    height: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 21),
                                Column(
                                  children: (quiz["options"] as List).map((option) {
                                    final index = (quiz["options"] as List).indexOf(option);
                                    final label = String.fromCharCode(65 + index);
                                    return _buildMCQOption(
                                      option["text"],
                                      fontSize,
                                      label,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    backgroundColor: Colors.deepPurple,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  ),
                                  child: Text(  
                                    'Previous',
                                    style: TextStyle(
                                      fontSize: 16 * fontSize,
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
                                        _autoSubmit();
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    isLastQuestion ? 'Submit' : 'Next',
                                    style: TextStyle(
                                      fontSize: 16 * fontSize,
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
        if (!mounted) return;
        setState(() {
          _selectedAnswer = option;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(11),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(0, 0, 175, 90) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            width: 2,
            color: isSelected ? Colors.deepPurple : Colors.grey,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18 * fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 18 * fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
          SizedBox(
            height: 400,
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
        ],
      ),
    );
  }
}