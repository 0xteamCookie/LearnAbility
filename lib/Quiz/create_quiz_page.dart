import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/domain/constants/appcolors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/accessibility_model.dart';
import 'package:my_first_app/utils/constants.dart';

class Subject {
  final String id;
  final String name;
  final String color;

  Subject({required this.id, required this.name, required this.color});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      color: json['color'] ?? 'blue',
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String subjectId;

  Lesson({required this.id, required this.title, required this.subjectId});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      subjectId: json['subjectId'],
    );
  }
}

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();

  List<Subject> _subjects = [];
  List<Lesson> _lessons = [];

  String? _selectedSubjectId;
  String? _selectedLessonId;
  String _selectedDifficulty = 'Medium';
  int _questionCount = 5;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;
  bool _isCreating = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchSubjects() async {
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
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Subjects: $data");
        setState(() {
          _subjects =
              (data['subjects'] as List)
                  .map((json) => Subject.fromJson(json))
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> fetchLessons(String subjectId) async {
    setState(() {
      _lessons = [];
      _selectedLessonId = null;
      _isLoading = true;
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
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects/$subjectId/lessons'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("Lessons: $data");
        setState(() {
          _lessons =
              (data['lessons'] as List)
                  .map((json) => Lesson.fromJson(json))
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print("Error fetching lessons: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> createQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        _isCreating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication error. Please log in again.")),
      );
      return;
    }

    try {
      final Map<String, dynamic> requestBody = {
        "subjectId": _selectedSubjectId,
        "lessonId": _selectedLessonId,
        "difficulty": _selectedDifficulty,
        "questionCount": _questionCount,
        "title": _titleController.text,
        "description": _descriptionController.text,
        "saveToDb": true,
      };

      final response = await http.post(
        Uri.parse('${Constants.uri}/api/v1/quizzes/generate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("Create Quiz Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Quiz created successfully!")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create quiz. Please try again.")),
        );
        setState(() {
          _isCreating = false;
        });
      }
    } catch (e) {
      print("Error creating quiz: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creating quiz: $e")));
      setState(() {
        _isCreating = false;
      });
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
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create Quiz",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? _buildErrorState(settings, fontFamily())
              : _buildForm(settings, fontFamily()),
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
              "Failed to load data",
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "There was a problem loading the required data. Please try again.",
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
              onPressed: fetchSubjects,
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

  Widget _buildForm(AccessibilitySettings settings, String fontFamily) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quiz Details",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            SizedBox(height: 24),
            Text(
              "Subject and Lesson",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.subject),
              ),
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
                color: Colors.black,
              ),
              value: _selectedSubjectId,
              items:
                  _subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject.id,
                      child: Text(subject.name),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubjectId = value;
                  if (value != null) {
                    fetchLessons(value);
                  }
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a subject";
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Lesson",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.book),
              ),
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
                color: Colors.black,
              ),
              value: _selectedLessonId,
              items:
                  _lessons.map((lesson) {
                    return DropdownMenuItem<String>(
                      value: lesson.id,
                      child: Text(lesson.title),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLessonId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a lesson";
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            Text(
              "Quiz Settings",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Difficulty",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.trending_up),
              ),
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
                color: Colors.black,
              ),
              value: _selectedDifficulty,
              items:
                  ["Easy", "Medium", "Hard"].map((difficulty) {
                    return DropdownMenuItem<String>(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Number of Questions: $_questionCount",
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed:
                      _questionCount > 1
                          ? () {
                            setState(() {
                              _questionCount--;
                            });
                          }
                          : null,
                ),
                Text(
                  "$_questionCount",
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed:
                      _questionCount < 20
                          ? () {
                            setState(() {
                              _questionCount++;
                            });
                          }
                          : null,
                ),
              ],
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
                onPressed: _isCreating ? null : createQuiz,
                child:
                    _isCreating
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          "Create Quiz",
                          style: TextStyle(
                            fontSize: 18 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
