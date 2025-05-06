import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_generator/View/Screens/Quizz/bloc/quiz_bloc.dart';
import 'package:test_generator/View/Screens/Quizz/bloc/quiz_event.dart';
import 'package:test_generator/View/Screens/Quizz/bloc/quiz_state.dart';
import 'package:test_generator/View/Screens/Quizz/quiz_result.dart';
import 'package:test_generator/services/quizScreenService.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizBloc(
        quizScreenService: QuizScreenService(),
        quizId: widget.quizId,
      )..add(LoadQuiz(quizId: widget.quizId)),
      child: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizFinished) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuizResult(
                  score: state.score,
                  total: state.total,
                  userAnswers: state.userAnswers,
                  quizId: state.quizId,
                  quizTitle: state.quizTitle,
                  quizIcon: state.quizIcon,
                  difficulty: state.difficulty,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is QuizError) {
            return Scaffold(
              body: Center(child: Text(state.message)),
            );
          }

          if (state is QuizLoaded) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.grey[800],
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "${state.quizName} Quiz",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.blue, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${state.timeLeft} s",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Question ${state.currentQuestion + 1} of ${state.questions.length}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              state.questions[state.currentQuestion]
                                  ['question'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildOptions(context, state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        },
      ),
    );
  }

  Widget _buildOptions(BuildContext context, QuizLoaded state) {
    final options =
        List<String>.from(state.questions[state.currentQuestion]['options']);
    return Column(
      children: List.generate(
        options.length,
        (index) => GestureDetector(
          onTap: state.answered
              ? null
              : () => context
                  .read<QuizBloc>()
                  .add(SelectAnswer(selectedOption: index)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getOptionColor(state, index),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(state, index),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getCircleColor(state, index),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: _getTextColor(state, index),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getOptionColor(QuizLoaded state, int index) {
    if (state.answered) {
      if (index == state.questions[state.currentQuestion]['correctIndex']) {
        return Colors.green[100]!;
      }
      if (state.selectedOption == index) {
        return Colors.red[100]!;
      }
    }
    return Colors.white;
  }

  Color _getBorderColor(QuizLoaded state, int index) {
    if (state.answered) {
      if (index == state.questions[state.currentQuestion]['correctIndex']) {
        return Colors.green;
      }
      if (state.selectedOption == index) {
        return Colors.red;
      }
    }
    return Colors.grey[400]!;
  }

  Color _getCircleColor(QuizLoaded state, int index) {
    if (state.answered) {
      if (index == state.questions[state.currentQuestion]['correctIndex']) {
        return Colors.green;
      }
      if (state.selectedOption == index) {
        return Colors.red;
      }
    }
    return state.selectedOption == index ? Colors.purple : Colors.grey[400]!;
  }

  Color _getTextColor(QuizLoaded state, int index) {
    if (state.answered &&
        (index == state.questions[state.currentQuestion]['correctIndex'] ||
            state.selectedOption == index)) {
      return Colors.white;
    }
    return Colors.black;
  }
}
