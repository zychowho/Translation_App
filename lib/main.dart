import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translation_app/login/login.dart';
import 'package:translation_app/pages/profilepage.dart';
import 'package:translation_app/register/register.dart';
import 'package:translation_app/homescreen/homescreen.dart';
import 'package:translation_app/pages/landing_page.dart';
import 'package:translation_app/forgotpassword/forgotpassword.dart';
import 'package:translation_app/pages/onboarding_page.dart'; // Import On2boarding Page

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Default to false (show onboarding)
  bool hasSeenOnboarding = false;

  try {
    // Try to get SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  } catch (e) {
    // If there's an error, log it but continue with default value
    print('Error accessing SharedPreferences: $e');
  }

  // Run the app with the determined state
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translation App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // Always go to login screen first
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, String>?;
          return HomeScreen(languageCode: args?['languageCode'] ?? 'en');
        },
        '/pages': (context) => LandingPage(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/onboarding_page': (context) => OnboardingPage(),
        '/profilepage': (context) => ProfilePage(),
      },
    );
  }
}
