import 'package:flutter/material.dart';

class MyMaterial {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String duration;

  MyMaterial({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.duration,
  });

  factory MyMaterial.fromJson(Map<String, dynamic> json) {
    return MyMaterial(
      imageUrl: json['imageUrl'],
      title: json['title'],
      subtitle: json['subtitle'],
      duration: json['duration'],
    );
  }
}

class MyMaterialsPage extends StatefulWidget {
  const MyMaterialsPage({super.key});

  @override
  State<MyMaterialsPage> createState() => _MyMaterialsPageState();
}

class _MyMaterialsPageState extends State<MyMaterialsPage> {
  List<MyMaterial> materials = [];

  @override
  void initState() {
    super.initState();
    loadMaterials();
  }

  void loadMaterials() {
    // Use a List of Maps to represent the JSON data
    final List<Map<String, dynamic>> jsonList = [
      {
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Photosynthesis_en.svg/1200px-Photosynthesis_en.svg.png",
        "title": "Personalized Material 1",
        "subtitle": "This is a personalized material uploaded by the user",
        "duration": "10 mins"
      },
      {
        "imageUrl": "https://fatty15.com/cdn/shop/articles/Understanding_the_Process_of_Cellular_Respiration_1200x1200.png?v=1696520936",
        "title": "Personalized Material 2",
        "subtitle": "Another personalized material uploaded by the user",
        "duration": "20 mins"
      },
      {
        "imageUrl": "https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg",
        "title": "Personalized Material 3",
        "subtitle": "Yet another personalized material uploaded by the user",
        "duration": "30 mins"
      }
    ];

    setState(() {
      materials = jsonList.map((json) => MyMaterial.fromJson(json)).toList();
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personalized Materials",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...materials.map((material) => _buildMaterialCard(
                imageUrl: material.imageUrl,
                title: material.title,
                subtitle: material.subtitle,
                duration: material.duration,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard({
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
                      "View Material",
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