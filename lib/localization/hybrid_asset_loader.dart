import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart'; // For Locale
import 'package:flutter/services.dart' show rootBundle; // For loading bundled assets
import 'package:easy_localization/easy_localization.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

final Logger _logger = Logger();

class HybridAssetLoader extends AssetLoader {
  const HybridAssetLoader();

  // Helper to get the language code string in the format backend expects (e.g., 'en', 'zh-CN')
  // This is also used for naming the local files.
  String getFileNameForLocale(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return "${locale.languageCode}-${locale.countryCode}.json";
    }
    return "${locale.languageCode}.json";
  }

  Future<String> get _localTranslationsPath async {
    final directory = await getApplicationDocumentsDirectory();
    final langDirPath = '${directory.path}/lang';
    // Ensure the lang directory exists
    final langDir = Directory(langDirPath);
    if (!await langDir.exists()) {
      await langDir.create(recursive: true);
    }
    return langDirPath;
  }

  @override
  Future<Map<String, dynamic>> load(String assetPath, Locale locale) async {
    final fileName = getFileNameForLocale(locale);
    _logger.i('HybridAssetLoader: Loading translations for locale: $locale, targeting file: $fileName');

    if (locale.languageCode == 'en') {
      // Load English directly from bundled assets
      _logger.d('HybridAssetLoader: Loading English from bundled assets: $assetPath/$fileName');
      try {
        final jsonString = await rootBundle.loadString('$assetPath/$fileName');
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        _logger.i('HybridAssetLoader: Successfully loaded bundled English translations.');
        return jsonData;
      } catch (e) {
        _logger.e('HybridAssetLoader: Error loading bundled English translations from $assetPath/$fileName: $e');
        return {}; // Fallback for English
      }
    } else {
      // For other languages, try to load from local app documents directory
      try {
        final localPath = await _localTranslationsPath;
        final filePath = '$localPath/$fileName';
        final file = File(filePath);

        if (await file.exists()) {
          _logger.d('HybridAssetLoader: Loading $fileName from local file: $filePath');
          final jsonString = await file.readAsString();
          final Map<String, dynamic> jsonData = jsonDecode(jsonString);
          _logger.i('HybridAssetLoader: Successfully loaded $fileName from local storage.');
          return jsonData;
        } else {
          _logger.w('HybridAssetLoader: Local translation file not found for $fileName at $filePath. EasyLocalization will use fallback.');
          return {}; // File not found, EasyLocalization will use its fallback mechanism
        }
      } catch (e) {
        _logger.e('HybridAssetLoader: Error loading $fileName from local storage: $e');
        return {}; // Error reading file, fallback
      }
    }
  }
} 