import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:test_generator/View/Screens/quiz_review_screen.dart';
import 'package:test_generator/services/quizScreenService.dart';



class QuizResult extends StatelessWidget {
  final int score;
  final int total;
  final String quizId;
  final List<int> userAnswers;
    final QuizScreenService _quizScreenService = QuizScreenService();



   QuizResult({
    super.key,
    required this.score,
    required this.total,
    required this.userAnswers, required this.quizId,
  });



  

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
    // String jsonString =
      final loadedQuestions =
        await _quizScreenService.fetchQuizQuestions(quizId);
    // List<dynamic> jsonData = json.decode(jsonString);
    return loadedQuestions;
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        title: const Text("Quiz Result", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _getResultColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _getResultColor(),
                  width: 2,
                ),
              ),
              child: Text(
                "$score / $total",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getResultColor(),
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
                    Navigator.popUntil(context, (route) => route.isFirst);
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
    );
  }
}
