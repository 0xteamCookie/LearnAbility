import "package:flutter/material.dart";
import "package:logger/logger.dart";
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'repository/widgets/global_navbar.dart';
import 'accessibility_model.dart';

final Logger logger = Logger();

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingsPage> {
  final List<Map<String, dynamic>> _privacySettings = [
    {
      "title": "Learning Data Collection",
      "subtitle":
          "Allow us to collect data to personalize your learning experience",
      "value": false,
      "key": "learningDataCollection",
    },
    {
      "title": "Share Progress with Teachers",
      "subtitle": "Allow teachers to view your learning progress",
      "value": false,
      "key": "shareProgressWithTeachers",
    },
    {
      "title": "AI Learning History",
      "subtitle": "Store your AI assistant chat history",
      "value": false,
      "key": "aiLearningHistory",
    },
  ];

  final List<Map<String, dynamic>> _notificationSettings = [
    {
      "title": "Email Notifications",
      "subtitle": "Receive emails about your learning progress",
      "value": false,
      "key": "emailNotifications",
    },
    {
      "title": "Browser Notifications",
      "subtitle": "Allow desktop notifications from the app",
      "value": false,
      "key": "browserNotifications",
    },
  ];

  final List<Map<String, dynamic>> _generalSettings = [
    {
      "title": "Select Language",
      "subtitle": "Select your preferred medium of learning",
      "value": false,
      "key": "emailNotifications",
    },
  ];

  void _saveChanges() {
    logger.d("Changes saved");
    logger.d({
      "privacySettings": _privacySettings,
      "notificationSettings": _notificationSettings,
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Settings saved successfully"),
        backgroundColor: Color(0XFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _updateSetting(
    List<Map<String, dynamic>> settingsList,
    String key,
    bool value,
  ) {
    setState(() {
      final setting = settingsList.firstWhere(
        (setting) => setting["key"] == key,
      );
      setting["value"] = value;
    });
  }

  @override
  void initState() {
    super.initState();
    // Set the correct index when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessibilitySettings>(
        context,
        listen: false,
      ).setSelectedIndex(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
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
                          "Settings",
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
                      "Customize your learning experience",
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
                child: ListView(
                  padding: EdgeInsets.all(20.0),
                  children: [
                    // General Settings Section
                    _buildSectionHeader(
                      'General Settings',
                      settings,
                      fontFamily(),
                    ),
                    SizedBox(height: 12),

                    for (var setting in _generalSettings)
                      _buildGeneralSettingsCard(
                        setting,
                        settings,
                        fontFamily(),
                      ),

                    SizedBox(height: 24),

                    // Privacy Settings Section
                    _buildSectionHeader(
                      'Privacy Settings',
                      settings,
                      fontFamily(),
                    ),
                    SizedBox(height: 12),

                    for (var setting in _privacySettings)
                      _buildSettingsCard(
                        setting,
                        _privacySettings,
                        settings,
                        fontFamily(),
                      ),

                    SizedBox(height: 24),

                    // Notification Settings Section
                    _buildSectionHeader(
                      'Notification Settings',
                      settings,
                      fontFamily(),
                    ),
                    SizedBox(height: 12),

                    for (var setting in _notificationSettings)
                      _buildSettingsCard(
                        setting,
                        _notificationSettings,
                        settings,
                        fontFamily(),
                      ),

                    SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0XFF6366F1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _saveChanges,
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16 * settings.fontSize,
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamily(),
                        ),
                      ),
                    ),

                    // Add extra padding at the bottom for the floating navbar
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18 * settings.fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    Map<String, dynamic> setting,
    List<Map<String, dynamic>> settingsList,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: SwitchListTile(
        title: Text(
          setting["title"],
          style: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Text(
          setting["subtitle"],
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily,
            color: Colors.grey.shade600,
          ),
        ),
        value: setting["value"],
        onChanged: (value) {
          _updateSetting(settingsList, setting["key"], value);
        },
        activeColor: Color(0XFF6366F1),
        inactiveTrackColor: Colors.grey.shade200,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildGeneralSettingsCard(
    Map<String, dynamic> setting,
    AccessibilitySettings settings,
    String fontFamily,
  ) {
    if (setting["title"] == "Select Language") {
      return Container(
        margin: EdgeInsets.only(bottom: 12),
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
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            setting["title"],
            style: TextStyle(
              fontSize: 16 * settings.fontSize,
              fontWeight: FontWeight.w500,
              fontFamily: fontFamily,
              color: Color(0xFF1F2937),
            ),
          ),
          subtitle: Text(
            setting["subtitle"],
            style: TextStyle(
              fontSize: 14 * settings.fontSize,
              fontFamily: fontFamily,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: Consumer<AccessibilitySettings>(
            builder: (context, settings, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0XFF6366F1).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: DropdownButton<String>(
                  value: settings.language,
                  items:
                      ["English", "Hindi"]
                          .map(
                            (language) => DropdownMenuItem<String>(
                              value: language,
                              child: Text(
                                language,
                                style: TextStyle(
                                  fontSize: 14 * settings.fontSize,
                                  fontFamily: fontFamily,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      settings.setLanguage(newValue);
                    }
                  },
                  underline: Container(), // Removes the default underline
                  icon: Icon(
                    LucideIcons.chevronDown,
                    color: Color(0XFF6366F1),
                    size: 18,
                  ),
                  elevation: 2,
                  isDense: true,
                  style: TextStyle(
                    fontSize: 14 * settings.fontSize,
                    fontFamily: fontFamily,
                    color: Color(0xFF1F2937),
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ),
      );
    }

    // Keep the switch for other general settings (if any)
    return _buildSettingsCard(setting, _generalSettings, settings, fontFamily);
  }
}
