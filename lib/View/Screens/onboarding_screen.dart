import 'package:flutter/material.dart';
import 'package:test_generator/Auth/auth.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to Quizzly!',
      'description':
          'Quizzly transforms your documents or required topic into interactive quizzes, making study sessions fun and interactive!',
      'image': 'assets/Screens/StartUpSlides/1.png'
    },
    {
      'title': 'Learn Smarter',
      'description':
          'Upload documents or enter topics to generate personalized quizzes tailored to your learning needs.',
      'image': 'assets/Screens/StartUpSlides/2.png'
    },
    {
      'title': 'Track Your Progress',
      'description':
          'Monitor your performance, review past quizzes, and see your improvement over time.',
      'image': 'assets/Screens/StartUpSlides/3.png'
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Overlay
          Image.asset(
            'assets/Screens/Splash/background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            color: Colors.white
                .withOpacity(0.85), // White overlay to fade background
          ),

          // Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _nextPage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Center image
                    Image.asset(
                      _onboardingData[index]['image']!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    // Title
                    Text(
                      _onboardingData[index]['title']!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _onboardingData[index]['description']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Page Indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 25 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.purple : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
