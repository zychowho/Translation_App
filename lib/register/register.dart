import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:translation_app/register/email_verification_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String passwordPattern =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Registration Form
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: mediaQuery.size.width * 0.1,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(130, 143, 143, 143),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildInputField('Name', name),
                    const SizedBox(height: 20),
                    _buildInputField('Email', email),
                    const SizedBox(height: 20),
                    _buildInputField('Password', password, isPassword: true),
                    const SizedBox(height: 20),
                    _buildRegisterButton(mediaQuery),
                    const SizedBox(height: 10),
                    _buildGoogleSignInButton(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already Have An Account? ',
                            style: TextStyle(color: Colors.white)),
                        GestureDetector(
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 22, color: Colors.white),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscureText,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Color(0xFFFFEB3B),
                  width: 2.0,
                ),
              ),
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : null,
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(MediaQueryData mediaQuery) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
          _showErrorDialog('Please fill in all fields.');
          return;
        }
        if (!RegExp(passwordPattern).hasMatch(password.text)) {
          _showErrorDialog(
              'Password must be at least 8 characters, include an uppercase letter, a lowercase letter, a number, and a special character.');
          return;
        }
        if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email.text)) {
          _showErrorDialog('The email address is badly formatted.');
          return;
        }

        try {
          UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
            email: email.text,
            password: password.text,
          );

          User? user = userCredential.user;

          if (user != null) {
            await user.sendEmailVerification();
            await _firestore.collection('Users').doc(user.uid).set({
              'name': name.text,
              'email': email.text,
              'createdAt': Timestamp.now(),
            });

            _showSuccessDialog(
                'Registration successful! A verification email has been sent.');
          }
        } catch (e) {
          _showErrorDialog(e.toString());
        }
      },
      child: Container(
        height: mediaQuery.size.height * 0.06,
        width: mediaQuery.size.width * 0.5,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 15, 5, 93),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'REGISTER',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _signInWithGoogle,
      child: Container(
        height: 50,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/google.png', height: 30),
            const SizedBox(width: 10),
            const Text('Sign in with Google',
                style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _showErrorDialog("Google Sign-In failed. Try again.");
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
                );

              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
