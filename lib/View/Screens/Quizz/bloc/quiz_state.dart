import 'package:equatable/equatable.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<Map<String, dynamic>> questions;
  final String quizName;
  final String quizIcon;
  final String quizDifficulty;
  final int currentQuestion;
  final int timeLeft;
  final int selectedOption;
  final bool answered;
  final int score;
  final List<int> userAnswers;

  const QuizLoaded({
    required this.questions,
    required this.quizName,
    required this.quizIcon,
    required this.quizDifficulty,
    required this.currentQuestion,
    required this.timeLeft,
    this.selectedOption = -1,
    this.answered = false,
    this.score = 0,
    required this.userAnswers,
  });

  QuizLoaded copyWith({
    List<Map<String, dynamic>>? questions,
    String? quizName,
    String? quizIcon,
    String? quizDifficulty,
    int? currentQuestion,
    int? timeLeft,
    int? selectedOption,
    bool? answered,
    int? score,
    List<int>? userAnswers,
  }) {
    return QuizLoaded(
      questions: questions ?? this.questions,
      quizName: quizName ?? this.quizName,
      quizIcon: quizIcon ?? this.quizIcon,
      quizDifficulty: quizDifficulty ?? this.quizDifficulty,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      timeLeft: timeLeft ?? this.timeLeft,
      selectedOption: selectedOption ?? this.selectedOption,
      answered: answered ?? this.answered,
      score: score ?? this.score,
      userAnswers: userAnswers ?? this.userAnswers,
    );
  }

  @override
  List<Object> get props => [
        questions,
        quizName,
        quizIcon,
        quizDifficulty,
        currentQuestion,
        timeLeft,
        selectedOption,
        answered,
        score,
        userAnswers
      ];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object> get props => [message];
}

class QuizFinished extends QuizState {
  final int score;
  final int total;
  final List<int> userAnswers;
  final String quizId;
  final String quizTitle;
  final String quizIcon;
  final String difficulty;

  const QuizFinished({
    required this.score,
    required this.total,
    required this.userAnswers,
    required this.quizId,
    required this.quizTitle,
    required this.quizIcon,
    required this.difficulty,
  });

  @override
  List<Object> get props => [
        score,
        total,
        userAnswers,
        quizId,
        quizTitle,
        quizIcon,
        difficulty,
      ];
}
