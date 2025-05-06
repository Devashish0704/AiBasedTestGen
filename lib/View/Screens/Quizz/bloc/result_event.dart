import 'package:equatable/equatable.dart';

abstract class ResultEvent extends Equatable {
  const ResultEvent();

  @override
  List<Object> get props => [];
}

class SaveQuizResult extends ResultEvent {
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final String quizTitle;
  final String quizIcon;
  final String quizDifficulty;
  final List<Map<String, dynamic>> questions;
  final List<int> userAnswers;

  const SaveQuizResult({
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.quizTitle,
    required this.quizIcon,
    required this.quizDifficulty,
    required this.questions,
    required this.userAnswers,
  });

  @override
  List<Object> get props => [
        quizId,
        userId,
        score,
        totalQuestions,
        quizTitle,
        quizIcon,
        quizDifficulty,
        questions,
        userAnswers
      ];
}
