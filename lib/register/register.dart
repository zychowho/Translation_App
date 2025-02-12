import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String passwordPattern = r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                  ],
                ),
                SizedBox(height: 30),
                _buildInputField('NAME', name),
                SizedBox(height: 20),
                _buildInputField('EMAIL', email),
                SizedBox(height: 20),
                _buildInputField('PASSWORD', password, isPassword: true),
                SizedBox(height: 30),
                _buildRegisterButton(mediaQuery),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already Have An Account? ', style: TextStyle(color: Colors.black87)),
                    GestureDetector(
                      child: Text(
                        'Log In',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black38,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            border: InputBorder.none,
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
          ),
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(MediaQueryData mediaQuery) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        // Your validation and registration code
        if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
          _showErrorDialog('Please fill in all fields.');
        } else if (!RegExp(passwordPattern).hasMatch(password.text)) {
          _showErrorDialog('Password must be at least 8 characters, include an uppercase letter, a lowercase letter, a number, and a special character.');
        } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email.text)) {
          _showErrorDialog('The email address is badly formatted.');
        } else {
          try {
            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
              email: email.text,
              password: password.text,
            );

            await _firestore.collection('Users').doc(userCredential.user!.uid).set({
              'name': name.text,
              'email': email.text,
              'createdAt': Timestamp.now(),
            });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('Registration successful!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          } catch (e) {
            _showErrorDialog(e.toString());
          }
        }
      },
      child: Container(
        height: mediaQuery.size.height * 0.06,
        width: mediaQuery.size.width * 0.5,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'REGISTER',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

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