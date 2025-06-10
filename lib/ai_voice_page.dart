import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_first_app/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:vapinew/vapinew.dart';
import 'accessibility_model.dart';
import 'domain/constants/appcolors.dart';

// Imports for additional pages and utilities
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/utils/constants.dart'; 
import 'package:my_first_app/repository/screens/login/loginscreen.dart';
import 'package:my_first_app/repository/screens/signup/signupscreen.dart';
import 'package:my_first_app/home_page.dart'; // For HomePage itself
import 'package:my_first_app/stats_page.dart';
import 'package:my_first_app/accessibility_page.dart';
import 'package:my_first_app/subjects.dart'; // SubjectsPage
import 'package:my_first_app/generate_content_page.dart'; // GenerateContentPage (My Materials)
import 'package:my_first_app/Quiz/quizzes_page.dart'; // QuizzesPage
import 'package:my_first_app/ai_assistant_page.dart'; // AIAssistantPage
import 'package:my_first_app/videos_page.dart';
import 'package:my_first_app/articles_page.dart';
import 'package:my_first_app/profile_page.dart';
import 'package:my_first_app/Lesson/lesson_page.dart'; // For LessonContentPage
import 'package:my_first_app/Lesson/lessons_page.dart'; // For LessonsPage

// ignore: constant_identifier_names
const VAPI_PUBLIC_KEY = '012585dc-1191-46c5-abe6-8daf08aa841d';

// Duplicated NextLesson class definition from home_page.dart for simplicity
class NextLesson {
  final String id;
  final String title;
  final String subjectName;
  final String subjectId;
  final String? description;
  final String? duration;
  final String? level;
  final int? progress;

  NextLesson({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.subjectId,
    this.description,
    this.duration,
    this.level,
    this.progress,
  });
}

void main() {
  runApp(const VoiceAiChat());
}

