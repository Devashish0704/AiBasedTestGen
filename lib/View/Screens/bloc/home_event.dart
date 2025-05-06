import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadUserData extends HomeEvent {}

class GenerateQuiz extends HomeEvent {
  final String topic;

  const GenerateQuiz({required this.topic});

  @override
  List<Object> get props => [topic];
}

class UpdateQuizSettings extends HomeEvent {
  final String difficulty;

  const UpdateQuizSettings({required this.difficulty});

  @override
  List<Object> get props => [difficulty];
}
