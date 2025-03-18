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
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,

          //APP NAME
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
              const Text(
                "All Articles",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              const Text(
                "Explore the latest content",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              Wrap(
              spacing: 8.0,
              children: [
                _buildCategoryChip("Science"),
                _buildCategoryChip("Mathematics"),
                _buildCategoryChip("History"),
                _buildCategoryChip("Technology"),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
              "Featured Articles",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            for (var article in feedData["articles"])
              _buildArticleCard(
                image: article["image"],
                heading: article["heading"],
                creator: article["creator"],
                duration: article["duration"],
              ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Chip(
      label: Text(label),
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
                child: const Icon(
                  Icons.article,
                  size: 50,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                creator,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Add "Read Article" functionality
                    },
                    child: const Text("Read Article"),
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