class VoiceAiChat extends StatefulWidget {
  const VoiceAiChat({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VoiceAiChatState createState() => _VoiceAiChatState();
}

class _VoiceAiChatState extends State<VoiceAiChat> {
  String buttonText = 'Start Talking';
  bool isLoading = false;
  bool isCallStarted = false;
  final Vapi vapi = Vapi(VAPI_PUBLIC_KEY);
  final List<Map<String, dynamic>> _chatHistory = [];

  final Map<String, Widget Function(BuildContext)> routeMap = {
    "/settings": (context) => SettingsPage(),
    // Adding new routes
    "/login": (context) => LoginScreen(),
    "/signup": (context) => SignupScreen(),
    "/home": (context) => HomePage(),
    "/stats": (context) => StatsPage(),
    "/progress": (context) => StatsPage(), // Alias for stats
    "/accessibility": (context) => AccessibilityPage(),
    "/subjects": (context) => SubjectsPage(),
    "/courses": (context) => SubjectsPage(), // Alias for subjects
    "/materials": (context) => GenerateContentPage(),
    "/my-materials": (context) => GenerateContentPage(), // Alias for materials
    "/quizzes": (context) => QuizzesPage(),
    "/ai-assistant": (context) => AIAssistantPage(),
    "/chat-assistant": (context) => AIAssistantPage(), // Alias for ai-assistant
    "/voice-assistant": (context) => VoiceAiChat(), // Current page
    "/videos": (context) => VideosPage(),
    "/articles": (context) => ArticlesPage(),
    "/profile": (context) => ProfilePage(),
    // LessonContentPage will be handled via _navigateToNextLesson or specific lesson IDs if ever needed
  };

  _VoiceAiChatState() {
    vapi.onEvent.listen((event) {
      try {
        final Map<String, dynamic> messageData = jsonDecode(event.value);

        print(messageData);

        if (messageData["status"] == "ended") {
        setState(() {
          final settings = Provider.of<AccessibilitySettings>(context, listen: false);
          isCallStarted = false;
          settings.setCallStatus(false);   //passing props to lesson page
          buttonText = 'Start Talking';
          isLoading = false;
        });
        return;
      }

        if (messageData["type"] == "transcript" &&
            messageData["transcriptType"] == "final") {
          setState(() {
            _chatHistory.add({
              'role': messageData["role"],
              'message': messageData["transcript"],
            });
          });
        }

        if (messageData['type'] == 'tool-calls') {
          final dynamic toolCalls = messageData['toolCalls'];
          if (toolCalls is List && toolCalls.isNotEmpty) {
            final dynamic firstToolCall = toolCalls[0];
            if (firstToolCall is Map &&
                firstToolCall['type'] == 'function') {
              final dynamic functionCallDetails = firstToolCall['function'];
              if (functionCallDetails is Map) {
                final String functionName = functionCallDetails['name'] as String;
                final dynamic arguments = functionCallDetails['arguments'];

                if (functionName == 'navigate' && arguments is Map && arguments['path'] is String) {
                  final String path = arguments['path'] as String;
                  print('Navigating via tool-call to path: $path');
                  _navigateToPage(path);
                } else if (functionName == 'navigateToSubjectLessons' && arguments is Map && arguments['subjectName'] is String) {
                  final String subjectName = arguments['subjectName'] as String;
                  print('Navigating via tool-call to lessons for subject: $subjectName');
                  _handleNavigateToSubjectLessons(subjectName);
                } else if (functionName == 'navigateToLessonContent' && arguments is Map && arguments['lessonName'] is String) {
                  final String lessonName = arguments['lessonName'] as String;
                  final String? subjectName = arguments['subjectName'] as String?;
                  print('Navigating via tool-call to lesson content: $lessonName in subject: $subjectName');
                  _handleNavigateToLessonContent(lessonName, subjectName);
                }
              }
            }
          }
        }
      } catch (e) {
        print("Error decoding event data: $e");
      }
    });
  }

  Future<void> _handleMicPress() async {
    setState(() {
      isLoading = true;
      buttonText = isCallStarted ? 'Ending Call...' : 'Starting Call...';
    });

    if (!isCallStarted) {
      // Fetch dynamic data for the prompt
      String dynamicPromptInfo = await _getDynamicPromptData();

      final assistantConfig = {
        "name": "miss-williams",
        "model": {
          "provider": "openai",
          "model": "gpt-3.5-turbo",
          "temperature": 0.7,
          "systemPrompt":
              "You are Miss Williams, a knowledgeable and friendly teacher. Your primary role is to help users navigate the LearnAbility app using voice commands. \\n" +
              "1. Use the 'navigate' function for general page navigation (e.g., '/home', '/settings'). \\n" +
              "2. If the user asks to 'continue learning' or 'open next lesson', use the path '/lesson/next' with the 'navigate' function. \\n" +
              "3. To show lessons for a specific subject (e.g., 'Show lessons for Mathematics'), use the 'navigateToSubjectLessons' function with the 'subjectName'. \\n" +
              "4. To open a specific lesson's content (e.g., 'Open Introduction to Algebra in Mathematics'), use the 'navigateToLessonContent' function with 'lessonName' and 'subjectName'. If subjectName is not provided for a lesson, ask for it, or use the subject context if a subject's lessons are already being viewed. \\n" +
              "Be clear and confirm actions if a request is ambiguous. \\n" +
              "Available general page paths: /home, /settings, /profile, /stats (or /progress), /accessibility, /subjects (or /courses), /materials (or /my-materials), /quizzes, /ai-assistant (or /chat-assistant), /voice-assistant, /videos, /articles.\\n" +
              "IMPORTANT: Use the following list of available subjects and lessons to guide the user and confirm names. If a user mentions a subject or lesson not in this list, inform them it's not available or ask for clarification.\\n" +
              dynamicPromptInfo, // Appended dynamic data
          "functions": [
            {
              "name": "navigate",
              "async": true,
              "description": "Navigate to a general predefined page path in the app or to the next lesson.",
              "parameters": {
                "type": "object",
                "properties": {
                  "path": {
                    "type": "string",
                    "description":
                        "The predefined route path (e.g., '/home', '/settings') or '/lesson/next' for the next lesson.",
                  },
                },
                "required": ["path"],
              },
            },
            {
              "name": "navigateToSubjectLessons",
              "async": true,
              "description": "Navigate to the list of lessons for a specific subject.",
              "parameters": {
                "type": "object",
                "properties": {
                  "subjectName": {
                    "type": "string",
                    "description": "The name of the subject to show lessons for (e.g., 'Mathematics', 'Science').",
                  },
                },
                "required": ["subjectName"],
              },
            },
            {
              "name": "navigateToLessonContent",
              "async": true,
              "description": "Navigate to the content page of a specific lesson within a subject.",
              "parameters": {
                "type": "object",
                "properties": {
                  "lessonName": {
                    "type": "string",
                    "description": "The name/title of the lesson to open (e.g., 'Introduction to Algebra', 'Cell Structure').",
                  },
                  "subjectName": {
                    "type": "string",
                    "description": "The name of the subject that the lesson belongs to (e.g., 'Mathematics', 'Biology'). This helps disambiguate if lesson names are similar across subjects.",
                  },
                },
                "required": ["lessonName", "subjectName"],
              },
            }
          ],
          "tools":[
            {
              "type": "endCall"
            }
          ]
        },
        "voice": {"provider": "11labs", "voiceId": "paula"},
        "firstMessage":
            "Hello! I'm Miss Williams. Ask me anything—I'm here to help! You can ask me to navigate to pages like home, settings, or your subjects.",
        "serverUrl": "https://08ae-202-43-120-244.ngrok-free.app/api/webhook",
      };

      await vapi.start(assistant: assistantConfig);
    } else {
      print("Ending AI Voice Assistant...");
      await vapi.stop();
    }
  }

  Future<String> _getDynamicPromptData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      return "User not logged in, so subject and lesson data is unavailable.\n";
    }

    StringBuffer promptData = StringBuffer("Current Subjects and Lessons:\n");
    bool dataFetched = false;

    try {
      // Fetch Subjects
      final subjectsResponse = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (subjectsResponse.statusCode == 200) {
        final Map<String, dynamic> subjectsData = jsonDecode(subjectsResponse.body);
        final List allSubjects = subjectsData['subjects'];

        if (allSubjects.isEmpty) {
          promptData.writeln("No subjects found for the user.\n");
        } else {
          dataFetched = true;
          for (var subject in allSubjects) {
            String subjectId = subject['id'];
            String subjectName = subject['name'];
            promptData.writeln("- Subject: $subjectName");

            // Fetch Lessons for this Subject
            try {
              final lessonsResponse = await http.get(
                Uri.parse('${Constants.uri}/api/v1/pyos/subjects/$subjectId/lessons'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
              if (lessonsResponse.statusCode == 200) {
                final Map<String, dynamic> lessonsData = jsonDecode(lessonsResponse.body);
                final List subjectLessons = lessonsData['lessons'];
                if (subjectLessons.isNotEmpty) {
                  for (var lesson in subjectLessons) {
                    String lessonTitle = lesson['title'];
                    promptData.writeln("  - Lesson: $lessonTitle");
                  }
                } else {
                  promptData.writeln("    (No lessons found for this subject)");
                }
              } else {
                promptData.writeln("    (Could not fetch lessons for this subject: Error ${lessonsResponse.statusCode})");
              }
            } catch (e) {
              promptData.writeln("    (Error fetching lessons for this subject: $e)");
            }
          }
           promptData.writeln(); // Add a newline at the end of the list
        }
      } else {
        promptData.writeln("Could not fetch subjects: Error ${subjectsResponse.statusCode}\n");
      }
    } catch (e) {
      promptData.writeln("Error fetching dynamic prompt data: $e\n");
    }
    if (!dataFetched && promptData.length == StringBuffer("Current Subjects and Lessons:\n").length){
        // This means no subjects were found or an initial error occurred before any subject processing
        return "Could not retrieve a list of subjects and lessons at this time.\n";
    }
    return promptData.toString();
  }

  void _navigateToPage(String path) {
    if (path == "/lesson/next") {
      _navigateToNextLesson();
      return;
    }
    final navigateTo = routeMap[path];

    if (navigateTo != null) {
      Navigator.push(context, MaterialPageRoute(builder: navigateTo));
    } else {
      print("Unknown route: $path");
      // Optionally, provide feedback to the user if a route is unknown via chat
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'message': "I'm sorry, I couldn't find the page: $path",
        });
      });
    }
  }

  Future<void> _navigateToNextLesson() async {
    // This logic is inspired by HomePage._fetchNextLesson()
    // Ensure you have internet permission and necessary dependencies (http, shared_preferences)
    // Also ensure Constants.uri is correctly defined in your project
    setState(() {
      isLoading = true; // Show loading indicator if you have one for navigation
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      print("Error: JWT token not found. Cannot fetch next lesson.");
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'message': "I couldn't fetch your next lesson because you're not logged in.",
        });
        isLoading = false;
      });
      return;
    }

    try {
      // First fetch subjects
      final subjectsResponse = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (subjectsResponse.statusCode == 200) {
        final Map<String, dynamic> subjectsData = jsonDecode(subjectsResponse.body);
        final List subjects = subjectsData['subjects'];

        if (subjects.isNotEmpty) {
          // Get the first subject for simplicity, or implement more sophisticated logic
          final subject = subjects[0];
          final String subjectId = subject['id'];
          // final String subjectName = subject['name']; // Not needed directly for NextLesson constructor here

          // Fetch lessons for this subject
          final lessonsResponse = await http.get(
            Uri.parse('${Constants.uri}/api/v1/pyos/subjects/$subjectId/lessons'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (lessonsResponse.statusCode == 200) {
            final Map<String, dynamic> lessonsData = jsonDecode(lessonsResponse.body);
            final List lessons = lessonsData['lessons'];

            if (lessons.isNotEmpty) {
              // Get the first lesson as the "next lesson"
              final lesson = lessons[0];
              final nextLesson = NextLesson(
                id: lesson['id'],
                title: lesson['title'],
                subjectName: subject['name'], // Use fetched subjectName
                subjectId: subjectId,
                description: lesson['description'],
                duration: lesson['duration'],
                level: lesson['level'] ?? 'Beginner',
                progress: lesson['progress'] ?? 0,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonContentPage(
                    lessonId: nextLesson.id,
                    subjectId: nextLesson.subjectId,
                  ),
                ),
              );
            } else {
              print("No lessons found for subject $subjectId");
               setState(() {
                _chatHistory.add({
                  'role': 'assistant',
                  'message': "I couldn't find any lessons for your first subject.",
                });
              });
            }
          } else {
            print("Failed to fetch lessons: ${lessonsResponse.statusCode}");
             setState(() {
                _chatHistory.add({
                  'role': 'assistant',
                  'message': "I had trouble fetching your lessons. Please try again.",
                });
              });
          }
        } else {
          print("No subjects found.");
           setState(() {
            _chatHistory.add({
              'role': 'assistant',
              'message': "You don't seem to have any subjects. Please add some first.",
            });
          });
        }
      } else {
        print("Failed to fetch subjects: ${subjectsResponse.statusCode}");
        setState(() {
          _chatHistory.add({
            'role': 'assistant',
            'message': "I had trouble fetching your subjects. Please try again.",
          });
        });
      }
    } catch (e) {
      print("Error fetching next lesson: $e");
       setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'message': "An error occurred while trying to find your next lesson.",
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleNavigateToSubjectLessons(String subjectName) async {
    setState(() { isLoading = true; });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      _showError("You need to be logged in to view subject lessons.");
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
        final List allSubjects = data['subjects'];
        final foundSubject = allSubjects.firstWhere(
          (s) => (s['name'] as String).toLowerCase() == subjectName.toLowerCase(),
          orElse: () => null,
        );

        if (foundSubject != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonsPage(
                subjectId: foundSubject['id'],
                subjectName: foundSubject['name'],
              ),
            ),
          );
        } else {
          _showError("I couldn't find a subject named '$subjectName'.");
        }
      } else {
        _showError("Failed to fetch subjects. Please try again.");
      }
    } catch (e) {
      print("Error in _handleNavigateToSubjectLessons: $e");
      _showError("An error occurred while trying to find subjects.");
    } finally {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _handleNavigateToLessonContent(String lessonName, String? subjectName) async {
    setState(() { isLoading = true; });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      _showError("You need to be logged in to view lesson content.");
      return;
    }

    if (subjectName == null || subjectName.isEmpty) {
        _showError("Please specify which subject the lesson '$lessonName' belongs to.");
        setState(() { isLoading = false; });
        return;
    }

    try {
      // 1. Find Subject ID from subjectName
      final subjectsResponse = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      String? targetSubjectId;
      String? actualSubjectName;

      if (subjectsResponse.statusCode == 200) {
        final Map<String, dynamic> subjectsData = jsonDecode(subjectsResponse.body);
        final List allSubjects = subjectsData['subjects'];
        final foundSubject = allSubjects.firstWhere(
          (s) => (s['name'] as String).toLowerCase() == subjectName.toLowerCase(),
          orElse: () => null,
        );
        if (foundSubject != null) {
          targetSubjectId = foundSubject['id'];
          actualSubjectName = foundSubject['name'];
        } else {
          _showError("I couldn't find the subject '$subjectName'.");
          setState(() { isLoading = false; });
          return;
        }
      } else {
        _showError("Failed to fetch subjects to find '$subjectName'.");
        setState(() { isLoading = false; });
        return;
      }

      // 2. Fetch lessons for that subjectId
      final lessonsResponse = await http.get(
        Uri.parse('${Constants.uri}/api/v1/pyos/subjects/$targetSubjectId/lessons'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (lessonsResponse.statusCode == 200) {
        final Map<String, dynamic> lessonsData = jsonDecode(lessonsResponse.body);
        final List subjectLessons = lessonsData['lessons'];
        final foundLesson = subjectLessons.firstWhere(
          (l) => (l['title'] as String).toLowerCase() == lessonName.toLowerCase(),
          orElse: () => null,
        );

        if (foundLesson != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonContentPage(
                lessonId: foundLesson['id'],
                subjectId: targetSubjectId!, // Already confirmed targetSubjectId is not null
              ),
            ),
          );
        } else {
          _showError("I couldn't find a lesson named '$lessonName' in the subject '$actualSubjectName'.");
        }
      } else {
        _showError("Failed to fetch lessons for the subject '$actualSubjectName'.");
      }
    } catch (e) {
      print("Error in _handleNavigateToLessonContent: $e");
      _showError("An error occurred while trying to find the lesson.");
    } finally {
      setState(() { isLoading = false; });
    }
  }

  void _showError(String message) {
     print("VoiceAI Error: $message");
     setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'message': message,
        });
        isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;
    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Icon(
                  Icons.mic,
                  color: AppColors.primaryBackground,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Voice AI Chat',
                style: TextStyle(
                  fontSize: 18 * settings.fontSize,
                  color: Colors.white,
                  fontFamily: fontFamily(),
                ),
              ),
            ],
          ),
          elevation: 2,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey[50]!, Colors.grey[100]!],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child:
                    _chatHistory.isEmpty
                        ? _buildEmptyState(settings, fontFamily)
                        : _buildChatHistory(settings, fontFamily),
              ),
              _buildMicButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    AccessibilitySettings settings,
    String Function() fontFamily,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic_none,
            size: 80 * settings.fontSize,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Talk to Your AI Assistant',
            style: TextStyle(
              fontSize: 20 * settings.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: fontFamily(),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the mic button below and ask anything!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                color: Colors.grey[600],
                fontFamily: fontFamily(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistory(
    AccessibilitySettings settings,
    String Function() fontFamily,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: _chatHistory.length,
      itemBuilder: (context, index) {
        final chat = _chatHistory[index];
        final bool isUser = chat['role'] == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isUser ? 40 : 0,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primaryBackground : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Text(
              chat['message'] ?? '',
              style: TextStyle(
                fontSize: 15 * settings.fontSize,
                color: isUser ? Colors.white : Colors.black87,
                fontFamily: fontFamily(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton(
        onPressed: isLoading ? null : _handleMicPress,
        backgroundColor: AppColors.primaryBackground,
        child: Icon(
          isCallStarted ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}
