import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:translation_app/login/login.dart';
import 'package:translation_app/register/register.dart';
import 'package:translation_app/homescreen/choose-language.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translation_app/pages/homepage.dart';

class HomeScreen extends StatefulWidget {
  final String languageCode;

  const HomeScreen({Key? key, required this.languageCode}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final translator = GoogleTranslator();
  String selectedLanguage = "English";
  String languageCode = "en";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String translatedSignUp = "Sign Up";
  String translatedSignIn = "Sign In";

  @override
  void initState() {
    super.initState();
    languageCode = widget.languageCode;
    translateContent();

    // Check if user is already logged in
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    // If user is already logged in, go to HomePage
    if (_auth.currentUser != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
    }
  }

  Future<void> translateContent() async {
    final translations = await Future.wait([
      translator.translate("Sign Up", from: 'en', to: languageCode),
      translator.translate("Sign In", from: 'en', to: languageCode),
    ]);

    setState(() {
      translatedSignUp = translations[0].text;
      translatedSignIn = translations[1].text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topCenter,
            colors: [
              Colors.lightBlue.shade700,
              Colors.lightBlue.shade300,
              Colors.white
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseLanguageScreen(
                          currentLanguage:
                              selectedLanguage, // Pass the selected language
                        ),
                      ),
                    );

                    if (result != null && result is Map<String, String>) {
                      setState(() {
                        selectedLanguage = result["name"]!;
                        languageCode = result["code"]!;
                        translateContent();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    '🌍 ' + selectedLanguage,
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ),
            ),
            SizedBox(height: 140),
            Center(
              child: Image.asset(
                'assets/speakwise.png',
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Speak clearly, choose wisely!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Column(
              children: [
                SizedBox(
                  width: 250,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  RegisterScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                      begin: Offset(1.0, 0.0), end: Offset.zero)
                                  .animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      side: BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        translatedSignUp,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LoginScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                      begin: Offset(1.0, 0.0), end: Offset.zero)
                                  .animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      backgroundColor: Colors.white,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        translatedSignIn,
                        style: TextStyle(fontSize: 18, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
