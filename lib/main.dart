import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:test_generator/Auth/auth.dart';
import 'package:test_generator/firebase_options.dart';
import 'package:test_generator/View/Screens/Quizz/quizScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use FirebaseOptions
    );
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
    );
  }
}

// // LOADING SCREEN
// class LoadingScreen extends StatefulWidget {
//   const LoadingScreen({super.key});

//   @override
//   _LoadingScreenState createState() => _LoadingScreenState();
// }

// class _LoadingScreenState extends State<LoadingScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Simulate loading and navigate to quiz screen after 2 seconds
//     Timer(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) => QuizScreen(
//                   quizId: 'hoxHQKMmoUvt6xJU9DMo',
//                 )),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(
//               color: Colors.purple,
//             ),
//             SizedBox(height: 16),
//             Text(
//               "Generating your test...",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//      flutter run -d edge --web-port=8080