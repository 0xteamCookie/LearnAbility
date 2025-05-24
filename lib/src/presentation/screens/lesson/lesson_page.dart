import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/src/core/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/src/presentation/providers/accessibility_settings_provider.dart';
import 'package:my_first_app/src/core/app_constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Model classes for the new JSON structure
class LessonData {
  final String id;
  final String title;
  final String description;
  final String totalEstimatedTime;
  final List<String> learningObjectives;
  final List<LessonPage> pages;

  LessonData({
    required this.id,
    required this.title,
    required this.description,
    required this.totalEstimatedTime,
    required this.learningObjectives,
    required this.pages,
  });

  factory LessonData.fromJson(Map<String, dynamic> json) {
    return LessonData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      totalEstimatedTime: json['totalEstimatedTime'] ?? '',
      learningObjectives:
          json['learningObjectives'] != null
              ? List<String>.from(json['learningObjectives'])
              : [],
      pages:
          json['pages'] != null
              ? (json['pages'] as List)
                  .map((page) => LessonPage.fromJson(page))
                  .toList()
              : [],
    );
  }
}

class LessonPage {
  final String id;
  final String title;
  final int order;
  final String estimatedTime;
  final List<Block> blocks;

  LessonPage({
    required this.id,
    required this.title,
    required this.order,
    required this.estimatedTime,
    required this.blocks,
  });

  factory LessonPage.fromJson(Map<String, dynamic> json) {
    return LessonPage(
      id: json['id'],
      title: json['title'],
      order: json['order'],
      estimatedTime: json['estimatedTime'],
      blocks:
          (json['blocks'] as List)
              .map((block) => Block.fromJson(block))
              .toList(),
    );
  }
}

class Block {
  final String id;
  final String type;
  final int order;
  final Map<String, dynamic> data;

  Block({
    required this.id,
    required this.type,
    required this.order,
    required this.data,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    // Extract the type and common properties
    final type = json['type'];
    final id = json['id'];
    final order = json['order'];

    // Remove the common properties to get the type-specific data
    final Map<String, dynamic> data = Map.from(json);
    data.remove('id');
    data.remove('type');
    data.remove('order');

    return Block(id: id, type: type, order: order, data: data);
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }
}

class LessonContentPage extends StatefulWidget {
  final String lessonId;
  final String subjectId;

  const LessonContentPage({
    super.key,
    required this.lessonId,
    required this.subjectId,
  });

  @override
  State<LessonContentPage> createState() => _LessonContentPageState();
}

class _LessonContentPageState extends State<LessonContentPage> {
  // Add this function at the top of the _LessonContentPageState class

