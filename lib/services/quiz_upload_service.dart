import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

 String userId = FirebaseAuth.instance.currentUser!.uid;

class FirebaseQuizService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  /// Uploads the generated quiz and returns the quiz document ID
  static Future<String?> uploadQuiz(List<Map<String, dynamic>> questions) async {
    try {
      // 1. Add quiz metadata to `quizzes` collection
      final quizDoc = await _firestore.collection('quizzes').add({
        'created_at': FieldValue.serverTimestamp(),
        'description': 'Quiz on UI/UX fundamentals',
        'difficulty': 'medium',
        'quiz_type': 'MCQ',
        'topic': 'UI/UX Design',
        'userId': userId,
      });

      // 2. Upload each question to subcollection `questions`
      final questionsRef = quizDoc.collection('questions');

      for (var q in questions) {
        await questionsRef.add({
          'question': q['question'],
          'options': q['options'],
          'correct_answer': q['options'][q['correctIndex']],
          'question_type': 'MCQ',
        });
      }

      return quizDoc.id;
    } catch (e) {
      print("❌ Error uploading quiz: $e");
      return null;
    }
  }
}
