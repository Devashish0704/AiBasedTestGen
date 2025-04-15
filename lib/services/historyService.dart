import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUserHistory(String userId) async {
    await Firebase.initializeApp();
    List<Map<String, dynamic>> historyData = [];


    try {
      final quizzesSnapshot = await _firestore
          .collection('user_answers')
          .doc(userId)
          .collection('quizzes')
          .orderBy('created_at', descending: true)
          .get();

      for (final quizDoc in quizzesSnapshot.docs) {
        final quizId = quizDoc.id;
        final quizData = quizDoc.data();

        final score = quizData['score'] ?? 0;
        final totalQuestions = quizData['total_questions'] ?? 0;
        final title = quizData['quiz_title'] ?? 'Untitled Quiz';
        final date = quizData['created_at']?.toDate()?.toString().split(' ')[0] ?? 'Unknown Date';
        final iconName = quizData['quiz_icon'] ?? 'Icons.help';
        final icon = _getIconFromString(iconName);


        // Fetch user answers
        final answersSnapshot = await _firestore
            .collection('user_answers')
            .doc(userId)
            .collection('quizzes')
            .doc(quizId)
            .collection('answers')
            .get();

        final List<int> userAnswers = [];
        final List<Map<String, dynamic>> questionsData = [];

        for (final answerDoc in answersSnapshot.docs) {
          final answerData = answerDoc.data();
          userAnswers.add(answerData['selected_answer'] ?? -1);
          questionsData.add({
            'question': answerData['question'] ?? '',
            'is_correct': answerData['is_correct'] ?? false,
            'selected_answer': answerData['selected_answer'],
            'answered_at': answerData['answered_at'],
          });
        }

        historyData.add({
          'title': title,
          'questions': totalQuestions,
          'score': score,
          'icon': icon,
          'date': date,
          'userAnswers': userAnswers,
          'questions_data': questionsData,
        });
      }
    } catch (e) {
      print('❌ Error fetching history for userId: $userId - $e');
    }

    return historyData;
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'Icons.code':
        return Icons.code;
      case 'Icons.storage':
        return Icons.storage;
      case 'Icons.web':
        return Icons.web;
      case 'Icons.design_services':
        return Icons.design_services;
      default:
        return Icons.help_outline;
    }
  }
}
