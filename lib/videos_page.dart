import 'package:flutter/material.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final Map<String, dynamic> feedData = {
    "videos": [
      {
        "image": "https://via.placeholder.com/150",
        "heading": "Introduction to Flutter",
        "creator": "John Doe",
        "duration": "10:25"
      },
      {
        "image": "https://invalid.url/150",
        "heading": "Advanced State Management",
        "creator": "Jane Smith",
        "duration": "15:40"
      },
      {
        "image": "https://via.placeholder.com/150",
        "heading": "Building Responsive UIs",
        "creator": "Alice Johnson",
        "duration": "12:30"
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,

        //AAP NAME
        title: const Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white),
        ),
      ),


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "All Videos",
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
              "Featured Videos",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Dynamically generate video cards from feedData
            for (var video in feedData["videos"])
              _buildVideoCard(
                image: video["image"],
                heading: video["heading"],
                creator: video["creator"],
                duration: video["duration"],
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

  Widget _buildVideoCard({
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
                  Icons.image,
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
                      // Add "Watch Video" functionality
                    },
                    child: const Text("Watch Video"),
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