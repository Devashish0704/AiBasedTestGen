import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_generator/services/document_service.dart';
import 'package:test_generator/services/content_quiz_generator_service.dart';
import 'package:test_generator/services/quiz_upload_service.dart';
import 'quiz_customization_event.dart';
import 'quiz_customization_state.dart';

class QuizCustomizationBloc
    extends Bloc<QuizCustomizationEvent, QuizCustomizationState> {
  QuizCustomizationBloc() : super(QuizCustomizationInitial()) {
    on<UploadDocument>(_onUploadDocument);
    on<EnterTextManually>(_onEnterTextManually);
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<QuizCustomizationState> emit,
  ) async {
    emit(QuizCustomizationLoading());

    try {
      final text = await DocumentService.extractTextFromFile(event.file);
      if (text == null || text.isEmpty) {
        emit(QuizCustomizationError('Could not extract text from document'));
        return;
      }

      final quiz =
          await ContentQuizGeneratorService.generateQuizFromContent(text);
      if (quiz.isEmpty) {
        emit(QuizCustomizationError('Could not generate quiz from document'));
        return;
      }

      final quizId = await FirebaseQuizService.uploadQuiz(quiz);
      if (quizId != null) {
        emit(QuizCustomizationSuccess(quizId));
      } else {
        emit(QuizCustomizationError('Failed to upload quiz'));
      }
    } catch (e) {
      emit(QuizCustomizationError(e.toString()));
    }
  }

  Future<void> _onEnterTextManually(
    EnterTextManually event,
    Emitter<QuizCustomizationState> emit,
  ) async {
    emit(QuizCustomizationLoading());

    try {
      final quiz =
          await ContentQuizGeneratorService.generateQuizFromContent(event.text);
      if (quiz.isEmpty) {
        emit(QuizCustomizationError('Could not generate quiz from text'));
        return;
      }

      final quizId = await FirebaseQuizService.uploadQuiz(quiz);
      if (quizId != null) {
        emit(QuizCustomizationSuccess(quizId));
      } else {
        emit(QuizCustomizationError('Failed to upload quiz'));
      }
    } catch (e) {
      emit(QuizCustomizationError(e.toString()));
    }
  }
}
