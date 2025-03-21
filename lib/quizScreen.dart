// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';

// import 'package:test_generator/homeScreen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: QuizScreen(),
//     );
//   }
// }

// class QuizScreen extends StatefulWidget {
//   const QuizScreen({super.key});

//   @override
//   _QuizScreenState createState() => _QuizScreenState();
// }

// class _QuizScreenState extends State<QuizScreen>
//     with SingleTickerProviderStateMixin {
//   int _selectedOption = -1;
//   int _currentQuestion = 0;
//   final int _totalQuestions = 10;
//   int _timeLeft = 30;
//   late Timer _timer;
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   List<Map<String, dynamic>> questions = [];

//   @override
//   void initState() {
//     super.initState();
//     loadQuestions();
//     _startTimer();
//     _controller = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 500));
//     _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//     _controller.forward();
//   }

//   Future<void> loadQuestions() async {
//     String jsonString =
//         await DefaultAssetBundle.of(context).loadString('lib/Data/quiz.json');
//     List<dynamic> jsonData = json.decode(jsonString);
//     setState(() {
//       questions = List<Map<String, dynamic>>.from(jsonData);
//     });
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_timeLeft > 0) {
//         setState(() {
//           _timeLeft--;
//         });
//       } else {
//         _nextQuestion();
//       }
//     });
//   }

//   void _selectOption(int index) {
//     setState(() {
//       _selectedOption = index;
//     });
//   }

//   void _nextQuestion() {
//     if (_currentQuestion < _totalQuestions) {
//       setState(() {
//         _controller.reset();
//         _controller.forward();
//         _currentQuestion++;
//         _selectedOption = -1;
//         _timeLeft = 30;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.grey[800],
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => HomeScreen()),
//             );
//           },
//         ),
//         title: const Text(
//           "UI UX Design Quiz",
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.timer, color: Colors.blue, size: 16),
//                 const SizedBox(width: 4),
//                 Text(
//                   "$_timeLeft s",
//                   style: const TextStyle(
//                       color: Colors.blue, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: questions.isEmpty
//               ? const Center(child: CircularProgressIndicator())
//               : Column(
//                   children: [
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                             "Question ${_currentQuestion + 1} of $_totalQuestions",
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       questions[_currentQuestion]['question'],
//                       style: const TextStyle(
//                           fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 20),
//                     Column(
//                       children: List.generate(4, (index) {
//                         List<String> options = List<String>.from(
//                             questions[_currentQuestion]['options']);
//                         return GestureDetector(
//                           onTap: () => _selectOption(index),
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: _selectedOption == index
//                                   ? Colors.purple[100]
//                                   : Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: _selectedOption == index
//                                     ? Colors.purple
//                                     : Colors.grey[400]!,
//                                 width: 2,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundColor: _selectedOption == index
//                                       ? Colors.purple
//                                       : Colors.grey[400],
//                                   child: Text(
//                                     String.fromCharCode(65 + index),
//                                     style: TextStyle(
//                                       color: _selectedOption == index
//                                           ? Colors.white
//                                           : Colors.black,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     options[index],
//                                     style: const TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                     const SizedBox(height: 24),
//                     Center(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.purple,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 12),
//                         ),
//                         onPressed: () {
//                           _nextQuestion();
//                         },
//                         child: const Text(
//                           "Continue",
//                           style: TextStyle(fontSize: 18, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:test_generator/quiz_result.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _selectedOption = -1;
  int _currentQuestion = 0;
  final int _totalQuestions = 10;
  int _timeLeft = 30;
  late Timer _timer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> questions = [];
  bool _answered = false;
  int _score = 0;
  List<int> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
    _startTimer();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<void> loadQuestions() async {
    String jsonString =
        await DefaultAssetBundle.of(context).loadString('lib/Data/quiz.json');
    List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      questions = List<Map<String, dynamic>>.from(jsonData);
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

  void _nextQuestion() {
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
          ),
        ),
      );
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
        title: const Text(
          "UI UX Design Quiz",
          style: TextStyle(color: Colors.white, fontSize: 18),
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
