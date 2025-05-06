import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class QuizCustomizationEvent extends Equatable {
  const QuizCustomizationEvent();

  @override
  List<Object?> get props => [];
}

class UploadDocument extends QuizCustomizationEvent {
  final PlatformFile file;

  const UploadDocument(this.file);

  @override
  List<Object?> get props => [file];
}

class EnterTextManually extends QuizCustomizationEvent {
  final String text;

  const EnterTextManually(this.text);

  @override
  List<Object?> get props => [text];
}
