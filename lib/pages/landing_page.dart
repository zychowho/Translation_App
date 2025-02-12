import 'package:flutter/material.dart';
import 'homepage.dart'; // Import your HomePage

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String selectedLanguage = "English UK (Default)";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100], // Light blue background
      appBar: AppBar(
        automaticallyImplyLeading: false, // ❌ Removes back arrow
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Choose Your Language:",
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              // 🚪 Handle log out
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔍 Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search your language",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.yellow),
                ),
              ),
            ),
            SizedBox(height: 20),

            // 🌍 Language List
            Expanded(
              child: ListView(
                children: [
                  _buildLanguageTile("English UK (Default)", "🇬🇧"),
                  _buildLanguageTile("Korean", "🇰🇷", showHand: true),
                  _buildLanguageTile("Thai", "🇹🇭"),
                  _buildLanguageTile("Kanji", "🇯🇵"),
                ],
              ),
            ),

            // ✅ Select Button (Navigates to HomePage)
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to HomePage after selecting a language
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Select",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Language Tile Widget
  Widget _buildLanguageTile(String language, String flag, {bool showHand = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selectedLanguage == language ? Colors.blue[200] : Colors.transparent,
          border: Border.all(color: Colors.blue.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Text(
              language,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            if (showHand) Spacer(),
          ],
        ),
      ),
    );
  }
}
