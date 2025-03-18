import 'package:flutter/material.dart';
import 'lesson_page.dart';

void main() {
  runApp(MaterialApp(
    home: LessonsPage(),
  ));
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
      {
        "imageUrl": "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg",
        "title": "Cat-O-logy",
        "subtitle": "meow meow meow",
        "duration": "400 mins"
      }
    ];

    setState(() {
      lessons = jsonList.map((json) => Lesson.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LessonPage(),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lessons",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...lessons.map((lesson) => _buildLessonCard(
                imageUrl: lesson.imageUrl,
                title: lesson.title,
                subtitle: lesson.subtitle,
                duration: lesson.duration,
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
  }) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(color: const Color.fromARGB(255, 100, 99, 99)),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: const Color.fromARGB(255, 89, 150, 255)),
                    SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(color: const Color.fromARGB(255, 57, 108, 250)),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add navigation or action here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      "Start Lesson",
                      style: TextStyle(color: Colors.white),
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