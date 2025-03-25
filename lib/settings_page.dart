import "package:flutter/material.dart";
import "package:logger/logger.dart";
import 'package:provider/provider.dart';
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
      "subtitle": "Allow us to collect data to personalize your learning experience",
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

  void _saveChanges() {
    logger.d("Changes saved");
    logger.d({
      "privacySettings": _privacySettings,
      "notificationSettings": _notificationSettings,
    });
  }

  void _updateSetting(List<Map<String, dynamic>> settingsList, String key, bool value) {
    setState(() {
      final setting = settingsList.firstWhere((setting) => setting["key"] == key);
      setting["value"] = value;
    });
  }

   @override
  void initState() {
    super.initState();
    // Set the correct index when this page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccessibilitySettings>(context, listen: false).setSelectedIndex(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() {
      return isDyslexic ? "OpenDyslexic" : "Roboto";
    }

    return SafeArea(
      child: GlobalNavBar(
        body: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.all(16.0),
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
                    "Settings",
                    style: TextStyle(
                      fontSize: 24 * settings.fontSize,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Privacy Settings',
                style: TextStyle(
                  fontSize: 22 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              SizedBox(height: 16),
        
              for (var setting in _privacySettings)
                _buildPrivacySettingsCard(setting, settings, fontFamily()),
              SizedBox(height: 24),
              Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 22 * settings.fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily(), // Added fontFamily
                ),
              ),
              SizedBox(height: 16),
        
              for (var setting in _notificationSettings)
                _buildNotificationSettingsCard(setting, settings, fontFamily()),
              SizedBox(height: 24),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.grey[100]), // Correct way to set grey[100]
                  ),
                  onPressed: _saveChanges,
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(), // Added fontFamily
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySettingsCard(
    Map<String, dynamic> setting,
    AccessibilitySettings settings,
    String fontFamily, // Added fontFamily parameter
  ) {
    return Card(
      color: Colors.grey[100],
      margin: EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(
          setting["title"],
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily, // Added fontFamily
          ),
        ),
        subtitle: Text(
          setting["subtitle"],
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily, // Added fontFamily
          ),
        ),
        value: setting["value"],
        onChanged: (value) {
          _updateSetting(_privacySettings, setting["key"], value);
        },
        activeColor: Colors.deepPurple,
        inactiveTrackColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildNotificationSettingsCard(
    Map<String, dynamic> setting,
    AccessibilitySettings settings,
    String fontFamily, // Added fontFamily parameter
  ) {
    return Card(
      color: Colors.grey[100],
      margin: EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(
          setting["title"],
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily, // Added fontFamily
          ),
        ),
        subtitle: Text(
          setting["subtitle"],
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily, // Added fontFamily
          ),
        ),
        value: setting["value"],
        onChanged: (value) {
          _updateSetting(_notificationSettings, setting["key"], value);
        },
        activeColor: Colors.deepPurple,
        inactiveTrackColor: Colors.grey[200],
      ),
    );
  }
}