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
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    double fontSize = settings.fontSize;
    bool openDyslexic = settings.openDyslexic;
    double speechRate = settings.speechRate;
    bool wordPrediction = settings.wordPrediction;
    bool visualTimers = settings.visualTimers;
    bool breakReminders = settings.breakReminders;
    int selectedColorIndex = settings.selectedColorIndex;

    String displaySliderValue(double value) {
      if (value == 1.0) {
        return "1x";
      } else if (value == 0.5) {
        return "0.5x";
      } else if (value == 0.75) {
        return "0.75x";
      } else if (value == 1.25) {
        return "1.25x";
      } else if (value == 1.5) {
        return "1.5x";
      }
      return "x";
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                  ),
                  Text(
                    "Accessibility Settings",
                    style: TextStyle(
                      fontSize: 24 * fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
      
              // Text & Display Section
              Text(
                "Text & Display",
                style: TextStyle(
                  fontSize: 20 * fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
            ),
              SizedBox(height: 10),
              Text(
                "Font Size",
                style: TextStyle(
                  fontSize: 16 * fontSize,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              Slider(
                value: fontSize,
                min: 0.5,
                max: 1.5,
                activeColor: Colors.deepPurple,
                divisions: 4,
                label: displaySliderValue(fontSize),
                onChanged: (double value) {
                  settings.setFontSize(value);
                },
              ),
              SizedBox(height: 20),
      
              // Color Theme Section
              Text(
                "Color Theme",
                style: TextStyle(
                  fontSize: 20 * fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _colorThemes.map((color) {
                  return GestureDetector(
                    onTap: () {
                      settings.setColorIndex(_colorThemes.indexOf(color));
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
      
              // Speech Rate Section
              Text(
                "Speech Rate",
                style: TextStyle(
                  fontSize: 16 * fontSize,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              Slider(
                value: speechRate,
                min: 0,
                max: 1,
                label: displaySliderValue(speechRate),
                activeColor: Colors.deepPurple,
                onChanged: (double value) {
                  settings.setSpeechRate(value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Slow",
                    style: TextStyle(
                      fontSize: 14 * fontSize,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                  Text(
                    "Fast",
                    style: TextStyle(
                      fontSize: 14 * fontSize,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
      
              // Word Prediction Section
              Row(
                children: [
                  Text(
                    "Word Prediction",
                    style: TextStyle(
                      fontSize: 16 * fontSize,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: wordPrediction,
                    activeColor: Colors.deepPurple,
                    onChanged: (bool value) {
                      settings.setWordPrediction(value);
                    },
                  ),
                ],
              ),
      
              // Dyslexia friendly font Section
              Row(
                children: [
                  Text(
                    "Dyslexia friendly font",
                    style: TextStyle(
                      fontSize: 16 * fontSize,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: openDyslexic,
                    activeColor: Colors.deepPurple,
                    onChanged: (bool value) {
                      settings.setDyslexic(value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
      
              // Focus & Timers Section
              Text(
                "Focus & Timers",
                style: TextStyle(
                  fontSize: 20 * fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              SizedBox(height: 10),
      
              // Visual Timers Section
              Row(
                children: [
                  Text(
                    "Visual Timers",
                    style: TextStyle(
                      fontSize: 16 * fontSize,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: visualTimers,
                    activeColor: Colors.deepPurple,
                    onChanged: (bool value) {
                      settings.setVisualTimers(value);
                    },
                  ),
                ],
              ),
      
              // Break Reminders Section
              Row(
                children: [
                  Text(
                    "Break Reminders",
                    style: TextStyle(
                      fontSize: 16 * fontSize,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                  Spacer(),
                  Switch(
                    value: breakReminders,
                    activeColor: Colors.deepPurple,
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