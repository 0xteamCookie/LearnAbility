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
    final bool isDyslexic = settings.openDyslexic;

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
            fontSize: 22 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(settings, fontFamily()),
              const SizedBox(height: 24),
              _buildStreakCard(settings, fontFamily()),
              const SizedBox(height: 24),
              _buildSubjectsProgressCard(settings, fontFamily()),
              const SizedBox(height: 24),
              _buildWeeklyActivityCard(settings, fontFamily()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AccessibilitySettings settings, String fontFamily) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Your Learning Progress",
                style: TextStyle(
                  fontSize: 24 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                // Show date range picker
              },
              tooltip: "Select time period",
            ),
          ],
        ),
        Text(
          "Track your achievements and see how far you've come",
          style: TextStyle(
            fontSize: 16 * settings.fontSize,
            color: Colors.grey,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(AccessibilitySettings settings, String fontFamily) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Streak",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "12 Days",
                  style: TextStyle(
                    fontSize: 32 * settings.fontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
                const Icon(Icons.whatshot, color: Colors.orange, size: 32),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Weekly Goal: 20 Lessons",
              style: TextStyle(
                fontSize: 14 * settings.fontSize,
                color: Colors.grey,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsProgressCard(AccessibilitySettings settings, String fontFamily) {
    final Map<String, Map<String, dynamic>> subjects = {
      "Science": {"progress": 0.45, "color": Colors.green},
      "English": {"progress": 0.65, "color": Colors.purple},
      "History": {"progress": 0.30, "color": Colors.brown},
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Subject Progress",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            ...subjects.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: entry.value["progress"],
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          entry.value["color"],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${(entry.value["progress"] * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyActivityCard(AccessibilitySettings settings, String fontFamily) {
    final List<Map<String, dynamic>> weeklyActivity = [
      {"day": "Mon", "value": 0.3},
      {"day": "Tue", "value": 0.7},
      {"day": "Wed", "value": 0.5},
      {"day": "Thu", "value": 0.9},
      {"day": "Fri", "value": 0.4},
      {"day": "Sat", "value": 0.2},
      {"day": "Sun", "value": 0.6},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weekly Activity",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyActivity.map((activity) {
                return Column(
                  children: [
                    Text(
                      activity["day"],
                      style: TextStyle(
                        fontSize: 14 * settings.fontSize,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 16,
                      height: activity["value"] * 100,
                      color: Colors.blue,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}