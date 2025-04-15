import 'package:flutter/material.dart';
import 'package:test_generator/Auth/auth.dart';
import 'package:test_generator/View/Screens/customize_quiz.dart';
import 'package:test_generator/View/Screens/loading_screen.dart';
import 'package:test_generator/View/Screens/settings.dart';
import 'package:test_generator/View/Screens/user_profile.dart';
import 'package:test_generator/View/Screens/history_screen.dart';
import 'package:test_generator/main.dart';
import 'package:test_generator/Services/user_service.dart';
import 'package:test_generator/services/auth_service.dart'; // Import UserService
import 'package:test_generator/services/quiz_generator_service.dart';
import 'package:test_generator/services/quiz_upload_service.dart'; // Import QuizGeneratorService

void main() {
  runApp(MyApp());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService(); // Add UserService instance
  final AuthService _authService = AuthService(); // Add AuthService instance
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller =
      TextEditingController(); // Add controller

  String? userName;
  String? profilePic;

  @override
  void initState() {
    super.initState();
    fetchUserInfo(); // Fetch user info on initialization
  }

  void fetchUserInfo() async {
    Map<String, dynamic>? userData = await _userService.getUserDetails();

    if (userData != null) {
      setState(() {
        userName = userData['name'];
        profilePic = userData['profile_pic'];
      });
    } else {
      print("No user data found.");
    }
  }

  void fetchQuiz() async {
    print("Fetching quiz..."); // Debugging line
    final userInput = controller.text.trim(); // Get user input
    if (userInput.isEmpty) {
      print("❌ Please enter a topic.");
      return;
    }

    final prompt = """
Generate a JSON array of 10 multiple-choice questions on $userInput. Each object in the array must follow this exact format:

{
  "question": "What does HTML stand for?",
  "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
  "correctIndex": 0
}
Correct index can go from 0 to 3. The question should be related to the topic and the options should be plausible answers. The correct answer should be one of the options.
Only return the JSON array. No numbering. No explanation. No additional text or formatting.
""";

    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LoadingScreen(
        uploadQuizTask: () async {
          final quiz = await QuizGeneratorService.generateQuiz(prompt);
          print("Quiz generated: $quiz"); // Debugging line
          if (quiz.isNotEmpty) { 
            final quizId = await FirebaseQuizService.uploadQuiz(quiz);
            print("✅ Uploaded quiz with ID: $quizId");
            return quizId!;
          } else {
            throw Exception("❌ Failed to generate quiz");
          }
        },
      ),
    ),
  );
    
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
      case 2:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) => QuizSettingsScreen(),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Welcome ${userName ?? ''}!",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: profilePic != null
                    ? NetworkImage(profilePic!)
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
                radius: 20,
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple[100],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: profilePic != null
                        ? NetworkImage(profilePic!)
                        : const AssetImage('assets/profile.jpg')
                            as ImageProvider,
                    radius: 45,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName ?? 'Dev',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) => QuizSettingsScreen(),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Add logout functionality here
                _authService.signOut().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                });

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What test would you like to generate today?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller, // Use the controller
                decoration: InputDecoration(
                  hintText: "Enter a topic...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      fetchQuiz(); // Call fetchQuiz when the send button is pressed
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 140,
        height: 48,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.purple[100],
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return QuizCustomizationScreen();
              },
            );
          },
          label: const Text(
            'New Quiz',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.black87,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
