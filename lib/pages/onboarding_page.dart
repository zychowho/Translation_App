import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translation_app/pages/homepage.dart';
import 'package:translation_app/login/login.dart';

class OnboardingPage extends StatefulWidget {
  final String? userId;

  OnboardingPage({this.userId});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/logo.png",
      "title": "Welcome to SpeakWise!",
      "description": "Your personal translation assistant at your fingertips.",
    },
    {
      "image": "assets/logo.png",
      "title": "Text-to-Text Translation",
      "description": "Easily translate text between multiple languages.",
    },
    {
      "image": "assets/logo.png",
      "title": "Voice Recognition",
      "description": "Speak and get real-time translations instantly.",
    },
    {
      "image": "assets/logo.png",
      "title": "Camera Translation",
      "description": "Translate text from images using your camera.",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Remove the automatic check that skips onboarding
  }

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHomePage();
    }
  }

  void _goToHomePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Set both the general flag and the user-specific flag
    await prefs.setBool('hasSeenOnboarding', true);

    // If we have a userId, set a user-specific flag
    if (widget.userId != null) {
      await prefs.setBool('user_onboarded_${widget.userId}', true);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return _buildOnboardingContent(
                  onboardingData[index]["image"]!,
                  onboardingData[index]["title"]!,
                  onboardingData[index]["description"]!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _goToHomePage,
                  child: Text("Skip", style: TextStyle(color: Colors.grey)),
                ),
                Row(
                  children: List.generate(
                    onboardingData.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                _currentIndex == onboardingData.length - 1
                    ? TextButton(
                        onPressed: _goToHomePage,
                        child: Text("Finish",
                            style: TextStyle(color: Colors.blue)),
                      )
                    : TextButton(
                        onPressed: _nextPage,
                        child:
                            Text("Next", style: TextStyle(color: Colors.blue)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent(
      String image, String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 250, fit: BoxFit.contain),
        SizedBox(height: 30),
        Text(title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
