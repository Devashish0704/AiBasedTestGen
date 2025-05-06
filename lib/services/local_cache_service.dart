import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_generator/Data/quiz_history.dart';

class LocalCacheService {
  static const String _quizHistoryBoxName = 'quiz_history';
  static Box<QuizHistory>? _quizHistoryBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(QuizHistoryAdapter());
    _quizHistoryBox = await Hive.openBox<QuizHistory>(_quizHistoryBoxName);
  }

  static Future<void> cacheQuizHistory(List<QuizHistory> history) async {
    await _quizHistoryBox?.clear();
    for (var item in history) {
      await _quizHistoryBox?.put(item.quizId, item);
    }
  }

  static List<QuizHistory> getQuizHistory() {
    return _quizHistoryBox?.values.toList() ?? [];
  }

  static Future<void> addQuizHistory(QuizHistory history) async {
    await _quizHistoryBox?.put(history.quizId, history);
  }

  static Future<void> clearCache() async {
    await _quizHistoryBox?.clear();
  }
}
