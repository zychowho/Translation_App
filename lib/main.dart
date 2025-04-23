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
import 'package:translation_app/pages/history_page.dart'; // Import History Page
import 'package:translation_app/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translation_app/services/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Default to false (show onboarding)
  bool hasSeenOnboarding = false;
  bool firebaseInitialized = false;

  try {
    // Initialize Firebase with the project configuration
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: FirebaseConfig.webApiKey,
        appId:
            '1:${FirebaseConfig.projectNumber}:web:12345abcdef', // Should be replaced with actual app ID
        messagingSenderId: FirebaseConfig.projectNumber,
        projectId: FirebaseConfig.projectId,
        storageBucket: '${FirebaseConfig.projectId}.appspot.com',
      ),
    );

    // Enable Firestore offline persistence
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    firebaseInitialized = true;
    print("Firebase successfully initialized");
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Continue without Firebase - will be handled in app
  }

  try {
    // Try to get SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  } catch (e) {
    // If there's an error, log it but continue with default value
    print('Error accessing SharedPreferences: $e');
  }

  // Run the app with the determined state
  runApp(MyApp(
    hasSeenOnboarding: hasSeenOnboarding,
    firebaseInitialized: firebaseInitialized,
  ));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool firebaseInitialized;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.firebaseInitialized,
  });

  @override
  Widget build(BuildContext context) {
    // Default to home screen if Firebase isn't initialized
    String initialRoute = '/home';

    if (firebaseInitialized) {
      // Only check auth state if Firebase is initialized
      try {
        final User? currentUser = _auth.currentUser;
        initialRoute = currentUser != null ? '/pages' : '/home';
      } catch (e) {
        print("Error checking auth state: $e");
        // Default to home on error
      }
    }

    return MaterialApp(
      title: 'Translation App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) {
          return HomeScreen(languageCode: 'en');
        },
        '/pages': (context) => HomePage(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/onboarding_page': (context) => OnboardingPage(),
        '/profilepage': (context) => ProfilePage(),
        '/history': (context) => HistoryPage(), // Add history route
      },
    );
  }
}
