import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_generator/Auth/auth.dart';
import 'package:test_generator/View/Screens/bloc/home_bloc.dart';
import 'package:test_generator/View/Screens/bloc/home_event.dart';
import 'package:test_generator/View/Screens/bloc/home_state.dart';
import 'package:test_generator/View/Screens/customize_quiz.dart';
import 'package:test_generator/View/Screens/settings.dart';
import 'package:test_generator/View/Screens/user_profile.dart';
import 'package:test_generator/View/Screens/history_screen.dart';
import 'package:test_generator/View/Screens/Quizz/quizScreen.dart';
import 'package:test_generator/services/auth_service.dart';
import 'package:test_generator/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onItemTapped(int index, BuildContext context) async {
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
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
        setState(() => _selectedIndex = 0);

        if (result != null && result is Map<String, dynamic>) {
          if (result['action'] == 'upgrade') {
            context
                .read<HomeBloc>()
                .add(UpdateQuizSettings(difficulty: result['difficulty']));
          }
          controller.text = result['topic'];
          _generateQuiz(context);
        }
        break;
      // case 2:
      //   showModalBottomSheet(
      //     context: context,
      //     isScrollControlled: true,
      //     backgroundColor: Colors.transparent,
      //     builder: (BuildContext context) => QuizSettingsScreen(),
      //   ).then((_) => setState(() => _selectedIndex = 0));
      //   break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
    }
  }

  void _generateQuiz(BuildContext context) {
    final topic = controller.text.trim();
    if (topic.isEmpty) return;

    context.read<HomeBloc>().add(GenerateQuiz(topic: topic));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(userService: UserService())..add(LoadUserData()),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is HomeLoaded && state.generatedQuizId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(quizId: state.generatedQuizId!),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                state is HomeLoaded
                    ? "Welcome ${state.userName ?? ''}!"
                    : "Welcome!",
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
                      backgroundImage:
                          state is HomeLoaded && state.profilePic != null
                              ? NetworkImage(state.profilePic!)
                              : const AssetImage('assets/profile.jpg')
                                  as ImageProvider,
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
                          backgroundImage:
                              state is HomeLoaded && state.profilePic != null
                                  ? NetworkImage(state.profilePic!)
                                  : const AssetImage('assets/profile.jpg')
                                      as ImageProvider,
                          radius: 45,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state is HomeLoaded ? state.userName ?? 'Dev' : 'Dev',
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
                        MaterialPageRoute(
                            builder: (context) => UserProfileScreen()),
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
                        MaterialPageRoute(
                            builder: (context) => HistoryScreen()),
                      );
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.settings),
                  //   title: const Text('Settings'),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     showModalBottomSheet(
                  //       context: context,
                  //       isScrollControlled: true,
                  //       backgroundColor: Colors.transparent,
                  //       builder: (BuildContext context) => QuizSettingsScreen(),
                  //     );
                  //   },
                  // ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      _authService.signOut().then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                Center(
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
                          controller: controller,
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
                              onPressed: () => _generateQuiz(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is HomeLoaded && state.isGenerating)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.purple),
                          SizedBox(height: 16),
                          Text(
                            "Generating your test...",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
              onTap: (index) => _onItemTapped(index, context),
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
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.settings),
                //   label: 'Settings',
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