  // Add this function at the top of the _LessonContentPageState class
  Widget _buildHighlightedCode(String code, String language, double fontSize) {
    // This is a simple fallback if flutter_highlight is not available
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        code,
        style: TextStyle(fontSize: 14 * fontSize, fontFamily: 'Courier New'),
      ),
    );
  }

  LessonData? lessonData;
  bool isLoading = true;
  bool hasError = false;
  int currentPageIndex = 0;
  Map<String, int> quizAnswers =
      {}; // Maps question ID to selected answer index
  Map<String, bool> quizSubmitted = {}; // Maps question ID to submission status

  // Sample demo data to use when API fails
  final String demoLessonData = '''
{
    "success": true,
    "content": {
        "id": "b1989ecc-eebc-4e3d-8eea-02672d1ced32",
        "title": "Some Basic Concepts of Chemistry",
        "description": "Introduction to the fundamental concepts of chemistry, including the importance of chemistry, nature of matter and its properties.",
        "totalEstimatedTime": "60 min",
        "learningObjectives": [
            "Define chemistry and its various branches.",
            "Explain the importance of chemistry in everyday life.",
            "Classify matter based on its physical and chemical properties.",
            "Differentiate between elements, compounds, and mixtures.",
            "Understand the properties of matter and their measurement.",
            "Distinguish between physical and chemical properties."
        ],
        "pages": [
            {
                "id": "b1989ecc-eebc-4e3d-8eea-02672d1ced32-page-1",
                "title": "Introduction to Chemistry",
                "order": 1,
                "estimatedTime": "15 min",
                "blocks": [
                    {
                        "id": "intro-heading-1",
                        "type": "heading",
                        "order": 1,
                        "level": 1,
                        "content": "What is Chemistry?"
                    },
                    {
                        "id": "intro-text-1",
                        "type": "text",
                        "order": 2,
                        "content": "Chemistry is the study of matter and its properties as well as how matter changes. It is a vast field that encompasses the composition, structure, behavior, and reactions of substances.",
                        "emphasis": "none"
                    },
                    {
                        "id": "intro-list-1",
                        "type": "list",
                        "order": 3,
                        "items": [
                            "Analytical Chemistry",
                            "Biochemistry",
                            "Inorganic Chemistry",
                            "Organic Chemistry",
                            "Physical Chemistry"
                        ],
                        "style": "bullet"
                    },
                    {
                        "id": "intro-heading-2",
                        "type": "heading",
                        "order": 4,
                        "level": 2,
                        "content": "Importance of Chemistry"
                    },
                    {
                        "id": "intro-text-2",
                        "type": "text",
                        "order": 5,
                        "content": "Chemistry plays a crucial role in our daily lives and in various industries.",
                        "emphasis": "strong"
                    },
                    {
                        "id": "intro-list-2",
                        "type": "list",
                        "order": 6,
                        "items": [
                            "Medicine and Healthcare",
                            "Agriculture and Food Production",
                            "Manufacturing and Materials Science",
                            "Energy Production and Environmental Science"
                        ],
                        "style": "numbered"
                    },
                    {
                        "id": "intro-callout-1",
                        "type": "callout",
                        "order": 7,
                        "content": "Chemistry is fundamental to understanding the world around us.",
                        "variant": "info",
                        "title": "Key Takeaway"
                    }
                ]
            },
            {
                "id": "b1989ecc-eebc-4e3d-8eea-02672d1ced32-page-2",
                "title": "Nature of Matter",
                "order": 2,
                "estimatedTime": "20 min",
                "blocks": [
                    {
                        "id": "matter-heading-1",
                        "type": "heading",
                        "order": 1,
                        "level": 1,
                        "content": "What is Matter?"
                    },
                    {
                        "id": "matter-definition-1",
                        "type": "definition",
                        "order": 2,
                        "term": "Matter",
                        "definition": "Anything that has mass and occupies space.",
                        "examples": [
                            "A book",
                            "Water",
                            "Air"
                        ]
                    },
                    {
                        "id": "matter-heading-2",
                        "type": "heading",
                        "order": 3,
                        "level": 2,
                        "content": "States of Matter"
                    },
                    {
                        "id": "matter-list-1",
                        "type": "list",
                        "order": 4,
                        "items": [
                            "Solid: Definite shape and volume.",
                            "Liquid: Definite volume but no definite shape.",
                            "Gas: No definite shape or volume.",
                            "Plasma: Ionized gas with high temperature."
                        ],
                        "style": "bullet"
                    },
                    {
                        "id": "matter-table-1",
                        "type": "table",
                        "order": 5,
                        "headers": [
                            "State",
                            "Shape",
                            "Volume",
                            "Compressibility"
                        ],
                        "rows": [
                            [
                                "Solid",
                                "Definite",
                                "Definite",
                                "Low"
                            ],
                            [
                                "Liquid",
                                "Indefinite",
                                "Definite",
                                "Low"
                            ],
                            [
                                "Gas",
                                "Indefinite",
                                "Indefinite",
                                "High"
                            ]
                        ],
                        "caption": "Comparison of States of Matter"
                    },
                    {
                        "id": "matter-heading-3",
                        "type": "heading",
                        "order": 6,
                        "level": 2,
                        "content": "Classification of Matter"
                    },
                    {
                        "id": "matter-list-2",
                        "type": "list",
                        "order": 7,
                        "items": [
                            "Pure Substances: Elements and Compounds",
                            "Mixtures: Homogeneous and Heterogeneous"
                        ],
                        "style": "numbered"
                    },
                    {
                        "id": "matter-exercise-1",
                        "type": "exercise",
                        "order": 8,
                        "instructions": "Classify the following as element, compound, or mixture: Water (H2O), Air, Gold (Au), Saltwater, Sugar (C12H22O11).",
                        "solution": "Water (H2O): Compound, Air: Mixture (Homogeneous), Gold (Au): Element, Saltwater: Mixture (Homogeneous), Sugar (C12H22O11): Compound",
                        "hints": [
                            "Elements are found on the periodic table.",
                            "Compounds are made of two or more elements chemically combined."
                        ]
                    }
                ]
            },
            {
                "id": "b1989ecc-eebc-4e3d-8eea-02672d1ced32-page-3",
                "title": "Properties of Matter",
                "order": 3,
                "estimatedTime": "25 min",
                "blocks": [
                    {
                        "id": "properties-heading-1",
                        "type": "heading",
                        "order": 1,
                        "level": 1,
                        "content": "Properties of Matter"
                    },
                    {
                        "id": "properties-text-1",
                        "type": "text",
                        "order": 2,
                        "content": "Properties of matter can be classified as physical or chemical.",
                        "emphasis": "none"
                    },
                    {
                        "id": "properties-heading-2",
                        "type": "heading",
                        "order": 3,
                        "level": 2,
                        "content": "Physical Properties"
                    },
                    {
                        "id": "properties-definition-1",
                        "type": "definition",
                        "order": 4,
                        "term": "Physical Property",
                        "definition": "A characteristic of a substance that can be observed or measured without changing the identity of the substance.",
                        "examples": [
                            "Color",
                            "Density",
                            "Melting Point",
                            "Boiling Point"
                        ]
                    },
                    {
                        "id": "properties-heading-3",
                        "type": "heading",
                        "order": 5,
                        "level": 2,
                        "content": "Chemical Properties"
                    },
                    {
                        "id": "properties-definition-2",
                        "type": "definition",
                        "order": 6,
                        "term": "Chemical Property",
                        "definition": "A characteristic of a substance that describes its ability to change into different substances.",
                        "examples": [
                            "Flammability",
                            "Reactivity with acids",
                            "Oxidation"
                        ]
                    },
                    {
                        "id": "properties-quiz-1",
                        "type": "quiz",
                        "order": 7,
                        "title": "Physical vs. Chemical Properties",
                        "questions": [
                            {
                                "id": "q1",
                                "question": "Which of the following is a physical property?",
                                "options": [
                                    "Flammability",
                                    "Boiling Point",
                                    "Reactivity with water",
                                    "Rusting"
                                ],
                                "correctAnswer": 1,
                                "explanation": "Boiling point is a physical property because it can be measured without changing the substance's identity."
                            },
                            {
                                "id": "q2",
                                "question": "Which of the following is a chemical property?",
                                "options": [
                                    "Color",
                                    "Density",
                                    "Melting point",
                                    "Combustibility"
                                ],
                                "correctAnswer": 3,
                                "explanation": "Combustibility is a chemical property, describing a substance's ability to burn, which results in new substances."
                            }
                        ]
                    },
                    {
                        "id": "properties-checkpoint-1",
                        "type": "checkpoint",
                        "order": 8,
                        "title": "Understanding Properties",
                        "description": "Ensure you can differentiate between physical and chemical properties before moving on.",
                        "requiredToAdvance": true
                    }
                ]
            }
        ]
    },
    "isNew": false
}
''';

  @override
  void initState() {
    super.initState();
    fetchLessonData();
  }

  Future<void> fetchLessonData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      print(
        '${Constants.uri}/api/v1/pyos/${widget.subjectId}/${widget.lessonId}',
      );
      final response = await http.get(
        Uri.parse(
          '${Constants.uri}/api/v1/pyos/${widget.subjectId}/${widget.lessonId}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        //print(data);
        setState(() {
          lessonData = LessonData.fromJson(data['content']);
          isLoading = false;

          // Initialize quiz answers and submission status
          for (var page in lessonData!.pages) {
            for (var block in page.blocks) {
              if (block.type == 'quiz') {
                final questions = (block.data['questions'] as List);
                for (var question in questions) {
                  final questionId = question['id'];
                  quizAnswers[questionId] = -1; // -1 means no answer selected
                  quizSubmitted[questionId] = false;
                }
              }
            }
          }
        });
      } else {
        // If API fails, use demo data
        _loadDemoData();
      }
    } catch (e) {
      print("Error fetching lesson data: $e");
      // If API fails, use demo data
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    try {
      final Map<String, dynamic> demoData = jsonDecode(demoLessonData);
      setState(() {
        lessonData = LessonData.fromJson(demoData['content']);
        isLoading = false;

        // Initialize quiz answers and submission status for demo data
        for (var page in lessonData!.pages) {
          for (var block in page.blocks) {
            if (block.type == 'quiz') {
              final questions = (block.data['questions'] as List);
              for (var question in questions) {
                final questionId = question['id'];
                quizAnswers[questionId] = -1; // -1 means no answer selected
                quizSubmitted[questionId] = false;
              }
            }
          }
        }
      });
    } catch (e) {
      print("Error loading demo data: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void goToNextPage() {
    if (lessonData != null &&
        lessonData!.pages.isNotEmpty &&
        currentPageIndex < lessonData!.pages.length - 1) {
      setState(() {
        currentPageIndex++;
      });
    }
  }

  void goToPreviousPage() {
    if (lessonData != null &&
        lessonData!.pages.isNotEmpty &&
        currentPageIndex > 0) {
      setState(() {
        currentPageIndex--;
      });
    }
  }

  void selectQuizAnswer(String questionId, int answerIndex) {
    if (quizSubmitted[questionId] == true) return;

    setState(() {
      quizAnswers[questionId] = answerIndex;
    });
  }

  void submitQuizAnswer(String questionId, int correctAnswer) {
    setState(() {
      quizSubmitted[questionId] = true;
    });
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
          isLoading ? "Loading Lesson..." : lessonData?.title ?? "Lesson",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20 * settings.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily(),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : hasError
              ? _buildErrorState(settings, fontFamily())
              : _buildLessonContent(settings, fontFamily()),
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
              "Failed to load lesson",
              style: TextStyle(
                fontSize: 20 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "There was a problem loading the lesson content. Please try again.",
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
              onPressed: fetchLessonData,
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

  Widget _buildLessonContent(
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    if (lessonData == null) return Container();

    // Check if pages list is empty
    if (lessonData!.pages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.amber.shade400,
              ),
              SizedBox(height: 16),
              Text(
                "No content available",
                style: TextStyle(
                  fontSize: 20 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: Colors.amber.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "This lesson doesn't have any content pages yet.",
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
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                label: Text(
                  "Go Back",
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

    final currentPage = lessonData!.pages[currentPageIndex];

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (currentPageIndex + 1) / lessonData!.pages.length,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0XFF6366F1)),
        ),

        // Page content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson title and description (only on first page)
                  if (currentPageIndex == 0) ...[
                    Text(
                      lessonData!.title,
                      style: TextStyle(
                        fontSize: 24 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      lessonData!.description,
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        color: Colors.grey.shade700,
                        fontFamily: fontFamily,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Learning objectives
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: Color(0XFF6366F1)),
                                SizedBox(width: 8),
                                Text(
                                  "Learning Objectives",
                                  style: TextStyle(
                                    fontSize: 18 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                    color: Color(0XFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            ...lessonData!.learningObjectives
                                .map(
                                  (objective) => Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 18,
                                          color: Colors.green.shade600,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            objective,
                                            style: TextStyle(
                                              fontSize: 14 * settings.fontSize,
                                              fontFamily: fontFamily,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                ,
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Page title
                  Text(
                    currentPage.title,
                    style: TextStyle(
                      fontSize: 22 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily,
                      color: Color(0XFF6366F1),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Estimated time: ${currentPage.estimatedTime}",
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      color: Colors.grey.shade600,
                      fontFamily: fontFamily,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Page blocks
                  ...currentPage.blocks
                      .sorted((a, b) => a.order.compareTo(b.order))
                      .map((block) => _buildBlock(block, settings, fontFamily))
                      ,
                ],
              ),
            ),
          ),
        ),

        // Navigation controls
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: currentPageIndex > 0 ? goToPreviousPage : null,
                icon: Icon(Icons.arrow_back),
                label: Text("Previous"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade100,
                  disabledForegroundColor: Colors.grey.shade400,
                ),
              ),
              Text(
                'Page ${currentPageIndex + 1} of ${lessonData!.pages.length}',
                style: TextStyle(
                  fontSize: 14 * settings.fontSize,
                  color: Colors.grey.shade600,
                  fontFamily: fontFamily,
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    currentPageIndex < lessonData!.pages.length - 1
                        ? goToNextPage
                        : null,
                icon: Icon(Icons.arrow_forward),
                label: Text("Next"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBackground,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade100,
                  disabledForegroundColor: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    switch (block.type) {
      case 'heading':
        return _buildHeadingBlock(block, settings, fontFamily);
      case 'text':
        return _buildTextBlock(block, settings, fontFamily);
      case 'list':
        return _buildListBlock(block, settings, fontFamily);
      case 'code':
        return _buildCodeBlock(block, settings, fontFamily);
      case 'equation':
        return _buildEquationBlock(block, settings, fontFamily);
      case 'callout':
        return _buildCalloutBlock(block, settings, fontFamily);
      case 'quiz':
        return _buildQuizBlock(block, settings, fontFamily);
      case 'exercise':
        return _buildExerciseBlock(block, settings, fontFamily);
      case 'checkpoint':
        return _buildCheckpointBlock(block, settings, fontFamily);
      case 'table':
        return _buildTableBlock(block, settings, fontFamily);
      case 'definition':
        return _buildDefinitionBlock(block, settings, fontFamily);
      default:
        return Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.red.shade50,
          ),
          child: Text(
            "Unknown block type: ${block.type}",
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 14 * settings.fontSize,
              fontFamily: fontFamily,
            ),
          ),
        );
    }
  }

  Widget _buildHeadingBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final level = block.data['level'] ?? 1;
    final content = block.data['content'] ?? "";

    double fontSize;
    FontWeight fontWeight;

    switch (level) {
      case 1:
        fontSize = 24;
        fontWeight = FontWeight.bold;
        break;
      case 2:
        fontSize = 22;
        fontWeight = FontWeight.bold;
        break;
      case 3:
        fontSize = 20;
        fontWeight = FontWeight.w600;
        break;
      case 4:
        fontSize = 18;
        fontWeight = FontWeight.w600;
        break;
      default:
        fontSize = 16;
        fontWeight = FontWeight.w500;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16, top: level == 1 ? 8 : 0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: fontSize * settings.fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          color: level <= 2 ? Color(0XFF6366F1) : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final content = block.data['content'] ?? "";

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontFamily: fontFamily,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildListBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final items = List<String>.from(block.data['items'] ?? []);
    final style = block.data['style'] ?? "bullet";

    return Padding(
      padding: EdgeInsets.only(bottom: 16, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              Widget bullet;
              switch (style) {
                case 'numbered':
                  bullet = Container(
                    width: 24,
                    alignment: Alignment.center,
                    child: Text(
                      "${index + 1}.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * settings.fontSize,
                        fontFamily: fontFamily,
                      ),
                    ),
                  );
                  break;
                case 'check':
                  bullet = Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.green.shade600,
                  );
                  break;
                case 'bullet':
                default:
                  bullet = Container(
                    width: 24,
                    alignment: Alignment.center,
                    child: Text(
                      "•",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontFamily: fontFamily,
                      ),
                    ),
                  );
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bullet,
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          height: 1.4,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          height: 1.4,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCodeBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final content = block.data['content'] ?? "";
    final language = block.data['language'] ?? "plaintext";
    // final showLineNumbers = block.data['showLineNumbers'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Courier New",
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          _buildHighlightedCode(content, language, settings.fontSize),
        ],
      ),
    );
  }

  Widget _buildEquationBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final content = block.data['content'] ?? "";
    final displayMode = block.data['displayMode'] ?? false;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: displayMode ? 16 : 8),
      alignment: displayMode ? Alignment.center : Alignment.centerLeft,
      child: Math.tex(
        content,
        mathStyle: displayMode ? MathStyle.display : MathStyle.text,
        textStyle: TextStyle(fontSize: 16 * settings.fontSize),
      ),
    );
  }

  Widget _buildCalloutBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final content = block.data['content'] ?? "";
    final variant = block.data['variant'] ?? "info";
    final title = block.data['title'];

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (variant) {
      case 'warning':
        backgroundColor = Colors.amber.shade50;
        borderColor = Colors.amber.shade300;
        textColor = Colors.amber.shade900;
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade900;
        icon = Icons.error;
        break;
      case 'info':
      default:
        backgroundColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade300;
        textColor = Colors.blue.shade900;
        icon = Icons.info;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Icon(icon, color: textColor),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
          Text(
            content,
            style: TextStyle(
              fontSize: 14 * settings.fontSize,
              fontFamily: fontFamily,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final title = block.data['title'] ?? "Quiz";
    final questions =
        (block.data['questions'] as List?)
            ?.map((q) => Map<String, dynamic>.from(q))
            .toList() ??
        [];

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0XFF6366F1).withOpacity(0.3)),
        color: Color(0XFF6366F1).withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0XFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.quiz, color: Color(0XFF6366F1)),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: Color(0XFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  questions.map((question) {
                    final questionId = question['id'];
                    final questionText = question['question'];
                    final options = List<String>.from(question['options']);
                    final correctAnswer = question['correctAnswer'];
                    final explanation = question['explanation'];

                    final isSubmitted = quizSubmitted[questionId] ?? false;
                    final selectedAnswer = quizAnswers[questionId] ?? -1;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionText,
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontWeight: FontWeight.w500,
                              fontFamily: fontFamily,
                            ),
                          ),
                          SizedBox(height: 12),
                          ...options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value;

                            Color backgroundColor = Colors.white;
                            Color borderColor = Colors.grey.shade300;

                            if (isSubmitted) {
                              if (index == correctAnswer) {
                                backgroundColor = Colors.green.shade50;
                                borderColor = Colors.green.shade300;
                              } else if (index == selectedAnswer) {
                                backgroundColor = Colors.red.shade50;
                                borderColor = Colors.red.shade300;
                              }
                            } else if (index == selectedAnswer) {
                              backgroundColor = Color(
                                0XFF6366F1,
                              ).withOpacity(0.1);
                              borderColor = Color(0XFF6366F1);
                            }

                            return GestureDetector(
                              onTap: () {
                                if (!isSubmitted) {
                                  selectQuizAnswer(questionId, index);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              index == selectedAnswer
                                                  ? Color(0XFF6366F1)
                                                  : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        color:
                                            index == selectedAnswer
                                                ? Color(0XFF6366F1)
                                                : Colors.transparent,
                                      ),
                                      child:
                                          index == selectedAnswer
                                              ? Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14 * settings.fontSize,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          SizedBox(height: 16),

                          if (!isSubmitted) ...[
                            Center(
                              child: ElevatedButton(
                                onPressed:
                                    selectedAnswer >= 0
                                        ? () => submitQuizAnswer(
                                          questionId,
                                          correctAnswer,
                                        )
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Submit Answer",
                                  style: TextStyle(
                                    fontSize: 14 * settings.fontSize,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    selectedAnswer == correctAnswer
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      selectedAnswer == correctAnswer
                                          ? Colors.green.shade300
                                          : Colors.red.shade300,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        selectedAnswer == correctAnswer
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            selectedAnswer == correctAnswer
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        selectedAnswer == correctAnswer
                                            ? "Correct!"
                                            : "Incorrect",
                                        style: TextStyle(
                                          fontSize: 16 * settings.fontSize,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: fontFamily,
                                          color:
                                              selectedAnswer == correctAnswer
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    explanation,
                                    style: TextStyle(
                                      fontSize: 14 * settings.fontSize,
                                      fontFamily: fontFamily,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final instructions = block.data['instructions'] ?? "";
    final startingCode = block.data['startingCode'];
    final solution = block.data['solution'];
    final hints = List<String>.from(block.data['hints'] ?? []);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300),
        color: Colors.teal.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.code, color: Colors.teal.shade700),
                SizedBox(width: 8),
                Text(
                  "Exercise",
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructions,
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily,
                  ),
                ),

                if (startingCode != null) ...[
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Starting Code",
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Courier New",
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            startingCode,
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontFamily: "Courier New",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (hints.isNotEmpty) ...[
                  SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(
                      "Hints",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    children:
                        hints
                            .map(
                              (hint) => Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      color: Colors.amber.shade700,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        hint,
                                        style: TextStyle(
                                          fontSize: 14 * settings.fontSize,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],

                if (solution != null) ...[
                  SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(
                      "Solution",
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    children: [
                      Container(
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            solution,
                            style: TextStyle(
                              fontSize: 14 * settings.fontSize,
                              fontFamily: "Courier New",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final title = block.data['title'] ?? "Checkpoint";
    final description = block.data['description'] ?? "";
    final requiredToAdvance = block.data['requiredToAdvance'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
        color: Colors.orange.shade50,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: Colors.orange.shade700),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
              ),
            ),
            SizedBox(height: 16),
            if (requiredToAdvance)
              Row(
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
                  SizedBox(width: 8),
                  Text(
                    "You must complete this checkpoint to continue",
                    style: TextStyle(
                      fontSize: 14 * settings.fontSize,
                      fontStyle: FontStyle.italic,
                      fontFamily: fontFamily,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final headers = List<String>.from(block.data['headers'] ?? []);
    final rows =
        (block.data['rows'] as List?)
            ?.map((row) => List<String>.from(row))
            .toList() ??
        [];
    final caption = block.data['caption'];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              dataRowColor: WidgetStateProperty.all(Colors.white),
              columns:
                  headers
                      .map(
                        (header) => DataColumn(
                          label: Text(
                            header,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14 * settings.fontSize,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              rows:
                  rows
                      .map(
                        (row) => DataRow(
                          cells:
                              row
                                  .map(
                                    (cell) => DataCell(
                                      Text(
                                        cell,
                                        style: TextStyle(
                                          fontSize: 14 * settings.fontSize,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      )
                      .toList(),
            ),
          ),
          if (caption != null)
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                caption,
                style: TextStyle(
                  fontSize: 12 * settings.fontSize,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                  fontFamily: fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefinitionBlock(
    Block block,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    final term = block.data['term'] ?? "";
    final definition = block.data['definition'] ?? "";
    final examples = List<String>.from(block.data['examples'] ?? []);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade300),
        color: Colors.purple.shade50,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              term,
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: Colors.purple.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              definition,
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                fontFamily: fontFamily,
              ),
            ),
            if (examples.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                "Examples:",
                style: TextStyle(
                  fontSize: 14 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: Colors.purple.shade700,
                ),
              ),
              SizedBox(height: 4),
              ...examples
                  .map(
                    (example) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "•",
                            style: TextStyle(
                              fontSize: 16 * settings.fontSize,
                              fontFamily: fontFamily,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              example,
                              style: TextStyle(
                                fontSize: 14 * settings.fontSize,
                                fontStyle: FontStyle.italic,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  ,
            ],
          ],
        ),
      ),
    );
  }
}
