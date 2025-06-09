import "package:flutter/material.dart";
import "package:my_first_app/accessibility_model.dart";
import "package:my_first_app/repository/widgets/global_navbar.dart";
import "package:provider/provider.dart";
import 'package:easy_localization/easy_localization.dart';
import "package:lucide_icons/lucide_icons.dart";

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
  void initState() {
    super.initState();
    // Set the correct index when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessibilitySettings>(
        context,
        listen: false,
      ).setSelectedIndex(3);
    });
  }

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
    bool pomodoro = settings.pomodoro;
    bool breakReminders = settings.reminders;
    int selectedColorIndex = settings.selectedColorIndex;
    bool textToSpeech = settings.textToSpeech;

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

    return GlobalNavBar(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(color: Colors.white)),
          Column(
            children: [
              // Gradient Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0XFF6366F1), Color(0XFF8B5CF6)],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, 50, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              LucideIcons.arrowLeft,
                              size: 22,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "accessibility".tr(),
                          style: TextStyle(
                            fontSize: 24 * settings.fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily(),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "customize_learning".tr(),
                      style: TextStyle(
                        fontSize: 16 * settings.fontSize,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: fontFamily(),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text & Display Section
                      _buildSectionHeader(
                        "text_and_display".tr(),
                        fontSize,
                        fontFamily(),
                      ),
                      SizedBox(height: 16),

                      // Font Size
                      _buildSettingCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "font_size".tr(),
                              style: TextStyle(
                                fontSize: 16 * fontSize,
                                fontWeight: FontWeight.w500,
                                fontFamily: fontFamily(),
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.type,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: fontSize,
                                    min: 0.5,
                                    max: 1.5,
                                    activeColor: Color(0XFF6366F1),
                                    inactiveColor: Colors.grey.shade200,
                                    divisions: 4,
                                    label: displaySliderValue(fontSize),
                                    onChanged: (double value) {
                                      settings.setFontSize(value);
                                    },
                                  ),
                                ),
                                Icon(
                                  LucideIcons.type,
                                  size: 22,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Color Theme
                      _buildSettingCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "color_theme".tr(),
                              style: TextStyle(
                                fontSize: 16 * fontSize,
                                fontWeight: FontWeight.w500,
                                fontFamily: fontFamily(),
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:
                                  _colorThemes.map((color) {
                                    return GestureDetector(
                                      onTap: () {
                                        settings.setColorIndex(
                                          _colorThemes.indexOf(color),
                                        );
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border:
                                              selectedColorIndex ==
                                                      _colorThemes.indexOf(
                                                        color,
                                                      )
                                                  ? Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  )
                                                  : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),
                      // Speech Rate
                      _buildSettingCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "speech_rate".tr(),
                              style: TextStyle(
                                fontSize: 16 * fontSize,
                                fontWeight: FontWeight.w500,
                                fontFamily: fontFamily(),
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.type,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: speechRate,
                                    min: 0.5,
                                    max: 1.5,
                                    activeColor: Color(0XFF6366F1),
                                    inactiveColor: Colors.grey.shade200,
                                    divisions: 4,
                                    label: displaySliderValue(speechRate),
                                    onChanged: (double value) {
                                      settings.setSpeechRate(value);
                                    },
                                  ),
                                ),
                                Icon(
                                  LucideIcons.type,
                                  size: 22,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Word Prediction & Dyslexia Font
                      _buildSettingCard(
                        child: Column(
                          children: [
                            
                            _buildSwitchSetting(
                              "dyslexia_friendly_font".tr(),
                              openDyslexic,
                              (value) => settings.setDyslexic(value),
                              fontSize,
                              fontFamily(),
                              LucideIcons.textSelect,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade100,
                            ),
                            _buildSwitchSetting(
                              "text_to_speech".tr(),
                              textToSpeech,
                              (value) => settings.setTextToSpeech(value),
                              fontSize,
                              fontFamily(),
                              LucideIcons.textSelect,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Focus & Timers Section
                      _buildSectionHeader(
                        "focus_and_timers".tr(),
                        fontSize,
                        fontFamily(),
                      ),
                      SizedBox(height: 16),

                      // Pomodoro Timers & Break Reminders
                      _buildSettingCard(
                        child: Column(
                          children: [
                            _buildSwitchSetting(
                              "pomodoro".tr(),
                              pomodoro,
                              (value) => settings.setPomodoro(value),
                              fontSize,
                              fontFamily(),
                              LucideIcons.timer,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade100,
                            ),
                            _buildSwitchSetting(
                              "reminders".tr(),
                              breakReminders,
                              (value) => settings.setReminders(value),
                              fontSize,
                              fontFamily(),
                              LucideIcons.bellRing,
                            ),
                          ],
                        ),
                      ),

                      // Add extra padding at the bottom for the floating navbar
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, double fontSize, String fontFamily) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20 * fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildSwitchSetting(
    String title,
    bool value,
    Function(bool) onChanged,
    double fontSize,
    String fontFamily,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Color(0XFF6366F1)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16 * fontSize,
                fontWeight: FontWeight.w500,
                fontFamily: fontFamily,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: Color(0XFF6366F1),
            inactiveTrackColor: Colors.grey.shade200,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
