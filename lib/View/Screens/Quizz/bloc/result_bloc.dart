import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_generator/services/quizScreenService.dart';
import 'result_event.dart';
import 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final QuizScreenService _quizScreenService;

  ResultBloc({required QuizScreenService quizScreenService})
      : _quizScreenService = quizScreenService,
        super(ResultInitial()) {
    on<SaveQuizResult>(_onSaveQuizResult);
  }

  Future<void> _onSaveQuizResult(
      SaveQuizResult event, Emitter<ResultState> emit) async {
    emit(ResultSaving());
    try {
      await _quizScreenService.saveQuizHistory(
        userId: event.userId,
        quizId: event.quizId,
        score: event.score,
        total_questions: event.totalQuestions,
        quizTitle: event.quizTitle,
        quizIcon: event.quizIcon,
        quizDifficulty: event.quizDifficulty,
      );

      for (int i = 0; i < event.questions.length; i++) {
        final question = event.questions[i];
        final options = List<String>.from(question['options']);
        final selectedOption =
            event.userAnswers[i] >= 0 && event.userAnswers[i] < options.length
                ? options[event.userAnswers[i]]
                : 'No Answer';
        final correctAnswer = options[question['correctIndex']];

        await _quizScreenService.saveUserAnswer(
          userId: event.userId,
          quizId: event.quizId,
          questionId: question['id'],
          selectedOption: selectedOption,
          correctAnswer: correctAnswer,
          isCorrect: event.userAnswers[i] == question['correctIndex'],
          question: question['question'],
        );
      }
      emit(ResultSaved());
    } catch (e) {
      emit(ResultError(e.toString()));
    }
  }
}
