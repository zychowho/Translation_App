import 'package:flutter/material.dart';
import 'package:translation_app/pages/text-to-text.dart' as text_to_text;
import 'package:translation_app/pages/subscription.dart';
import 'package:translation_app/pages/profilepage.dart';
import 'package:translation_app/pages/picture-to-text.dart';
import 'package:translation_app/pages/voice-to-text.dart';
import 'package:translation_app/pages/phrases.dart' as phrases;
import 'package:translation_app/pages/history_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    HomeContent(),
    SubscriptionPage(
      languageCode: 'en',
    ),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _showLogoutConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Logout"),
            content: Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel logout
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // Confirm logout
                },
                child: Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "SpeakWise",
          style: TextStyle(
            fontFamily: 'BerlinSansFBDemi',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.blue[700]),
            tooltip: 'Translation History',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryPage()));
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _getNavigationBarItems(),
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Image.asset(
            'assets/logo.png',
            width: 24,
            height: 24,
          ),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Image.asset(
            'assets/logo.png',
            width: 24,
            height: 24,
            color: Colors.blue[700],
          ),
        ),
        label: 'Translate',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.star),
        label: 'Premium',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ];
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header with greeting and illustration
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello,",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "What would you like to translate today?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),

          // Translation options
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                Text(
                  "Translation Modes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                // Text to Text
                _buildModernOption(
                  context,
                  "Text to Text",
                  "Type or paste text for translation",
                  Icons.text_fields_rounded,
                  Colors.blue[700]!,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => text_to_text.NormalPage()),
                    );
                  },
                ),

                // Picture to Text
                _buildModernOption(
                  context,
                  "Picture to Text",
                  "Extract and translate text from images",
                  Icons.image,
                  Colors.green[600]!,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PictureToTextPage()),
                    );
                  },
                ),

                // Voice to Text
                _buildModernOption(
                  context,
                  "Voice to Text",
                  "Speak and translate your voice",
                  Icons.mic,
                  Colors.orange[600]!,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VoiceToTextPage()),
                    );
                  },
                ),

                // Common Phrases - replaced Picture to Voice
                _buildModernOption(
                  context,
                  "Common Phrases",
                  "View and use helpful translated phrases",
                  Icons.format_quote,
                  Colors.purple[600]!,
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => phrases.NormalPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
