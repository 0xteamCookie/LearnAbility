import "package:flutter/material.dart";
import "package:logger/logger.dart";

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
    // Implement save functionality here
    logger.d("Changes saved");
    logger.d({
      "privacySettings": _privacySettings,
      "notificationSettings": _notificationSettings,
    });
  }

  void _updateSetting(List<Map<String, dynamic>> settingsList, String key, bool value) {
    setState(() {
      // Find the setting by key and update its value
      final setting = settingsList.firstWhere((setting) => setting["key"] == key);
      setting["value"] = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "LearnAbility",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Privacy Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          for (var setting in _privacySettings) _buildPrivacySettingsCard(setting),
          SizedBox(height: 24),
          Text(
            'Notification Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          for (var setting in _notificationSettings) _buildNotificationSettingsCard(setting),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveChanges,
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
  Widget _buildPrivacySettingsCard(Map<String, dynamic> setting) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(
          setting["title"],
          style: TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          setting["subtitle"],
          style: TextStyle(fontSize: 14),
        ),
        value: setting["value"],
        onChanged: (value) {
          _updateSetting(_privacySettings, setting["key"], value);
        },
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildNotificationSettingsCard(Map<String, dynamic> setting) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(
          setting["title"],
          style: TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          setting["subtitle"],
          style: TextStyle(fontSize: 14),
        ),
        value: setting["value"],
        onChanged: (value) {
          _updateSetting(_notificationSettings, setting["key"], value);
        },
        activeColor: Colors.blue,
      ),
    );
  }
}