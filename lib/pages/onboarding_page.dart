import 'package:flutter/material.dart';
import 'package:translation_app/pages/normal_page.dart'; // Import the normal page

class OnboardingPage extends StatefulWidget {
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

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToNormalPage();
    }
  }

  void _goToNormalPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => NormalPage()), // Navigate to normal page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  onPressed: _goToNormalPage,
                  child: Text("Skip", style: TextStyle(color: Colors.red)),
                ),
                Row(
                  children: List.generate(
                    onboardingData.length,
                        (index) => _buildDot(index),
                  ),
                ),
                TextButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentIndex == onboardingData.length - 1 ? "Finish" : "Next",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent(String image, String title, String description) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          Container(
            height: 250,
            child: Center(
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: _currentIndex == index ? 12 : 8,
      height: _currentIndex == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _currentIndex == index ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}