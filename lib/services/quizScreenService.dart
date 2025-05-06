import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class QuizScreenService {
  Future<List<Map<String, dynamic>>> fetchQuizQuestions(String quizId) async {
    await Firebase.initializeApp();

    try {
      final quizRef =
          FirebaseFirestore.instance.collection('quizzes').doc(quizId);
      final questionsSnapshot = await quizRef.collection('questions').get();

      return questionsSnapshot.docs.map((doc) {
        final data = doc.data();
        final correctAnswer = data['correct_answer'];
        final options = List<String>.from(data['options']);
        final correctIndex = options.indexOf(correctAnswer);

        return {
          'id': doc.id,
          'question': data['question'],
          'options': options,
          'correctIndex': correctIndex,
        };
      }).toList();
    } catch (e) {
      print('Error fetching quiz data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuizDetails(String quizId) async {
    try {
      final quizRef =
          FirebaseFirestore.instance.collection('quizzes').doc(quizId);
      final quizSnapshot = await quizRef.get();

      if (!quizSnapshot.exists) {
        return [];
      }

      final quizData = quizSnapshot.data() ?? {};
      return [
        {
          'topic': quizData['topic'] ?? 'General Quiz',
          'quiz_icon': quizData['quiz_icon'] ?? 'book',
          'difficulty': quizData['difficulty'] ?? 'medium'
        }
      ];
    } catch (e) {
      print('Error fetching quiz data: $e');
      return [];
    }
  }

  Future<void> saveQuizHistory({
    required String userId,
    required String quizId,
    required int score,
    required int total_questions,
    required String quizTitle,
    required String quizIcon,
    required String quizDifficulty,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('user_answers')
        .doc(userId)
        .collection('quizzes')
        .doc(quizId);

    await docRef.set({
      'quiz_id': quizId,
      'quiz_title': quizTitle,
      'quiz_icon': quizIcon,
      'difficulty': quizDifficulty,
      'score': score,
      'total_questions': total_questions,
      'accuracy': (score / total_questions) * 100,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveUserAnswer({
    required String userId,
    required String quizId,
    required String questionId,
    required String selectedOption,
    required String correctAnswer,
    required bool isCorrect,
    required String question,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('user_answers')
        .doc(userId)
        .collection('quizzes')
        .doc(quizId)
        .collection('answers')
        .doc(questionId);

    await docRef.set({
      'question': question,
      'selected_option': selectedOption,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'answered_at': FieldValue.serverTimestamp(),
    });
  }
}
