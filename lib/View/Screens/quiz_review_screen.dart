import 'package:flutter/material.dart';

class QuizReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<int> userAnswers;

  const QuizReviewScreen({
    Key? key,
    required this.questions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        title: Text("Review Questions", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswer = userAnswers[index];
          final correctAnswer = question['correctIndex'];
          final options = List<String>.from(question['options']);

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
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
                        userAnswer == correctAnswer
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: userAnswer == correctAnswer
                            ? Colors.green
                            : Colors.red,
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
                      color: userAnswer == correctAnswer
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userAnswer >= 0 ? options[userAnswer] : "No answer",
                    style: TextStyle(fontSize: 15),
                  ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
