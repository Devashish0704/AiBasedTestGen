import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/subjects.dart';

class FirebaseQuizService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _uploadProgressController = BehaviorSubject<double>();

  static Stream<double> get uploadProgress => _uploadProgressController.stream;

  /// Uploads the quiz metadata first, then streams questions as they become available
  static Future<String?> uploadQuiz(String quizJson) async {
    try {
      final Map<String, dynamic> quizData = jsonDecode(quizJson);
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // 1. Create quiz document with metadata first
      final quizDoc = await _firestore.collection('quizzes').add({
        'created_at': FieldValue.serverTimestamp(),
        'topic': quizData['topic'] ?? 'General',
        'difficulty': (quizData['level'] ?? 'Medium').toString().toLowerCase(),
        'quiz_type': 'MCQ',
        'userId': userId,
        'quiz_icon': quizData['quiz_icon'] ?? 'book',
        'total_questions': quizData['questions']?.length ?? 0,
      });

      // 2. Upload questions incrementally
      final questions = List<Map<String, dynamic>>.from(quizData['questions']);
      final questionsRef = quizDoc.collection('questions');
      final totalQuestions = questions.length;

      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        await questionsRef.add({
          'question': q['question'],
          'options': q['options'],
          'correct_answer': q['options'][q['correctIndex']],
          'question_type': 'MCQ',
          'order': i,
        });

        // Update upload progress
        _uploadProgressController.add((i + 1) / totalQuestions);
      }

      return quizDoc.id;
    } catch (e) {
      print("❌ Error uploading quiz: $e");
      return null;
    }
  }

  static Future<String?> uploadQuizIncrementally(
    Map<String, dynamic> metadata,
    Stream<Map<String, dynamic>> questionsStream,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // 1. Create quiz document with metadata
      final quizDoc = await _firestore.collection('quizzes').add({
        'created_at': FieldValue.serverTimestamp(),
        'topic': metadata['topic'] ?? 'General',
        'difficulty': (metadata['level'] ?? 'Medium').toString().toLowerCase(),
        'quiz_type': 'MCQ',
        'userId': userId,
        'quiz_icon': metadata['quiz_icon'] ?? 'book',
        'total_questions': metadata['total_questions'] ?? 0,
      });

      // 2. Listen to question stream and upload each question as it arrives
      final batch = _firestore.batch();
      var questionCount = 0;
      final questionsRef = quizDoc.collection('questions');

      await for (final question in questionsStream) {
        final questionDoc = questionsRef.doc();
        batch.set(questionDoc, {
          'question': question['question'],
          'options': question['options'],
          'correct_answer': question['options'][question['correctIndex']],
          'question_type': 'MCQ',
          'order': questionCount,
        });

        questionCount++;
        if (questionCount % 20 == 0) {
          // Commit batch every 20 questions
          await batch.commit();
        }

        // Update upload progress
        _uploadProgressController
            .add(questionCount / metadata['total_questions']);
      }

      // Commit any remaining questions
      if (questionCount % 20 != 0) {
        await batch.commit();
      }

      return quizDoc.id;
    } catch (e) {
      print("❌ Error uploading quiz: $e");
      return null;
    }
  }

  static void dispose() {
    _uploadProgressController.close();
  }
}
