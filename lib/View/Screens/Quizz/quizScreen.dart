import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:test_generator/View/Screens/Quizz/quiz_result.dart';
import 'package:test_generator/services/quizScreenService.dart';

class QuizScreen extends StatefulWidget {
  final String quizId; // Accept quizId dynamically

  const QuizScreen({super.key, required this.quizId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final QuizScreenService _quizScreenService =
      QuizScreenService(); // Use service
  int _selectedOption = -1;
  int _currentQuestion = 0;
  int _timeLeft = 30;
  late Timer _timer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> questions = [];
  String QuizName = "";
  int get _totalQuestions => questions.length;
  bool _answered = false;
  int _score = 0;
  List<int> _userAnswers = [];
  String userId = FirebaseAuth.instance.currentUser!.uid; // Replace with actual userId from your auth/session

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadQuizDetails();
    _startTimer();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<void> _uploadAnswers(BuildContext context) async {
    final quizData = questions;

    for (int i = 0; i < quizData.length; i++) {
      final question = quizData[i];
      final questionId =
          question['id']; // Ensure each question has an `id` field
      final selectedIndex = _userAnswers[i];
      final correctIndex = question['correctIndex'];

      final isCorrect = selectedIndex == correctIndex;


      await _quizScreenService.saveUserAnswer(
        userId:
            userId, // Replace with the actual userId from your auth/session
        quizId: widget.quizId,
        questionId: questionId,
        selectedAnswer: selectedIndex,
        isCorrect: isCorrect, question: question['question'],
        
      );
    }

    print("✅ All answers uploaded.");
  }

  Future<void> _uploadResults() async {
    await _quizScreenService.saveQuizHistory(
      userId: userId, // Replace with the actual userId from your auth/session
      quizId: widget.quizId,
      score: _score,
      total_questions: _totalQuestions, quizTitle: QuizName,
    );
    print("✅ Quiz results uploaded.");
  }

  /// Load questions using the service
  Future<void> _loadQuestions() async {
    final loadedQuestions =
        await _quizScreenService.fetchQuizQuestions(widget.quizId);
    setState(() {
      questions = loadedQuestions;
    });
  }

  Future<void> _loadQuizDetails() async {
    final quizDetails =
        await _quizScreenService.fetchQuizDetails(widget.quizId);
    setState(() {
      QuizName = quizDetails[0]['topic'];
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _nextQuestion();
      }
    });
  }

  void _selectOption(int index) {
    if (!_answered) {
      setState(() {
        _selectedOption = index;
        _answered = true;
        if (index == questions[_currentQuestion]['correctIndex']) {
          _score++;
        }
        _userAnswers.add(index);
      });

      Future.delayed(const Duration(seconds: 1), () {
        _nextQuestion();
      });
    }
  }

  Future<void> _nextQuestion() async {
    if (_currentQuestion < _totalQuestions - 1) {
      setState(() {
        _controller.reset();
        _controller.forward();
        _currentQuestion++;
        _selectedOption = -1;
        _timeLeft = 30;
        _answered = false;
      });
    } else {
      _timer.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResult(
            score: _score,
            total: _totalQuestions,
            userAnswers: _userAnswers,
            quizId: widget.quizId, // Pass quizId to result screen
          ),
        ),
      );
      await _uploadAnswers(context); // Save answers first
      await _uploadResults(); // Save results
    }
  }

  Color _getOptionColor(int index) {
    if (_answered) {
      if (index == questions[_currentQuestion]['correctIndex']) {
        return Colors.green[100]!;
      }
      if (_selectedOption == index) {
        return Colors.red[100]!;
      }
    }
    return Colors.white;
  }

  Color _getBorderColor(int index) {
    if (_answered) {
      if (index == questions[_currentQuestion]['correctIndex']) {
        return Colors.green;
      }
      if (_selectedOption == index) {
        return Colors.red;
      }
    }
    return Colors.grey[400]!;
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "$QuizName Quiz",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  "$_timeLeft s",
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                                    "Question ${_currentQuestion + 1} of $_totalQuestions",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              questions[_currentQuestion]['question'],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: List.generate(4, (index) {
                                List<String> options = List<String>.from(
                                    questions[_currentQuestion]['options']);
                                return GestureDetector(
                                  onTap: () => _selectOption(index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _getOptionColor(index),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getBorderColor(index),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: _answered
                                              ? (index ==
                                                      questions[
                                                              _currentQuestion]
                                                          ['correctIndex']
                                                  ? Colors.green
                                                  : (_selectedOption == index
                                                      ? Colors.red
                                                      : Colors.grey[400]))
                                              : (_selectedOption == index
                                                  ? Colors.purple
                                                  : Colors.grey[400]),
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              color: _selectedOption == index ||
                                                      (_answered &&
                                                          index ==
                                                              questions[
                                                                      _currentQuestion]
                                                                  [
                                                                  'correctIndex'])
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            options[index],
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
