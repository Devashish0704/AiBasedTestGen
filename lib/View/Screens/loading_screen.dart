// loading_screen.dart
import 'package:flutter/material.dart';
import 'package:test_generator/View/Screens/Quizz/quizScreen.dart';

class LoadingScreen extends StatelessWidget {
  final Future<String> Function() uploadQuizTask;

  const LoadingScreen({super.key, required this.uploadQuizTask});

  @override
  Widget build(BuildContext context) {
    uploadQuizTask().then((quizId) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(quizId: quizId),
        ),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 16),
            Text(
              "Generating your test...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
