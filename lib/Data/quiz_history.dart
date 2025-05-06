import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'quiz_history.g.dart';

@HiveType(typeId: 0)
class QuizHistory extends HiveObject {
  @HiveField(0)
  final String quizId;

  @HiveField(1)
  final String quizTitle;

  @HiveField(2)
  final String quizIcon;

  @HiveField(3)
  final String difficulty;

  @HiveField(4)
  final int score;

  @HiveField(5)
  final int totalQuestions;

  @HiveField(6)
  final double accuracy;

  @HiveField(7)
  final DateTime createdAt;

  QuizHistory({
    required this.quizId,
    required this.quizTitle,
    required this.quizIcon,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.createdAt,
  });

  factory QuizHistory.fromJson(Map<String, dynamic> json) {
    return QuizHistory(
      quizId: json['quiz_id'] ?? '',
      quizTitle: json['quiz_title'] ?? '',
      quizIcon: json['quiz_icon'] ?? '',
      difficulty: json['difficulty'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'quiz_id': quizId,
        'quiz_title': quizTitle,
        'quiz_icon': quizIcon,
        'difficulty': difficulty,
        'score': score,
        'total_questions': totalQuestions,
        'accuracy': accuracy,
        'created_at': createdAt,
      };
}
