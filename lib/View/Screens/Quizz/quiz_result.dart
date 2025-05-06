import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_generator/View/Screens/quiz_review_screen.dart';
import 'package:test_generator/services/quizScreenService.dart';
import 'bloc/result_bloc.dart';
import 'bloc/result_event.dart';
import 'bloc/result_state.dart';

class QuizResult extends StatelessWidget {
  final int score;
  final int total;
  final List<int> userAnswers;
  final String quizId;
  final String quizTitle;
  final String quizIcon;
  final String difficulty;

  const QuizResult({
    Key? key,
    required this.score,
    required this.total,
    required this.userAnswers,
    required this.quizId,
    required this.quizTitle,
    required this.quizIcon,
    required this.difficulty,
  }) : super(key: key);

  String _getResultMessage() {
    double percentage = (score / total) * 100;
    if (percentage >= 90) {
      return "Excellent!";
    } else if (percentage >= 70) {
      return "Good Job!";
    } else if (percentage >= 50) {
      return "Not Bad!";
    } else {
      return "Keep Practicing!";
    }
  }

  Color _getResultColor() {
    double percentage = (score / total) * 100;
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 70) {
      return Colors.blue;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<List<Map<String, dynamic>>> _loadQuizData(BuildContext context) async {
    final loadedQuestions =
        await QuizScreenService().fetchQuizQuestions(quizId);
    return loadedQuestions;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total) * 100;
    final gradeColor = _getResultColor();

    return BlocProvider(
      create: (context) => ResultBloc(
        quizScreenService: QuizScreenService(),
      )..add(
          SaveQuizResult(
            quizId: quizId,
            userId: FirebaseAuth.instance.currentUser!.uid,
            score: score,
            totalQuestions: total,
            quizTitle: quizTitle,
            quizIcon: quizIcon,
            quizDifficulty: difficulty,
            questions: [], // Not needed for history
            userAnswers: userAnswers,
          ),
        ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.grey[800],
              elevation: 0,
              title: const Text("Quiz Result",
                  style: TextStyle(color: Colors.white)),
              automaticallyImplyLeading: false,
            ),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getResultMessage(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Your Score",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: gradeColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          "$score / $total",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final quizData = await _loadQuizData(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizReviewScreen(
                                    questions: quizData,
                                    userAnswers: userAnswers,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.purple),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove_red_eye,
                                    color: Colors.purple, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "View Questions",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Pop the QuizResult and QuizScreen, then return to home
                              Navigator.of(context).popUntil(
                                  (route) => route.settings.name == '/');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.home, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Home",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 16,
                  child: BlocBuilder<ResultBloc, ResultState>(
                    builder: (context, state) {
                      if (state is ResultSaving) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[400]!),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Saving...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      } else if (state is ResultSaved) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[400], size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Saved',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        );
                      } else if (state is ResultError) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red[400], size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Error saving',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
