import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadQuiz extends QuizEvent {
  final String quizId;

  const LoadQuiz({required this.quizId});

  @override
  List<Object> get props => [quizId];
}

class SelectAnswer extends QuizEvent {
  final int selectedOption;

  const SelectAnswer({required this.selectedOption});

  @override
  List<Object> get props => [selectedOption];
}

class NextQuestion extends QuizEvent {}

class TimerTick extends QuizEvent {}

class FinishQuiz extends QuizEvent {}
