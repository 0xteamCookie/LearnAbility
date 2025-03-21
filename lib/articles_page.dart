import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'accessibility_model.dart';

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
        "image": "https://invalid.url/150",
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
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,

        // APP NAME
        title: Text(
          "LearnAbility",
          style: TextStyle(
            color: const Color.fromRGBO(255, 255, 255, 1),
            fontSize: 24 * settings.fontSize,
            fontFamily: fontFamily(), // Added fontFamily
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "All Articles",
                style: TextStyle(
                  fontSize: 28 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              const SizedBox(height: 4),

              Text(
                "Explore the latest content",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize,
                  color: Colors.grey,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 8.0,
                children: [
                  _buildCategoryChip("Science", settings.fontSize, fontFamily()),
                  _buildCategoryChip("Mathematics", settings.fontSize, fontFamily()),
                  _buildCategoryChip("History", settings.fontSize, fontFamily()),
                  _buildCategoryChip("Technology", settings.fontSize, fontFamily()),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                "Featured Articles",
                style: TextStyle(
                  fontSize: 20 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              const SizedBox(height: 8),

              for (var article in feedData["articles"])
                _buildArticleCard(
                  image: article["image"],
                  heading: article["heading"],
                  creator: article["creator"],
                  duration: article["duration"],
                  fontSize: settings.fontSize,
                  fontFamily: fontFamily(), // Pass fontFamily
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, double fontSize, String fontFamily) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14 * fontSize,
          fontFamily: fontFamily, // Added fontFamily
        ),
      ),
      backgroundColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildArticleCard({
    required String image,
    required String heading,
    required String creator,
    required String duration,
    required double fontSize,
    required String fontFamily, // Added fontFamily parameter
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.network(
              image,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.article,
                    size: 50 * fontSize,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: 18 * fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily, // Added fontFamily
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  creator,
                  style: TextStyle(
                    fontSize: 14 * fontSize,
                    color: Colors.grey,
                    fontFamily: fontFamily, // Added fontFamily
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16 * fontSize),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 14 * fontSize,
                        color: Colors.grey,
                        fontFamily: fontFamily, // Added fontFamily
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Add "Read Article" functionality
                      },
                      child: Text(
                        "Read Article",
                        style: TextStyle(
                          fontSize: 14 * fontSize,
                          fontFamily: fontFamily, // Added fontFamily
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}