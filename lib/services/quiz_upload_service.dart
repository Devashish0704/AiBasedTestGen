import 'dart:convert'; // For jsonDecode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String userId = FirebaseAuth.instance.currentUser!.uid;

class FirebaseQuizService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Uploads the quiz (as JSON string), decodes it, and uploads to Firestore
  static Future<String?> uploadQuiz(String quizJson) async {
    try {
      final Map<String, dynamic> quizData = jsonDecode(quizJson);

      print("Quiz Data icon: ${quizData['quiz_icon']}");

      final topic = quizData['topic'] ?? 'General';
      final description = quizData['description'] ?? '';
      final level = (quizData['level'] ?? 'Medium').toString().toLowerCase();
      final questions = List<Map<String, dynamic>>.from(quizData['questions']);
      final icon = quizData['quiz_icon'] ?? 'Icons.storage'; // Default icon

      // 1. Add metadata to `quizzes` collection
      final quizDoc = await _firestore.collection('quizzes').add({
        'created_at': FieldValue.serverTimestamp(),
        'topic': topic,
        'description': description,
        'difficulty': level,
        'quiz_type': 'MCQ',
        'userId': userId,
        'quiz_icon': icon,
      });

      // 2. Add each question to subcollection `questions`
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
