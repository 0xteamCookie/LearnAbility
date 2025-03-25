import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../accessibility_model.dart';
import 'lesson_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AccessibilitySettings(),
      child: MaterialApp(
        home: LessonsPage(),
      ),
    ),
  );
}

class Lesson {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String duration;

  Lesson({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.duration,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      imageUrl: json['imageUrl'],
      title: json['title'],
      subtitle: json['subtitle'],
      duration: json['duration'],
    );
  }
}

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  List<Lesson> lessons = [];

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  void loadLessons() {
    // Use a List of Maps to represent the JSON data
    final List<Map<String, dynamic>> jsonList = [
      {
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Photosynthesis_en.svg/1200px-Photosynthesis_en.svg.png",
        "title": "Introduction to Photosynthesis",
        "subtitle": "Learn how plants convert sunlight into energy through photosynthesis",
        "duration": "15 mins"
      },
      {
        "imageUrl": "https://fatty15.com/cdn/shop/articles/Understanding_the_Process_of_Cellular_Respiration_1200x1200.png?v=1696520936",
        "title": "Cellular Respiration",
        "subtitle": "Understand how cells produce energy from nutrients",
        "duration": "20 mins"
      },
      {
        "imageUrl": "https://www.perkins.org/wp-content/uploads/2022/06/mitosis.png",
        "title": "Mitosis and Meiosis",
        "subtitle": "Explore the processes of cell division",
        "duration": "25 mins"
      },
    ];

    setState(() {
      lessons = jsonList.map((json) => Lesson.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return Scaffold(
      backgroundColor: Color(0xFFEDE7F6),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Row(
                
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 28, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Navigate back
                    },
                  ),
                  Text(
                    "Lessons",
                    style: TextStyle(
                      fontSize: 24 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily(),
                      
                    ),
                  ),
                ],
                
              ),
              SizedBox(height: 16), // Add some spacing

              // Lessons Title
              
              SizedBox(height: 16),

              // Lesson Cards
              ...lessons.map((lesson) => _buildLessonCard(
                imageUrl: lesson.imageUrl,
                title: lesson.title,
                subtitle: lesson.subtitle,
                duration: lesson.duration,
                fontSize: settings.fontSize,
                fontFamily: fontFamily(), // Pass fontFamily to the card
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String duration,
    required double fontSize,
    required String fontFamily, // Added fontFamily parameter
  }) {
    return Card(
      shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40)
            ),
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16), 
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(20), 
    topRight: Radius.circular(20), 
  ),
  child: Container(
    width: double.infinity,
    height: 150, // Ensuring consistent height with the original image
    alignment: Alignment.center, // Centers the icon inside the container
    color: Colors.grey[200], // Optional background color for better visibility
    child: Icon(
      Icons.image,
      size: 150, // Set icon size to 150
      color: Colors.grey,
    ),
  ),
),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18 * fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily, // Added fontFamily
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 100, 99, 99),
                    fontSize: 16 * fontSize,
                    fontFamily: fontFamily, // Added fontFamily
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16 * fontSize, color: Colors.deepPurpleAccent,
                    ),
                    SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 16 * fontSize,
                        fontFamily: fontFamily, // Added fontFamily
                      ),
                    ),
                  ],
                ),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonPage()),
              );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      "Start Lesson",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontSize,
                        fontFamily: fontFamily, // Added fontFamily
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}