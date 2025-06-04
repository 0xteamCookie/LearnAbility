import "package:flutter/material.dart";
import "package:logger/logger.dart";
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'repository/widgets/global_navbar.dart';
import 'accessibility_model.dart';

final Logger logger = Logger();

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingsPage> {
  final List<Map<String, String>> _privacySettings = [
    {
      "title": "learning_data_collection",
      "subtitle": "allow_us_to_collect_data",
      "key": "learningDataCollection",
    },
    {
      "title": "share_progress_with_teachers",
      "subtitle": "allow_teachers_to_view_progress",
      "key": "shareProgressWithTeachers",
    },
    {
      "title": "ai_learning_history",
      "subtitle": "store_ai_assistant_chat_history",
      "key": "aiLearningHistory",
    },
  ];

  final List<Map<String, String>> _notificationSettings = [
    {
      "title": "email_notifications",
      "subtitle": "receive_emails_about_progress",
      "key": "emailNotifications",
    },
    {
      "title": "browser_notifications",
      "subtitle": "allow_desktop_notifications",
      "key": "browserNotifications",
    },
  ];

  final List<Map<String, String>> _generalSettings = [
    {
      "title": "select_language",
      "subtitle": "select_preferred_learning_medium",
      "key": "selectLanguage",
    },
  ];

  final Map<String, bool> _settingsValues = {
    "learningDataCollection": false,
    "shareProgressWithTeachers": false,
    "aiLearningHistory": false,
    "emailNotifications": false,
    "browserNotifications": false,
  };

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("settings_saved".tr()),
        backgroundColor: const Color(0XFF6366F1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AccessibilitySettings>(context);
    final bool isDyslexic = settings.openDyslexic;

    String fontFamily() => isDyslexic ? "OpenDyslexic" : "Roboto";

    return GlobalNavBar(
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0XFF6366F1), Color(0XFF8B5CF6)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "settings".tr(),
                      style: TextStyle(
                        fontSize: 24 * settings.fontSize,
                        fontFamily: fontFamily(),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  "customize_learning".tr(),
                  style: TextStyle(
                    fontSize: 16 * settings.fontSize,
                    fontFamily: fontFamily(),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection('general_settings'.tr(), _generalSettings, settings, fontFamily),
                const SizedBox(height: 24),
                _buildSection('privacy_settings'.tr(), _privacySettings, settings, fontFamily),
                const SizedBox(height: 24),
                _buildSection('notification_settings'.tr(), _notificationSettings, settings, fontFamily),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('save_changes'.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Map<String, String>> settingsList,
    AccessibilitySettings settings,
    String Function() fontFamily,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
        const SizedBox(height: 12),
        ...settingsList.map((setting) => _buildSettingCard(setting, settings, fontFamily)),
      ],
    );
  }

  Widget _buildSettingCard(
    Map<String, String> setting,
    AccessibilitySettings settings,
    String Function() fontFamily,
  ) {
    if (setting["key"] == "selectLanguage") {
      return _buildLanguageSelector(settings, fontFamily);
    }

    final String key = setting["key"]!;
    return Card(
      color: Colors.white,
      elevation: 2,
      child: SwitchListTile(
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.white,
        title: Text(
          setting["title"]!.tr(),
          style: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
        subtitle: Text(
          setting["subtitle"]!.tr(),
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
        value: _settingsValues[key] ?? false,
        onChanged: (bool? value) {
          if (value != null) {
            setState(() {
              _settingsValues[key] = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildLanguageSelector(AccessibilitySettings settings, String Function() fontFamily) {
    // Get the current language in lowercase to match dropdown values
    final currentLanguage = settings.language.toLowerCase();
    
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 2,
      child: ListTile(
        title: Text(
          "select_language".tr(),
          style: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
        subtitle: Text(
          "select_preferred_learning_medium".tr(),
          style: TextStyle(
            fontSize: 14 * settings.fontSize,
            fontFamily: fontFamily(),
          ),
        ),
        trailing: DropdownButton<String>(
          value: currentLanguage,
          items: [
            DropdownMenuItem(
              value: "english",
              child: Text(
                "english".tr(),
                style: TextStyle(
                  fontFamily: fontFamily(),
                ),
              ),
            ),
            DropdownMenuItem(
              value: "hindi",
              child: Text(
                "hindi".tr(),
                style: TextStyle(
                  fontFamily: fontFamily(),
                ),
              ),
            ),
          ],
          onChanged: (String? value) async {
            if (value != null) {
              settings.setLanguage(value);
              await context.setLocale(value == "english" ? const Locale('en') : const Locale('hi'));
              if (mounted) setState(() {});
            }
          },
        ),
      ),
    );
  }
}