import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_generator/View/Screens/quiz_review_screen.dart';
import 'package:test_generator/services/historyService.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<Map<String, dynamic>> historyData = [];
  bool isLoading = true; // Track loading state

  void _retakeQuiz(String topic, String currentDifficulty) {
    // Navigate back to home and trigger quiz generation with same settings
    Navigator.pop(context,
        {'action': 'retake', 'topic': topic, 'difficulty': currentDifficulty});
  }

  void _takeHarderQuiz(String topic, String currentDifficulty) {
    String newDifficulty = 'Hard';
    if (currentDifficulty == 'Easy') {
      newDifficulty = 'Medium';
    }

    // Navigate back to home and trigger quiz generation with higher difficulty
    Navigator.pop(context,
        {'action': 'upgrade', 'topic': topic, 'difficulty': newDifficulty});
  }

  @override
  void initState() {
    super.initState();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    print(userId);
    _historyService.fetchUserHistory(userId).then((value) {
      setState(() {
        historyData = value;
        isLoading = false; // Data loaded
      });
    }).catchError((error) {
      print("Error fetching history: $error");
      setState(() {
        isLoading = false; // Stop loader even on error
      });
    });
  }

  String _getGrade(int score, int total) {
    if (total <= 0) return "N/A"; // Handle case where total is 0 or negative
    double percentage = (score / total) * 100;
    if (percentage >= 90) return "A";
    if (percentage >= 80) return "B";
    if (percentage >= 70) return "C";
    if (percentage >= 60) return "D";
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
        backgroundColor: Colors.grey[800],
        elevation: 0,
        title: Text(
          "Quiz History",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loader while loading
            )
          : historyData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No quiz history yet",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final item = historyData[index];
                    final grade = _getGrade(item["score"], item["questions"]);

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Navigate to quiz review when tapped
                          if (item["questions_data"].isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizReviewScreen(
                                  questions: item["questions_data"],
                                  userAnswers:
                                      List<int>.from(item["userAnswers"]),
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(item["icon"],
                                        color: Colors.purple),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["title"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          item["date"],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getGradeColor(grade)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getGradeColor(grade),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      item["questions"] > 0
                                          ? "${item["score"]}/${item["questions"]}"
                                          : "N/A",
                                      style: TextStyle(
                                        color: _getGradeColor(grade),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: item["questions"] > 0
                                    ? (item["score"] / item["questions"])
                                        .clamp(0.0, 1.0)
                                    : 0.0,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _getGradeColor(grade)),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (grade == "A")
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        final currentTitle = item["title"];
                                        final currentDifficulty =
                                            item["difficulty"];
                                        _takeHarderQuiz(
                                            currentTitle, currentDifficulty);
                                      },
                                      icon: Icon(Icons.trending_up,
                                          color: Colors.white),
                                      label: Text("Try Higher Difficulty",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        final currentTitle = item["title"];
                                        final currentDifficulty =
                                            item["difficulty"];
                                        _retakeQuiz(
                                            currentTitle, currentDifficulty);
                                      },
                                      icon: Icon(Icons.refresh,
                                          color: Colors.white),
                                      label: Text("Retake Quiz",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _getGradeColor(grade),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                ],
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
}
