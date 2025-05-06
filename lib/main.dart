import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_generator/homeScreen.dart';
import 'package:test_generator/Auth/auth.dart';
import 'package:test_generator/firebase_options.dart';
import 'package:test_generator/services/local_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use FirebaseOptions
    );
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }

  // Initialize local cache
  await LocalCacheService.init();
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
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

// flutter run -d edge --web-port=8080