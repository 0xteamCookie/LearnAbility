import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'accessibility_model.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white, fontSize: 22 * settings.fontSize),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title: Your Learning Progress
            Text(
              "Your Learning Progress",
              style: TextStyle(
                fontSize: 24 * settings.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle: Track your achievements and see how far you've come
            Text(
              "Track your achievements and see how far you've come",
              style: TextStyle(
                fontSize: 16 * settings.fontSize,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            // First Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Title: Current Streak
                    Text(
                      "Current Streak",
                      style: TextStyle(
                        fontSize: 18 * settings.fontSize,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Streak Value
                        Text(
                          "12",
                          style: TextStyle(
                            fontSize: 32 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.whatshot, color: Colors.orange), // Fire emoji
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Card Title: Study Hours
                    Text(
                      "Study Hours",
                      style: TextStyle(
                        fontSize: 18 * settings.fontSize,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle: This week
                    Text(
                      "This week",
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.72, // 72%
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Progress Value
                        Text(
                          "72%",
                          style: TextStyle(
                            fontSize: 16 * settings.fontSize,
                            color: Colors.grey,
                          ),
                        ),
                        // Goal Text
                        Text(
                          "Weekly Goal - 20 Lessons",
                          style: TextStyle(
                            fontSize: 16 * settings.fontSize,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Second Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSubjectProgress("Science", 0.45, settings),
                    const SizedBox(height: 16),
                    _buildSubjectProgress("English", 0.65, settings),
                    const SizedBox(height: 16),
                    _buildSubjectProgress("History", 0.30, settings),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Subject Progress Card Widget Template
  Widget _buildSubjectProgress(String subject, double progress, AccessibilitySettings settings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.blue), // Replace with your logo
                const SizedBox(width: 8),
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 18 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Progress Percentage
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Linear Progress Bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }
}
