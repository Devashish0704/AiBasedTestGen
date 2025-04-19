import 'package:flutter/material.dart';
import 'package:test_generator/Data/quiz_settings.dart';

class QuizSettingsProvider with ChangeNotifier {
  QuizSettings _settings = QuizSettings();

  QuizSettings get settings => _settings;

  void updateSettings(QuizSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void updateQuestionType(String type) {
    _settings.questionType = type;
    notifyListeners();
  }

  void updateFrom(String from) {
    _settings.from = from;
    notifyListeners();
  }

  void updateDifficulty(String difficulty) {
    _settings.difficulty = difficulty;
    notifyListeners();
  }
}
