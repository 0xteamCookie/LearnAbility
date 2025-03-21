import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'accessibility_model.dart';

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
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    // Function to determine font family
    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22 * settings.fontSize, // Dynamically adjusting font size
            fontFamily: fontFamily(), // Apply font family
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: All Videos
              Text(
                "All Videos",
                style: TextStyle(
                  fontSize: 28 * settings.fontSize, // Dynamically adjusting font size
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Apply font family
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle: Explore the latest content
              Text(
                "Explore the latest content",
                style: TextStyle(
                  fontSize: 16 * settings.fontSize, // Dynamically adjusting font size
                  color: Colors.grey,
                  fontFamily: fontFamily(), // Apply font family
                ),
              ),
              const SizedBox(height: 20),

              // Category Chips
              Wrap(
                spacing: 8.0,
                children: [
                  _buildCategoryChip("Science", settings, fontFamily()),
                  _buildCategoryChip("Mathematics", settings, fontFamily()),
                  _buildCategoryChip("History", settings, fontFamily()),
                  _buildCategoryChip("Technology", settings, fontFamily()),
                ],
              ),
              const SizedBox(height: 24),

              // Section Title: Featured Videos
              Text(
                "Featured Videos",
                style: TextStyle(
                  fontSize: 20 * settings.fontSize, // Dynamically adjusting font size
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Apply font family
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
                  settings: settings,
                  fontFamily: fontFamily(), // Pass font family
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Category Chip Widget
  Widget _buildCategoryChip(
    String label,
    AccessibilitySettings settings,
    String fontFamily, // Pass font family
  ) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14 * settings.fontSize, // Dynamically adjusting font size
          fontFamily: fontFamily, // Apply font family
        ),
      ),
      backgroundColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  // Video Card Widget
  Widget _buildVideoCard({
    required String image,
    required String heading,
    required String creator,
    required String duration,
    required AccessibilitySettings settings,
    required String fontFamily, // Pass font family
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
                // Video Heading
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize, // Dynamically adjusting font size
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily, // Apply font family
                  ),
                ),
                const SizedBox(height: 8),
                // Creator Name
                Text(
                  creator,
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize, // Dynamically adjusting font size
                    color: Colors.grey,
                    fontFamily: fontFamily, // Apply font family
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16),
                    const SizedBox(width: 4),
                    // Video Duration
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize, // Dynamically adjusting font size
                        color: Colors.grey,
                        fontFamily: fontFamily, // Apply font family
                      ),
                    ),
                    const Spacer(),
                    // Watch Video Button
                    TextButton(
                      onPressed: () {
                        // Add "Watch Video" functionality
                      },
                      child: Text(
                        "Watch Video",
                        style: TextStyle(
                          fontSize: 14 * settings.fontSize, // Dynamically adjusting font size
                          fontFamily: fontFamily, // Apply font family
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