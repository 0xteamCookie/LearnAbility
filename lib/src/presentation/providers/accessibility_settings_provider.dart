import 'package:flutter/material.dart';

class AccessibilitySettings extends ChangeNotifier {
  double _fontSize = 1.0;
  bool _openDyslexic = false;
  double _speechRate = 0.5;
  bool _wordPrediction = false;
  bool _visualTimers = false;
  bool _breakReminders = false;
  int _selectedColorIndex = 0;
  int _selectedIndexBottomNavBar = 2;
  String _language = 'English';

  double get fontSize => _fontSize;
  bool get openDyslexic => _openDyslexic;
  double get speechRate => _speechRate;
  bool get wordPrediction => _wordPrediction;
  bool get visualTimers => _visualTimers;
  bool get breakReminders => _breakReminders;
  int get selectedColorIndex => _selectedColorIndex;
  int get selectedIndexBottomNavBar => _selectedIndexBottomNavBar;
  String get language => _language;

  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }

  void setDyslexic(bool value) {
    _openDyslexic = value;
    notifyListeners();
  }

  void setSpeechRate(double value) {
    _speechRate = value;
    notifyListeners();
  }

  void setWordPrediction(bool value) {
    _wordPrediction = value;
    notifyListeners();
  }

  void setVisualTimers(bool value) {
    _visualTimers = value;
    notifyListeners();
  }

  void setBreakReminders(bool value) {
    _breakReminders = value;
    notifyListeners();
  }

  void setColorIndex(int index) {
    _selectedColorIndex = index;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndexBottomNavBar = index;
    notifyListeners();
  }

  void setLanguage(String newLanguage) {
    _language = newLanguage;
    notifyListeners();
  }
}
