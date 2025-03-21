import 'package:flutter/material.dart';
import 'package:test_generator/View/Screens/quiz_review_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // This would typically come from a database or storage
  final List<Map<String, dynamic>> historyData = [
    {
      "title": "Flutter Basics",
      "questions": 10,
      "score": 8,
      "icon": Icons.code,
      "date": "2024-03-20",
      "userAnswers": [0, 1, 2, 0, 1, 2, 0, 1, 2, 0],
      "questions_data": [] // This would contain the actual quiz questions
    },
    {
      "title": "Data Structures",
      "questions": 15,
      "score": 2,
      "icon": Icons.memory,
      "date": "2024-03-19",
      "userAnswers": List.generate(15, (index) => index % 4),
      "questions_data": []
    },
    {
      "title": "Algorithms",
      "questions": 20,
      "score": 14,
      "icon": Icons.settings,
      "date": "2024-03-18",
      "userAnswers": List.generate(20, (index) => index % 3),
      "questions_data": []
    },
    {
      "title": "Databases",
      "questions": 25,
      "score": 24,
      "icon": Icons.storage,
      "date": "2024-03-17",
      "userAnswers": List.generate(25, (index) => index % 2),
      "questions_data": []
    },
    {
      "title": "Networking",
      "questions": 30,
      "score": 24,
      "icon": Icons.network_check,
      "date": "2024-03-16",
      "userAnswers": List.generate(30, (index) => index % 5),
      "questions_data": []
    },
    // ... keep other history items ...
  ];

  String _getGrade(int score, int total) {
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
      body: historyData.isEmpty
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
                              userAnswers: List<int>.from(item["userAnswers"]),
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
                                child: Icon(item["icon"], color: Colors.purple),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: _getGradeColor(grade).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getGradeColor(grade),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "${item["score"]}/${item["questions"]}",
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
                            value: item["score"] / item["questions"],
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getGradeColor(grade)),
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
