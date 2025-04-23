import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'email_verification_screen.dart';
import 'package:translation_app/login/login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String passwordPattern =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';

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
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/speakwise.png',
                          width: MediaQuery.of(context).size.width * 0.8,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 40),
                        _buildTextField(name, 'Name'),
                        SizedBox(height: 30),
                        _buildTextField(email, 'Email', isEmail: true),
                        SizedBox(height: 30),
                        _buildPasswordField(),
                        SizedBox(height: 30),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 100),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blue),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text.rich(
                TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(
                      text: "Log in here.",
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.normal),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Builds a standard text field
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isEmail = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(),
      ),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
    );
  }

  /// 🔹 Builds the password field
  Widget _buildPasswordField() {
    return TextField(
      controller: password,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        border: UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  /// ✅ **Registers the user with Firebase**
  void _register() async {
    if (_isLoading) return; // Prevent multiple presses

    // Basic validation
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      _showErrorDialog("All fields are required.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      try {
        // Try to store user data in Firestore, but don't let it block the process
        await _firestore.collection('Users').doc(userCredential.user!.uid).set({
          'name': name.text,
          'email': email.text.trim(),
          'createdAt': Timestamp.now(),
        }).timeout(Duration(seconds: 3)); // Add timeout to avoid hanging
      } catch (firestoreError) {
        // Ignore Firestore errors and continue with the registration process
        print("Firestore error (ignored): $firestoreError");
      }

      // Make sure to update the UI regardless of Firestore success
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showVerificationDialog();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (e.code == 'email-already-in-use') {
          _showErrorDialog("This email is already registered.");
        } else if (e.code == 'weak-password') {
          _showErrorDialog("Your password is too weak.");
        } else if (e.code == 'invalid-email') {
          _showErrorDialog("Invalid email format.");
        } else {
          _showErrorDialog(e.message ?? "An error occurred.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("An error occurred: $e");
      }
    }
  }

  // Show a dialog with verification instructions
  void _showVerificationDialog() {
    // Store the current user for resending verification
    User? currentUser = _auth.currentUser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Verify Your Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              size: 60,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              "Registration successful!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We've sent a verification email to:",
              textAlign: TextAlign.center,
            ),
            Text(
              email.text.trim(),
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Please check your inbox and click the verification link before logging in.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Attempt to resend verification email
              if (currentUser != null) {
                try {
                  await currentUser.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Verification email sent again!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error sending email: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text("Resend Email"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog

              // Navigate to login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Go to Login"),
          ),
        ],
      ),
    );
  }

  /// 📌 Shows error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
