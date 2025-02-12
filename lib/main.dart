import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:translation_app/login/login.dart';
import 'package:translation_app/register/register.dart';
import 'package:translation_app/homescreen/homescreen.dart';
import 'package:translation_app/pages/landing_page.dart';
import 'package:translation_app/forgotpassword/forgotpassword.dart';
import 'package:translation_app/pages/onboarding_page.dart'; // Import Onboarding Page
import 'package:translation_app/register/email_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translation App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/pages': (context) => LandingPage(),
        '/register': (context) => RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/onboarding_page': (context) => OnboardingPage(),
        '/email-verification': (context) => EmailVerificationScreen(),

      },
    );
  }
}
