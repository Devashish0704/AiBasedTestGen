import 'package:equatable/equatable.dart';

abstract class QuizCustomizationState extends Equatable {
  const QuizCustomizationState();

  @override
  List<Object?> get props => [];
}

class QuizCustomizationInitial extends QuizCustomizationState {}

class QuizCustomizationLoading extends QuizCustomizationState {}

class QuizCustomizationSuccess extends QuizCustomizationState {
  final String quizId;

  const QuizCustomizationSuccess(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class QuizCustomizationError extends QuizCustomizationState {
  final String message;

  const QuizCustomizationError(this.message);

  @override
  List<Object?> get props => [message];
}
