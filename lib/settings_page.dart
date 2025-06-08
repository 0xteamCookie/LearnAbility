import "dart:convert";
import "dart:io"; // Import for File operations

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:logger/logger.dart";
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'repository/widgets/global_navbar.dart';
import 'accessibility_model.dart';
import 'models/supported_language.dart';
import 'utils/constants.dart';

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

  List<SupportedLanguage> _supportedLanguages = [];
  String? _selectedLanguageCode;
  bool _isLoadingLanguages = false;
  String? _languageError;
  bool _isUpdatingLanguage = false;

  @override
  void initState() {
    super.initState();
    _fetchSupportedLanguages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settings = Provider.of<AccessibilitySettings>(context, listen: false);
        if (_supportedLanguages.any((lang) => lang.code == settings.language)) {
          setState(() {
            _selectedLanguageCode = settings.language;
          });
        } else if (_supportedLanguages.isNotEmpty) {
          var defaultLang = _supportedLanguages.firstWhere((l) => l.code == 'en', orElse: () => _supportedLanguages.first);
          setState(() {
            _selectedLanguageCode = defaultLang.code;
          });
        }
      }
    });
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchSupportedLanguages() async {
    setState(() {
      _isLoadingLanguages = true;
      _languageError = null;
    });
    try {
      final String? authToken = await _getAuthToken();

      final response = await http.get(
        Uri.parse('${Constants.uri}/api/v1/translations/supported-languages'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null && authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _supportedLanguages = data.map((json) => SupportedLanguage.fromJson(json)).toList();
          final settings = Provider.of<AccessibilitySettings>(context, listen: false);
          if (_supportedLanguages.any((lang) => lang.code == settings.language)) {
            _selectedLanguageCode = settings.language;
          } else if (_supportedLanguages.isNotEmpty) {
            var defaultLang = _supportedLanguages.firstWhere((l) => l.code == 'en', orElse: () => _supportedLanguages.first);
            _selectedLanguageCode = defaultLang.code;
          }
        });
      } else if (response.statusCode == 401 && authToken != null) {
          logger.w('Failed to load languages due to auth error (401).');
          setState(() { _languageError = 'Authentication error. Please re-login.'; });
      } else {
        logger.e('Failed to load languages: ${response.statusCode} ${response.body}');
        setState(() {
          _languageError = 'Failed to load languages. Please try again.';
        });
      }
    } catch (e) {
      logger.e('Error fetching languages: $e');
      setState(() {
        _languageError = 'An error occurred: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLanguages = false;
        });
      }
    }
  }

  String _getLocaleFileName(String languageCode) {
    // Consistent naming with HybridAssetLoader
    if (languageCode.contains('-')) {
      return "$languageCode.json";
    }
    return "$languageCode.json";
  }

  Future<String> get _localTranslationsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/lang';
  }

  Future<bool> _isTranslationLocallyAvailable(String languageCode) async {
    if (languageCode == 'en') return true; // English is always bundled
    try {
      final localPath = await _localTranslationsPath;
      final fileName = _getLocaleFileName(languageCode);
      final filePath = '$localPath/$fileName';
      final fileExists = await File(filePath).exists();
      if (fileExists) {
        logger.i('Local translation file found for $languageCode at $filePath');
      }
      return fileExists;
    } catch (e) {
      logger.e('Error checking local translation for $languageCode: $e');
      return false;
    }
  }

  Future<bool> _generateAndSaveTranslation(String languageCode) async {
    if (languageCode == 'en') return true; // English is bundled

    final String? authToken = await _getAuthToken();
    if (authToken == null || authToken.isEmpty) {
      logger.w('Auth token not found, cannot generate/save translation for $languageCode');
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required to download languages.'), backgroundColor: Colors.orange),
          );
      }
      return false;
    }

    // 1. Ensure generation on backend
    try {
      logger.i('Requesting generation for $languageCode...');
      final genResponse = await http.post(
        Uri.parse('${Constants.uri}/api/v1/translations/$languageCode/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (genResponse.statusCode != 201 && genResponse.statusCode != 200) {
        logger.e('Backend failed to generate $languageCode: ${genResponse.statusCode} ${genResponse.body}');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('translation_generation_failed'.tr(args: [languageCode])), backgroundColor: Colors.red));
        return false;
      }
      logger.i('Generation request for $languageCode successful or already existed.');
    } catch (e) {
      logger.e('Error in generation request for $languageCode: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('error_generating_translation'.tr(args: [languageCode])), backgroundColor: Colors.red));
      return false;
    }

    // 2. Fetch the generated (or existing) translation file content
    try {
      logger.i('Fetching $languageCode.json from backend...');
      final fetchResponse = await http.get(
        Uri.parse('${Constants.uri}/api/v1/translations/$languageCode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (fetchResponse.statusCode == 200) {
        final String fileContent = utf8.decode(fetchResponse.bodyBytes); // Use utf8.decode for safety
        
        // 3. Save to local file
        final localStoredPath = await _localTranslationsPath; //path_provider's app doc dir + /lang
        await Directory(localStoredPath).create(recursive: true); 

        final fileName = _getLocaleFileName(languageCode);
        final filePath = '$localStoredPath/$fileName';
        final file = File(filePath);
        await file.writeAsString(fileContent);
        logger.i('Successfully fetched and saved $fileName to $filePath');
        return true;
      } else {
        logger.e('Failed to fetch $languageCode.json: ${fetchResponse.statusCode} ${fetchResponse.body}');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('translation_fetch_failed'.tr(args: [languageCode])), backgroundColor: Colors.red));
        return false;
      }
    } catch (e) {
      logger.e('Error fetching/saving $languageCode.json: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('translation_save_failed'.tr(args: [languageCode])), backgroundColor: Colors.red));
      return false;
    }
  }

  Future<void> _updateUserLanguagePreference(String languageCode) async {
    final settings = Provider.of<AccessibilitySettings>(context, listen: false);
    final String? previousSelectedLanguageCode = _selectedLanguageCode;

    setState(() {
      _selectedLanguageCode = languageCode;
      _isUpdatingLanguage = true;
    });

    bool preferenceSavedOnBackend = false;
    final String? authToken = await _getAuthToken();
    if (authToken != null && authToken.isNotEmpty) {
      try {
        final response = await http.put(
          Uri.parse('${Constants.uri}/api/v1/translations/user-language'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({'languageCode': languageCode}),
        );
        if (response.statusCode == 200) {
          logger.i('User language preference saved to backend for $languageCode.');
          preferenceSavedOnBackend = true;
        } else {
          logger.e('Failed to save user language preference to backend: ${response.statusCode}');
        }
      } catch (e) {
        logger.e('Error saving user language preference to backend: $e');
      }
    }

    if (!preferenceSavedOnBackend) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(authToken == null || authToken.isEmpty 
                                  ? 'Authentication required to save preference.'
                                  : 'failed_to_update_language_preference_on_server'.tr()), 
                      backgroundColor: Colors.orange),
        );
      }
    }

    bool localFileReady = false;
    if (languageCode == 'en') {
      localFileReady = true; // English is bundled, always ready
      logger.i('Selected language is English, using bundled version.');
    } else {
      bool alreadyExists = await _isTranslationLocallyAvailable(languageCode);
      if (alreadyExists) {
        logger.i('Translation for $languageCode already available locally.');
        localFileReady = true;
      } else {
        logger.i('Local translation for $languageCode not found, attempting to generate and save.');
        localFileReady = await _generateAndSaveTranslation(languageCode);
      }
    }

    if (localFileReady) {
      settings.setLanguage(languageCode);
      Locale newLocale;
      if (languageCode.contains('-')) {
        var parts = languageCode.split('-');
        newLocale = Locale(parts[0], parts[1]);
      } else {
        newLocale = Locale(languageCode);
      }
      await context.setLocale(newLocale);
      
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('language_set_to'.tr(args: [
                  _supportedLanguages.firstWhere((l) => l.code == languageCode, orElse: () => SupportedLanguage(code: languageCode, name: languageCode)).name
              ])),
              backgroundColor: const Color(0XFF6366F1),
            ),
          );
      }
    } else {
      logger.w('Translation file for $languageCode not made available. UI might not update as expected.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_load_language_pack'.tr(args: [languageCode])), backgroundColor: Colors.red),
        );
        setState(() { _selectedLanguageCode = previousSelectedLanguageCode; });
      }
    }
    if (mounted) {
      setState(() { _isUpdatingLanguage = false; });
    }
  }

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
                Padding(
                  padding: const EdgeInsets.only(left: 48.0),
                  child: Text(
                    "customize_learning".tr(),
                    style: TextStyle(
                      fontSize: 16 * settings.fontSize,
                      fontFamily: fontFamily(),
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                )
              ],
            ),
          ),
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
    if (_isLoadingLanguages) {
      return const Card(child: Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())));
    }
    if (_languageError != null) {
      return Card(
        color: Colors.red[50],
        child: ListTile(
          title: Text('error_loading_languages'.tr(), style: TextStyle(color: Colors.red[700])),
          subtitle: Text(_languageError!, style: TextStyle(color: Colors.red[700])),
          trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchSupportedLanguages, color: Colors.red[700]),
        )
      );
    }
    if (_supportedLanguages.isEmpty && !_isLoadingLanguages) {
       return Card(child: ListTile(title: Text("no_languages_available".tr())));
    }

    String? currentDropdownValue = _selectedLanguageCode;
    if (_supportedLanguages.isNotEmpty && (currentDropdownValue == null || !_supportedLanguages.any((lang) => lang.code == currentDropdownValue))) {
        currentDropdownValue = _supportedLanguages.firstWhere((l) => l.code == 'en', orElse: () => _supportedLanguages.first).code;
    }
    
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
        trailing: AbsorbPointer(
          absorbing: _isUpdatingLanguage,
          child: Opacity(
            opacity: _isUpdatingLanguage ? 0.5 : 1.0,
            child: DropdownButton<String>(
              value: currentDropdownValue,
              items: _supportedLanguages.map<DropdownMenuItem<String>>((SupportedLanguage language) {
                return DropdownMenuItem<String>(
                  value: language.code,
                  child: Text(
                    language.name, 
                    style: TextStyle(fontFamily: fontFamily()),
                  ),
                );
              }).toList(),
              onChanged: _isUpdatingLanguage ? null : (String? newValue) {
                if (newValue != null && newValue != _selectedLanguageCode) {
                  _updateUserLanguagePreference(newValue);
                }
              },
              hint: _isLoadingLanguages || (_supportedLanguages.isEmpty && currentDropdownValue == null) 
                    ? const Text("Loading...") 
                    : _isUpdatingLanguage ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3,)) : null,
            ),
          ),
        ),
      ),
    );
  }
}

// New localization keys you might need:
// "translation_fetch_failed": "Failed to download translation for {}."
// "translation_save_failed": "Failed to save translation for {}."
// "failed_to_update_language_preference_on_server": "Could not save language choice to server."
// "failed_to_load_language_pack": "Failed to load language pack for {}."