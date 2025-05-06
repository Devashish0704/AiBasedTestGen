import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_generator/services/quizScreenService.dart';
import 'package:test_generator/Data/quiz_history.dart';
import 'package:test_generator/services/local_cache_service.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizScreenService _quizScreenService;
  final String quizId;
  final String userId;
  Timer? _timer;

  QuizBloc({
    required QuizScreenService quizScreenService,
    required this.quizId,
  })  : _quizScreenService = quizScreenService,
        userId = FirebaseAuth.instance.currentUser!.uid,
        super(QuizInitial()) {
    on<LoadQuiz>(_onLoadQuiz);
    on<SelectAnswer>(_onSelectAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<TimerTick>(_onTimerTick);
    on<FinishQuiz>(_onFinishQuiz);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimerTick());
    });
  }

  Future<void> _onLoadQuiz(LoadQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final questions =
          await _quizScreenService.fetchQuizQuestions(event.quizId);
      final quizDetails =
          await _quizScreenService.fetchQuizDetails(event.quizId);

      if (questions.isEmpty || quizDetails.isEmpty) {
        emit(const QuizError('Failed to load quiz'));
        return;
      }

      emit(QuizLoaded(
        questions: questions,
        quizName: quizDetails[0]['topic'] ?? '',
        quizIcon: quizDetails[0]['quiz_icon'] ?? '',
        quizDifficulty: quizDetails[0]['difficulty'] ?? '',
        currentQuestion: 0,
        timeLeft: 30,
        userAnswers: [],
      ));

      _startTimer();
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onSelectAnswer(
      SelectAnswer event, Emitter<QuizState> emit) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final currentQuestion =
          currentState.questions[currentState.currentQuestion];
      final isCorrect = event.selectedOption == currentQuestion['correctIndex'];

      final newUserAnswers = List<int>.from(currentState.userAnswers)
        ..add(event.selectedOption);

      // Update state immediately
      emit(currentState.copyWith(
        selectedOption: event.selectedOption,
        answered: true,
        score: isCorrect ? currentState.score + 1 : currentState.score,
        userAnswers: newUserAnswers,
      ));

      // Save answer to Firestore immediately
      unawaited(_saveAnswer(
        questionId: currentQuestion['id'],
        selectedAnswer: event.selectedOption,
        isCorrect: isCorrect,
        question: currentQuestion['question'],
      ));

      Future.delayed(const Duration(seconds: 1), () {
        add(NextQuestion());
      });
    }
  }

  Future<void> _onNextQuestion(
      NextQuestion event, Emitter<QuizState> emit) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;

      if (currentState.currentQuestion < currentState.questions.length - 1) {
        emit(currentState.copyWith(
          currentQuestion: currentState.currentQuestion + 1,
          timeLeft: 30,
          selectedOption: -1,
          answered: false,
        ));
      } else {
        add(FinishQuiz());
      }
    }
  }

  void _onTimerTick(TimerTick event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.timeLeft > 0 && !currentState.answered) {
        emit(currentState.copyWith(timeLeft: currentState.timeLeft - 1));
      } else if (currentState.timeLeft == 0 && !currentState.answered) {
        add(SelectAnswer(selectedOption: -1));
      }
    }
  }

  Future<void> _onFinishQuiz(FinishQuiz event, Emitter<QuizState> emit) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      _timer?.cancel();

      // First emit the finished state so UI can update immediately
      emit(QuizFinished(
        score: currentState.score,
        total: currentState.questions.length,
        userAnswers: currentState.userAnswers,
        quizId: quizId,
        quizTitle: currentState.quizName,
        quizIcon: currentState.quizIcon,
        difficulty: currentState.quizDifficulty,
      ));

      // Save final quiz history
      final history = QuizHistory(
        quizId: quizId,
        quizTitle: currentState.quizName,
        quizIcon: currentState.quizIcon,
        difficulty: currentState.quizDifficulty,
        score: currentState.score,
        totalQuestions: currentState.questions.length,
        accuracy: (currentState.score / currentState.questions.length) * 100,
        createdAt: DateTime.now(),
      );

      // Update both Firestore and local cache
      unawaited(_saveQuizHistory(currentState, history));
    }
  }

  Future<void> _saveAnswer({
    required String questionId,
    required int selectedAnswer,
    required bool isCorrect,
    required String question,
  }) async {
    try {
      if (state is QuizLoaded) {
        final currentState = state as QuizLoaded;
        final currentQuestion =
            currentState.questions[currentState.currentQuestion];
        final options = List<String>.from(currentQuestion['options']);
        final selectedOption =
            selectedAnswer >= 0 && selectedAnswer < options.length
                ? options[selectedAnswer]
                : 'No Answer';
        final correctAnswer = options[currentQuestion['correctIndex']];

        await _quizScreenService.saveUserAnswer(
          userId: userId,
          quizId: quizId,
          questionId: questionId,
          selectedOption: selectedOption,
          correctAnswer: correctAnswer,
          isCorrect: isCorrect,
          question: question,
        );
      }
    } catch (e) {
      print('Error saving answer: ${e.toString()}');
    }
  }

  Future<void> _saveQuizHistory(QuizLoaded state, QuizHistory history) async {
    try {
      await _quizScreenService.saveQuizHistory(
        userId: userId,
        quizId: quizId,
        score: state.score,
        total_questions: state.questions.length,
        quizTitle: state.quizName,
        quizIcon: state.quizIcon,
        quizDifficulty: state.quizDifficulty,
      );

      // Update local cache
      await LocalCacheService.addQuizHistory(history);
    } catch (e) {
      print('Error saving quiz history: ${e.toString()}');
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
