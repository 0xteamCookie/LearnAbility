import 'package:flutter/material.dart';

class AccessibilitySettings extends ChangeNotifier {
  double _fontSize = 1.0;
  bool _openDyslexic = false;
  double _speechRate = 0.5;
  bool _wordPrediction = false;
  bool _pomodoro = false;
  bool _reminders = false;
  bool _textToSpeech = false;
  bool _voiceAssisstant = false;
  bool _callStatus = false;
  int _selectedColorIndex = 0;
  int _selectedIndexBottomNavBar = 2;
  String _language = 'English';

  double get fontSize => _fontSize;
  bool get callStatus => _callStatus;
  bool get openDyslexic => _openDyslexic;
  double get speechRate => _speechRate;
  bool get wordPrediction => _wordPrediction;
  bool get textToSpeech => _textToSpeech;
  bool get pomodoro => _pomodoro;
  bool get reminders => _reminders;
  bool get voiceAssisstant => _voiceAssisstant;
  int get selectedColorIndex => _selectedColorIndex;
  int get selectedIndexBottomNavBar => _selectedIndexBottomNavBar;
  String get language => _language;

  void setCallStatus(bool value){
    _callStatus = value;
    notifyListeners();
  }
  
  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }

  void setDyslexic(bool value) {
    _openDyslexic = value;
    notifyListeners();
  }

  void setTextToSpeech(bool value) {
    _textToSpeech = value;
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

  void setPomodoro(bool value) {
    _pomodoro = value;
    notifyListeners();
  }

  void setVoiceAssisstant(bool value) {
    _voiceAssisstant = value;
    notifyListeners();
  }

  void setReminders(bool value) {
    _reminders = value;
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
