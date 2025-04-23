import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translation_app/login/login.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    print("EmailVerificationScreen: initState called");

    try {
      _user = _auth.currentUser!;
      print("EmailVerificationScreen: Current user loaded: ${_user.email}");
    } catch (e) {
      print("EmailVerificationScreen: Error loading user: $e");
      // Handle the case where currentUser is null
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }
  }

  Future<void> _checkEmailVerified() async {
    print("EmailVerificationScreen: Starting email verification check");
    setState(() => _isVerifying = true);

    try {
      print("EmailVerificationScreen: Reloading user data");
      // Reload the user object to get the latest data
      await _user.reload();
      _user = _auth.currentUser!;
      print("EmailVerificationScreen: User reloaded successfully");

      print(
          "EmailVerificationScreen: Verification status: ${_user.emailVerified}");
      if (_user.emailVerified) {
        print(
            "EmailVerificationScreen: Email is verified, preparing to navigate to login");
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully! You can now log in.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        Future.delayed(const Duration(seconds: 2), () {
          print("EmailVerificationScreen: Navigating to login screen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } else {
        print("EmailVerificationScreen: Email is not verified yet");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your email is not verified yet. Please check your inbox and spam folder.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("EmailVerificationScreen: Error during verification check: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      print("EmailVerificationScreen: Verification check completed");
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    print("EmailVerificationScreen: Attempting to resend verification email");
    setState(() => _isResending = true);

    try {
      print(
          "EmailVerificationScreen: Sending verification email to ${_user.email}");
      await _user.sendEmailVerification();
      print("EmailVerificationScreen: Verification email sent successfully");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Please check your inbox.'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      print("EmailVerificationScreen: Error sending verification email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      print("EmailVerificationScreen: Resend operation completed");
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 24),
              Text(
                'Almost there!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'We sent a verification email to:',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '${_user.email}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Please check your email and click the verification link before continuing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      _isVerifying
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _checkEmailVerified,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                'I\'ve verified my email',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                      SizedBox(height: 16),
                      _isResending
                          ? CircularProgressIndicator(strokeWidth: 2)
                          : TextButton.icon(
                              onPressed: _resendVerificationEmail,
                              icon: Icon(Icons.refresh),
                              label: Text('Resend verification email'),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: _navigateToLogin,
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
