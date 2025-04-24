import 'package:flutter/material.dart';
import 'package:translation_app/pages/text-to-text.dart' as text_to_text;
import 'package:translation_app/pages/subscription.dart';
import 'package:translation_app/pages/profilepage.dart';
import 'package:translation_app/pages/picture-to-text.dart';
import 'package:translation_app/pages/voice-to-text.dart';
import 'package:translation_app/pages/phrases.dart' as phrases;
import 'package:translation_app/pages/history_page.dart';
import 'package:translation_app/services/firestore_service.dart';
import 'package:translation_app/models/avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/utils/theme_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = "User";
  String _avatarId = "avatar1";
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    try {
      // Get current user data from Firestore
      final userData = await _firestoreService.getUserProfile();
      if (userData != null) {
        setState(() {
          _userName = userData['name'] ?? "User";
          _avatarId = userData['avatarId'] ?? "avatar1";
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeContent(
            userName: _userName, avatarId: _avatarId, isLoading: _isLoading);
      case 1:
        return SubscriptionPage(languageCode: 'en');
      case 2:
        return ProfilePage();
      default:
        return HomeContent(
            userName: _userName, avatarId: _avatarId, isLoading: _isLoading);
    }
  }

  void _onItemTapped(int index) {
    // Handle all tab navigations within the main page
    setState(() {
      _selectedIndex = index;
    });

    // If navigating to HomePage, refresh user data
    if (index == 0) {
      _loadUserData();
    }
  }

  // Method to manually refresh the homepage data
  Future<void> refreshHomePage() async {
    await _loadUserData();
    setState(() {}); // Trigger UI update
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
    // Get the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
        title: Text(
          "SpeakWise",
          style: TextStyle(
            fontFamily: 'BerlinSansFBDemi',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.blue[400] : Colors.blue[700],
          ),
        ),
        centerTitle: true,
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF121212) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.black12,
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _getNavigationBarItems(isDarkMode),
          currentIndex: _selectedIndex,
          selectedItemColor: isDarkMode ? Colors.blue[400] : Colors.blue[700],
          unselectedItemColor: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
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

  List<BottomNavigationBarItem> _getNavigationBarItems(bool isDarkMode) {
    return [
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Image.asset(
            'assets/logo.png',
            width: 24,
            height: 24,
            color: isDarkMode ? Colors.grey[400] : null,
          ),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Image.asset(
            'assets/logo.png',
            width: 24,
            height: 24,
            color: isDarkMode ? Colors.blue[400] : Colors.blue[700],
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
  final String userName;
  final String avatarId;
  final bool isLoading;

  const HomeContent({
    Key? key,
    required this.userName,
    required this.avatarId,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get theme context
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      color: isDarkMode ? Color(0xFF121212) : Colors.white,
      child: Column(
        children: [
          // Professional header with greeting
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 30, 24, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode 
                  ? [Color(0xFF1A237E), Color(0xFF0D47A1)]
                  : [Colors.blue[600]!, Colors.blue[800]!],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoading ? "Hello..." : "Hello, ${userName}",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "What would you like to translate today?",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.translate,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Translation options
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "TRANSLATION MODES",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // Text to Text
                        _buildModernOption(
                          context,
                          "Text to Text",
                          "Type or paste text for translation",
                          Icons.text_fields_rounded,
                          Colors.blue[isDarkMode ? 400 : 700]!,
                          () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      text_to_text.NormalPage()),
                            );
                          },
                          isDarkMode,
                        ),

                        // Picture to Text
                        _buildModernOption(
                          context,
                          "Picture to Text",
                          "Extract and translate text from images",
                          Icons.image,
                          Colors.green[isDarkMode ? 400 : 600]!,
                          () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PictureToTextPage()),
                            );
                          },
                          isDarkMode,
                        ),

                        // Voice to Text
                        _buildModernOption(
                          context,
                          "Voice to Text",
                          "Speak and translate your voice",
                          Icons.mic,
                          Colors.orange[isDarkMode ? 400 : 600]!,
                          () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VoiceToTextPage()),
                            );
                          },
                          isDarkMode,
                        ),

                        // Common Phrases
                        _buildModernOption(
                          context,
                          "Common Phrases",
                          "View and use helpful translated phrases",
                          Icons.format_quote,
                          Colors.purple[isDarkMode ? 400 : 600]!,
                          () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => phrases.NormalPage()),
                            );
                          },
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    bool isDarkMode,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2, // Slightly more elevation for depth
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.grey[800],
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF2C2C2C) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
