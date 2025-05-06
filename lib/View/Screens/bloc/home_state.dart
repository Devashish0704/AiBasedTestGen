import 'package:equatable/equatable.dart';
import 'package:test_generator/Data/quiz_settings.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String? userName;
  final String? profilePic;
  final String? exam;
  final String? fieldOfStudy;
  final QuizSettings quizSettings;
  final bool isGenerating;
  final String? generatedQuizId;

  const HomeLoaded({
    this.userName,
    this.profilePic,
    this.exam,
    this.fieldOfStudy,
    required this.quizSettings,
    this.isGenerating = false,
    this.generatedQuizId,
  });

  HomeLoaded copyWith({
    String? userName,
    String? profilePic,
    String? exam,
    String? fieldOfStudy,
    QuizSettings? quizSettings,
    bool? isGenerating,
    String? generatedQuizId,
  }) {
    return HomeLoaded(
      userName: userName ?? this.userName,
      profilePic: profilePic ?? this.profilePic,
      exam: exam ?? this.exam,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      quizSettings: quizSettings ?? this.quizSettings,
      isGenerating: isGenerating ?? this.isGenerating,
      generatedQuizId: generatedQuizId ?? this.generatedQuizId,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        profilePic,
        exam,
        fieldOfStudy,
        quizSettings,
        isGenerating,
        generatedQuizId,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
