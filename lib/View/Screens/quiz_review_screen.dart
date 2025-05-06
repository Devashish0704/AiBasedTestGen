import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class QuizReviewEvent extends Equatable {
  const QuizReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadQuizReview extends QuizReviewEvent {
  final List<Map<String, dynamic>> questions;
  final List<int> userAnswers;

  const LoadQuizReview({required this.questions, required this.userAnswers});

  @override
  List<Object> get props => [questions, userAnswers];
}

class LoadQuizHistoryReview extends QuizReviewEvent {
  final List<Map<String, dynamic>> answers;
  final String quizTitle;

  const LoadQuizHistoryReview({
    required this.answers,
    required this.quizTitle,
  });

  @override
  List<Object> get props => [answers, quizTitle];
}

// States
abstract class QuizReviewState extends Equatable {
  const QuizReviewState();

  @override
  List<Object> get props => [];
}

class QuizReviewInitial extends QuizReviewState {}

class QuizReviewLoading extends QuizReviewState {}

class QuizReviewLoaded extends QuizReviewState {
  final List<Map<String, dynamic>> questions;
  final List<int> userAnswers;
  final List<Map<String, dynamic>>? historyAnswers;
  final String? quizTitle;

  const QuizReviewLoaded({
    required this.questions,
    required this.userAnswers,
    this.historyAnswers,
    this.quizTitle,
  });

  @override
  List<Object> get props => [
        questions,
        userAnswers,
        if (historyAnswers != null) historyAnswers!,
        if (quizTitle != null) quizTitle!,
      ];
}

class QuizReviewError extends QuizReviewState {
  final String message;

  const QuizReviewError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class QuizReviewBloc extends Bloc<QuizReviewEvent, QuizReviewState> {
  QuizReviewBloc() : super(QuizReviewInitial()) {
    on<LoadQuizReview>(_onLoadQuizReview);
    on<LoadQuizHistoryReview>(_onLoadQuizHistoryReview);
  }

  Future<void> _onLoadQuizReview(
    LoadQuizReview event,
    Emitter<QuizReviewState> emit,
  ) async {
    emit(QuizReviewLoading());
    try {
      emit(QuizReviewLoaded(
        questions: event.questions,
        userAnswers: event.userAnswers,
      ));
    } catch (e) {
      emit(QuizReviewError(e.toString()));
    }
  }

  void _onLoadQuizHistoryReview(
    LoadQuizHistoryReview event,
    Emitter<QuizReviewState> emit,
  ) {
    emit(QuizReviewLoading());
    try {
      emit(QuizReviewLoaded(
        questions: [], // Not needed for history review
        userAnswers: [], // Not needed for history review
        historyAnswers: event.answers,
        quizTitle: event.quizTitle,
      ));
    } catch (e) {
      emit(QuizReviewError(e.toString()));
    }
  }
}

// Widget
class QuizReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? questions;
  final List<int>? userAnswers;
  final List<Map<String, dynamic>>? historyAnswers;
  final String? quizTitle;

  const QuizReviewScreen({
    Key? key,
    this.questions,
    this.userAnswers,
    this.historyAnswers,
    this.quizTitle,
  }) : super(key: key);

  // New constructor for history review
  factory QuizReviewScreen.fromHistory({
    required List<Map<String, dynamic>> answers,
    required String quizTitle,
  }) {
    return QuizReviewScreen(
      historyAnswers: answers,
      quizTitle: quizTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizReviewBloc()
        ..add(
          historyAnswers != null
              ? LoadQuizHistoryReview(
                  answers: historyAnswers!, quizTitle: quizTitle!)
              : LoadQuizReview(
                  questions: questions!, userAnswers: userAnswers!),
        ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.purple[400],
          elevation: 0,
          title: Text(
            quizTitle ?? "Review Questions",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<QuizReviewBloc, QuizReviewState>(
          builder: (context, state) {
            if (state is QuizReviewLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              );
            }

            if (state is QuizReviewError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            if (state is QuizReviewLoaded) {
              final items = state.historyAnswers ??
                  List.generate(
                      state.questions.length,
                      (index) => {
                            'question': state.questions[index]['question'],
                            'selected_option': state.userAnswers[index] >= 0 &&
                                    state.userAnswers[index] <
                                        state.questions[index]['options'].length
                                ? state.questions[index]['options']
                                    [state.userAnswers[index]]
                                : 'No Answer',
                            'correct_answer': state.questions[index]['options']
                                [state.questions[index]['correctIndex']],
                            'is_correct': state.userAnswers[index] ==
                                state.questions[index]['correctIndex'],
                          });

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple[400],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Quiz Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${items.where((a) => a['is_correct']).length}/${items.length} Correct",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return AnimatedReviewCard(
                          index: index,
                          child: HistoryQuestionReviewCard(
                            index: index,
                            answer: items[index],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }
}

class AnimatedReviewCard extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedReviewCard({
    Key? key,
    required this.index,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: child,
      ),
    );
  }
}

class QuestionReviewCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> question;
  final int userAnswer;
  final int correctAnswer;
  final List<String> options;

  const QuestionReviewCard({
    Key? key,
    required this.index,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Question ${index + 1}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Icon(
                userAnswer == correctAnswer ? Icons.check_circle : Icons.cancel,
                color: userAnswer == correctAnswer ? Colors.green : Colors.red,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            question['question'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Your Answer:",
            style: TextStyle(
              color: userAnswer == correctAnswer ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userAnswer >= 0 && userAnswer < options.length
                ? options[userAnswer]
                : "No answer selected",
            style: TextStyle(fontSize: 15),
          ),
          if (userAnswer != correctAnswer) ...[
            SizedBox(height: 8),
            Text(
              "Correct Answer:",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              options[correctAnswer],
              style: TextStyle(fontSize: 15),
            ),
          ],
        ],
      ),
    );
  }
}

class HistoryQuestionReviewCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> answer;

  const HistoryQuestionReviewCard({
    Key? key,
    required this.index,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCorrect = answer['is_correct'];
    final cardColor =
        isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
    final borderColor =
        isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isCorrect ? Colors.green : Colors.red,
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      answer['question'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnswerSection(
                    "Your Answer",
                    answer['selected_option'],
                    isCorrect ? Colors.green : Colors.red,
                  ),
                  if (!isCorrect) ...[
                    SizedBox(height: 16),
                    _buildAnswerSection(
                      "Correct Answer",
                      answer['correct_answer'],
                      Colors.green,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection(String label, String text, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              label == "Your Answer"
                  ? (color == Colors.green
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined)
                  : Icons.check_circle_outline,
              color: color,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
