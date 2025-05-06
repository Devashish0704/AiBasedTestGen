import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_generator/View/Screens/quiz_review_screen.dart';
import 'package:test_generator/services/historyService.dart';
import 'package:test_generator/Data/quiz_history.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<QuizHistory> historyData = [];
  bool isLoading = true;

  void _retakeQuiz(String topic, String currentDifficulty) {
    Navigator.pop(context,
        {'action': 'retake', 'topic': topic, 'difficulty': currentDifficulty});
  }

  void _takeHarderQuiz(String topic, String currentDifficulty) {
    String newDifficulty = 'Hard';
    if (currentDifficulty == 'Easy') {
      newDifficulty = 'Medium';
    }
    Navigator.pop(context,
        {'action': 'upgrade', 'topic': topic, 'difficulty': newDifficulty});
  }

  void _showQuizReview(String quizId, QuizHistory quiz) async {
    final answers = await _historyService.fetchQuizAnswers(
      FirebaseAuth.instance.currentUser!.uid,
      quizId,
    );

    if (answers.isNotEmpty && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizReviewScreen.fromHistory(
            answers: answers,
            quizTitle: quiz.quizTitle,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    _historyService.fetchUserHistory(userId).then((value) {
      setState(() {
        historyData = value;
        isLoading = false;
      });
    }).catchError((error) {
      print("Error fetching history: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  String _getGrade(double accuracy) {
    if (accuracy >= 90) return "A";
    if (accuracy >= 80) return "B";
    if (accuracy >= 70) return "C";
    if (accuracy >= 60) return "D";
    return "F";
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case "A":
        return Colors.green;
      case "B":
        return Colors.blue;
      case "C":
        return Colors.orange;
      case "D":
        return Colors.deepOrange;
      case "N/A":
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz History'),
        backgroundColor: Colors.grey[800],
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.purple))
          : historyData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No quiz history yet",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Complete a quiz to see your history",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final quiz = historyData[index];
                    final grade = _getGrade(quiz.accuracy);
                    final gradeColor = _getGradeColor(grade);

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _showQuizReview(quiz.quizId, quiz),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: gradeColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconData(quiz.quizIcon),
                              color: gradeColor,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            quiz.quizTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Score: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${quiz.score}/${quiz.totalQuestions}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: gradeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Difficulty: ${quiz.difficulty}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: quiz.accuracy / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(gradeColor),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.refresh, color: gradeColor),
                                onPressed: () => _retakeQuiz(
                                    quiz.quizTitle, quiz.difficulty),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.trending_up, color: gradeColor),
                                onPressed: () => _takeHarderQuiz(
                                    quiz.quizTitle, quiz.difficulty),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'storage':
        return Icons.storage;
      case 'web':
        return Icons.web;
      case 'design_services':
        return Icons.design_services;
      case 'school':
        return Icons.school;
      case 'science':
        return Icons.science;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'book':
        return Icons.book;
      case 'computer':
        return Icons.computer;
      case 'lightbulb':
        return Icons.lightbulb;
      default:
        return Icons.help;
    }
  }
}
