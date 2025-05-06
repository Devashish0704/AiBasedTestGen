import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_generator/Data/quiz_history.dart';
import 'package:test_generator/services/local_cache_service.dart';
import 'package:rxdart/rxdart.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _historySubject = BehaviorSubject<List<QuizHistory>>();
  Stream<List<QuizHistory>> get historyStream => _historySubject.stream;
  bool _isInitialized = false;

  Future<List<QuizHistory>> fetchUserHistory(String userId,
      {bool forceRefresh = false}) async {
    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _isInitialized) {
      final cachedHistory = LocalCacheService.getQuizHistory();
      if (cachedHistory.isNotEmpty) {
        return cachedHistory;
      }
    }

    await Firebase.initializeApp();
    List<QuizHistory> historyData = [];

    try {
      final quizzesSnapshot = await _firestore
          .collection('user_answers')
          .doc(userId)
          .collection('quizzes')
          .orderBy('created_at', descending: true)
          .get();

      historyData = quizzesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['quiz_id'] = doc.id;
        return QuizHistory.fromJson(data);
      }).toList();

      // Cache the fetched data
      await LocalCacheService.cacheQuizHistory(historyData);
      _isInitialized = true;
      _historySubject.add(historyData);

      return historyData;
    } catch (e) {
      print('Error fetching history: $e');
      // Return cached data if available when fetch fails
      final cachedHistory = LocalCacheService.getQuizHistory();
      return cachedHistory;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizAnswers(
      String userId, String quizId) async {
    try {
      final answersSnapshot = await _firestore
          .collection('user_answers')
          .doc(userId)
          .collection('quizzes')
          .doc(quizId)
          .collection('answers')
          .orderBy('answered_at', descending: false)
          .get();

      return answersSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching quiz answers: $e');
      return [];
    }
  }

  void dispose() {
    _historySubject.close();
  }
}
