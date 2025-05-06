import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_generator/Data/quiz_settings.dart';
import 'package:test_generator/services/user_service.dart';
import 'package:test_generator/services/query_preprocessor_service.dart';
import 'package:test_generator/services/quiz_generator_service.dart';
import 'package:test_generator/services/quiz_upload_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserService _userService;

  HomeBloc({required UserService userService})
      : _userService = userService,
        super(HomeInitial()) {
    on<LoadUserData>(_onLoadUserData);
    on<GenerateQuiz>(_onGenerateQuiz);
    on<UpdateQuizSettings>(_onUpdateQuizSettings);
  }

  Future<void> _onLoadUserData(
      LoadUserData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final userData = await _userService.getUserDetails();
      if (userData != null) {
        emit(HomeLoaded(
          userName: userData['name'],
          profilePic: userData['profile_pic'],
          exam: userData['exam'],
          fieldOfStudy: userData['field_of_study'],
          quizSettings: QuizSettings.fromJson(userData['quiz_settings']),
        ));
      } else {
        emit(HomeLoaded(quizSettings: QuizSettings()));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onGenerateQuiz(
      GenerateQuiz event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(isGenerating: true));

      try {
        final formattedQuery =
            await QueryPreprocessorService.preprocessQuery(event.topic);
        print("Formatted Query: $formattedQuery");    
        final quiz = await QuizGeneratorService.generateQuiz(formattedQuery);
        print("Generated Quiz: $quiz");

        if (quiz.isNotEmpty) {
          final quizId = await FirebaseQuizService.uploadQuiz(quiz);
          if (quizId != null) {
            emit(currentState.copyWith(
              isGenerating: false,
              generatedQuizId: quizId,
            ));
            return;
          }
        }
        emit(currentState.copyWith(isGenerating: false));
        emit(HomeError("Failed to generate quiz"));
      } catch (e) {
        emit(currentState.copyWith(isGenerating: false));
        emit(HomeError(e.toString()));
      }
    }
  }

  void _onUpdateQuizSettings(
      UpdateQuizSettings event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newSettings = currentState.quizSettings.copyWith(
        difficulty: event.difficulty,
      );
      emit(currentState.copyWith(quizSettings: newSettings));
    }
  }
}
