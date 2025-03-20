import "package:flutter/material.dart";
import "package:my_first_app/accessibility_model.dart";
import "package:provider/provider.dart";

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {

  final List<Color> _colorThemes = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    double fontSize = settings.fontSize;
    bool openDyslexic = false;
    double speechRate = 0.5;
    bool wordPrediction = false;
    bool visualTimers = false;
    bool breakReminders = false;
    int selectedColorIndex = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Accessibility Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Customize your learning experience",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "Text & Display",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Font Size"),
            Slider(
              value: fontSize,
              min: 12,
              max: 24,
              activeColor: Colors.blue,
              divisions: 12,
              label: '${fontSize.round()}px',
              onChanged: (double value) {
                settings.setFontSize(value);
              },
            ),
            SizedBox(height: 20),
            Text(
              "Color Theme",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _colorThemes.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColorIndex = _colorThemes.indexOf(color);
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColorIndex == _colorThemes.indexOf(color)
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text("Speech Rate"),
            Slider(
              value: speechRate,
              min: 0,
              max: 1,
              activeColor: Colors.blue,
              onChanged: (double value) {
                settings.setSpeechRate(value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Slow"),
                Text("Fast"),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text("Word Prediction"),
                Spacer(),
                Switch(
                  value: wordPrediction,
                  activeColor: const Color.fromARGB(255, 29, 106, 237),
                  onChanged: (bool value) {
                    settings.setWordPrediction(value);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text("Dyslexia friendly font"),
                Spacer(),
                Switch(
                  value: openDyslexic,
                  activeColor: const Color.fromARGB(255, 29, 106, 237),
                  onChanged: (bool value) {
                    settings.setDyslexic(value);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Focus & Timers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Visual Timers"),
                Spacer(),
                Switch(
                  value: visualTimers,
                  activeColor: const Color.fromARGB(255, 29, 106, 237),
                  onChanged: (bool value) {
                    settings.setVisualTimers(value);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text("Break Reminders"),
                Spacer(),
                Switch(
                  value: breakReminders,
                  activeColor: const Color.fromARGB(255, 29, 106, 237),
                  onChanged: (bool value) {
                    settings.setBreakReminders(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}