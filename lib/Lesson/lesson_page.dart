// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _currentPage = 0; // Tracks the current page of the learning content
  String? _selectedAnswer;
  bool _isAnswerSubmitted = false;

  // Example JSON data
  final Map<String, dynamic> _lessonData = {
    "title": "Photosynthesis",
    "subtitle": "Science - Chapter 4",
    "learningContent": [
      {
        "title": "What is Photosynthesis?",
        "content":
            "Photosynthesis is the process through which plants convert sunlight into chemical energy to produce their own food. It occurs mainly in the chloroplasts of plant cells, using sunlight, carbon dioxide, and water. Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test ",
        "image":
            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Photosynthesis_en.svg/1200px-Photosynthesis_en.svg.png",
      },
      {
        "title": "The Key Components",
        "content":
            "• Sunlight: Provides the energy required for the process.\n• Chlorophyll: The green pigment in plants that absorbs light.\n• Water: Absorbed by roots and transported to leaves.\n• Carbon Dioxide: Taken in through stomata in leaves.",
        "image": "",
      },
      {
        "title": "The Photosynthesis Equation",
        "content": "6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂\n\n"
            "• CO₂ = Carbon Dioxide\n• H₂O = Water\n• C₆H₁₂O₆ = Glucose\n• O₂ = Oxygen",
        "image": "",
      },
      {
        "title": "katty",
        "content": "meow",
        "image": ""
      }
    ],
    "quiz": {
      "question": "Where does photosynthesis primarily take place in plant cells?",
      "options": [
        {"text": "Cell wall", "isCorrect": false},
        {"text": "Chloroplasts", "isCorrect": true},
        {"text": "Mitochondria", "isCorrect": false},
        {"text": "Nucleus", "isCorrect": false},
      ],
    },
    "webResources": [
      "https://en.wikipedia.org/wiki/Photosynthesis",
      "https://www.khanacademy.org/science/biology/photosynthesis-in-plants",
    ],
  };

  void _goToNextPage() {
    setState(() {
      if (_currentPage < (_lessonData["learningContent"] as List).length - 1) {
        _currentPage++;
      }
    });
  }

  void _goToPreviousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  void _submitAnswer() {
    setState(() {
      _isAnswerSubmitted = true;

      // Find the correct option
      final correctOption = (_lessonData["quiz"]["options"] as List)
          .firstWhere((option) => option["isCorrect"] == true)["text"];

      // Check if the selected answer is correct
      if (_selectedAnswer == correctOption) {
        // Correct answer
        print("Correct!");
      } else {
        // Incorrect answer
        print("Incorrect!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final learningContent = _lessonData["learningContent"] as List;
    final quiz = _lessonData["quiz"] as Map<String, dynamic>;
    final webResources = _lessonData["webResources"] as List;

    // Find the correct option
    final correctOption = (quiz["options"] as List)
        .firstWhere((option) => option["isCorrect"] == true)["text"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _lessonData["title"],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lessonData["subtitle"],
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (_currentPage + 1) / learningContent.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              // Learning Content Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  height: 600, // Fixed height for the card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Title
                        Text(
                          learningContent[_currentPage]["title"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Scrollable Page Content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  learningContent[_currentPage]["content"] ?? "", // Fallback for null content
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Page Image (if available)
                                if (learningContent[_currentPage]["image"]?.isNotEmpty ?? false)
                                  Image.network(
                                    learningContent[_currentPage]["image"],
                                    fit: BoxFit.cover,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Navigation Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _goToPreviousPage,
                              icon: const Icon(Icons.arrow_back),
                              color: _currentPage > 0 ? Colors.blue : Colors.grey,
                            ),
                            Text(
                              'Page ${_currentPage + 1} of ${learningContent.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              onPressed: _goToNextPage,
                              icon: const Icon(Icons.arrow_forward),
                              color: _currentPage < learningContent.length - 1 ? Colors.blue : Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Quick Check Section
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
                          onPressed: _isAnswerSubmitted ? null : _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text(
                            'Submit',
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
                                ? 'Correct! Photosynthesis takes place in chloroplasts.'
                                : 'Incorrect!',
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
              const SizedBox(height: 20),
              // Web Resources Section
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
                        'Web Resources',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...webResources.map((url) {
                        return _buildWebResourceLink(url);
                      }),
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
      value: option, // Use the option text as the unique value
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

  Widget _buildWebResourceLink(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          print("Opening: $url");
        },
        child: Text(
          url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}