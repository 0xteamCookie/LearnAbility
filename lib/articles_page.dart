import "package:flutter/material.dart";

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final Map<String, dynamic> feedData = {
  "articles": [
      {
        "image": "https://via.placeholder.com/150",
        "heading": "Getting Started with Dart",
        "creator": "John Doe",
        "duration": "5 min read"
      },
      {
        "image": "https://invalid.url/150", // Invalid URL for testing
        "heading": "Flutter Animations Guide",
        "creator": "Jane Smith",
        "duration": "8 min read"
      },
      {
        "image": "https://via.placeholder.com/150",
        "heading": "Effective Testing in Flutter",
        "creator": "Alice Johnson",
        "duration": "7 min read"
      }
    ]
  };
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,

          //APP NAME
          title: Text(
            "LearnAbility",
              style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)),
          ),
        ),

      body: Text("This is Articles page"),
    );
  }
}