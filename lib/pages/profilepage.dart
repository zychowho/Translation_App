import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translation_app/homescreen/homescreen.dart';
import 'package:translation_app/services/firestore_service.dart';
import 'package:translation_app/models/translation_history.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // User data
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = "";
  String _userEmail = "";
  bool _isLoading = true;
  String _selectedHistoryType = 'all';

  // For tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Set email from Auth
        _userEmail = currentUser.email ?? "No email found";

        // Try to get user data from Firestore
        final userData = await _firestoreService.getUserProfile();
        if (userData != null) {
          setState(() {
            _userName = userData['name'] ?? "User";
          });
        } else {
          _userName = "User";
        }
      }
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Navigate to HomeScreen after logout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen(languageCode: 'en')),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Widget _buildHistoryTypeFilter() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8),
          _buildFilterChip('Text', 'text'),
          SizedBox(width: 8),
          _buildFilterChip('Image', 'image'),
          SizedBox(width: 8),
          _buildFilterChip('Voice', 'voice'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    bool isSelected = _selectedHistoryType == filterValue;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedHistoryType = filterValue;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[700] : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _formatDate(DateTime timestamp) {
    return DateFormat('MMM d, yyyy · h:mm a').format(timestamp);
  }

  String _getLanguageName(String code) {
    final Map<String, String> languageMap = {
      'auto': 'Auto-detect',
      'af': 'Afrikaans',
      'sq': 'Albanian',
      'am': 'Amharic',
      'ar': 'Arabic',
      'hy': 'Armenian',
      'eu': 'Basque',
      'bn': 'Bengali',
      'bg': 'Bulgarian',
      'ca': 'Catalan',
      'ny': 'Chichewa',
      'zh-cn': 'Chinese (Simplified)',
      'zh-tw': 'Chinese (Traditional)',
      'hr': 'Croatian',
      'cs': 'Czech',
      'da': 'Danish',
      'nl': 'Dutch',
      'en': 'English',
      'et': 'Estonian',
      'tl': 'Filipino',
      'fi': 'Finnish',
      'fr': 'French',
      'de': 'German',
      'el': 'Greek',
      'gu': 'Gujarati',
      'ha': 'Hausa',
      'iw': 'Hebrew',
      'hi': 'Hindi',
      'hu': 'Hungarian',
      'is': 'Icelandic',
      'ig': 'Igbo',
      'id': 'Indonesian',
      'it': 'Italian',
      'ja': 'Japanese',
      'kn': 'Kannada',
      'km': 'Khmer',
      'ko': 'Korean',
      'la': 'Latin',
      'lv': 'Latvian',
      'lt': 'Lithuanian',
      'ms': 'Malay',
      'ml': 'Malayalam',
      'mr': 'Marathi',
      'my': 'Myanmar (Burmese)',
      'ne': 'Nepali',
      'no': 'Norwegian',
      'pl': 'Polish',
      'pt': 'Portuguese',
      'ro': 'Romanian',
      'ru': 'Russian',
      'sr': 'Serbian',
      'si': 'Sinhala',
      'sk': 'Slovak',
      'sl': 'Slovenian',
      'es': 'Spanish',
      'sw': 'Swahili',
      'sv': 'Swedish',
      'ta': 'Tamil',
      'te': 'Telugu',
      'th': 'Thai',
      'tr': 'Turkish',
      'uk': 'Ukrainian',
      'ur': 'Urdu',
      'vi': 'Vietnamese',
      'cy': 'Welsh',
      'yo': 'Yoruba',
      'zu': 'Zulu'
    };

    return languageMap[code] ?? code;
  }

  Widget _buildHistoryList() {
    return StreamBuilder<List<TranslationHistory>>(
      stream: _firestoreService.getTranslationHistory(
          type: _selectedHistoryType != 'all' ? _selectedHistoryType : null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading history: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final historyItems = snapshot.data ?? [];

        if (historyItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No translation history yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your translations will appear here',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: historyItems.length,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemBuilder: (context, index) {
            final item = historyItems[index];

            // Choose icon based on translation type
            IconData typeIcon;
            Color typeColor;

            switch (item.type) {
              case 'image':
                typeIcon = Icons.image;
                typeColor = Colors.green;
                break;
              case 'voice':
                typeIcon = Icons.mic;
                typeColor = Colors.orange;
                break;
              case 'text':
              default:
                typeIcon = Icons.text_fields;
                typeColor = Colors.blue;
                break;
            }

            return Dismissible(
              key: Key(item.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _firestoreService.deleteTranslation(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Translation deleted')),
                );
              },
              child: Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              typeIcon,
                              color: typeColor,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_getLanguageName(item.sourceLanguage)} → ${_getLanguageName(item.targetLanguage)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(item.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        item.originalText,
                        style: TextStyle(fontSize: 16),
                      ),
                      Divider(height: 24),
                      Text(
                        item.translatedText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 24, right: 24),
                        child: Column(
                          children: [
                            // Simple avatar icon instead of profile picture
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 12),
                            // Profile name
                            Text(
                              _userName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(text: "Profile", icon: Icon(Icons.person)),
                            Tab(text: "History", icon: Icon(Icons.history)),
                          ],
                          labelColor: Colors.blue[700],
                          unselectedLabelColor: Colors.grey[600],
                          indicatorColor: Colors.blue[700],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Profile Settings Tab
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 16, top: 8),
                                child: Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // Account settings option
                              _buildModernOption(
                                context,
                                "Account Settings",
                                "Privacy and security",
                                Icons.person_outline,
                                Colors.blue[700]!,
                                () {
                                  // Navigate to account settings
                                },
                              ),

                              // Language preferences option
                              _buildModernOption(
                                context,
                                "Language Preferences",
                                "Change your preferred languages",
                                Icons.language,
                                Colors.green[600]!,
                                () {
                                  // Navigate to language preferences
                                },
                              ),

                              // Appearance option
                              _buildModernOption(
                                context,
                                "Appearance",
                                "Dark mode, theme settings",
                                Icons.color_lens_outlined,
                                Colors.purple[600]!,
                                () {
                                  // Navigate to appearance settings
                                },
                              ),

                              SizedBox(height: 20),

                              // Add Logout Button
                              ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.logout, color: Colors.red),
                                ),
                                title: Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                onTap: () => _showLogoutConfirmation(context),
                              ),

                              // Add extra space at the bottom for scrolling
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // History Tab
                    Column(
                      children: [
                        _buildHistoryTypeFilter(),
                        Expanded(
                          child: _buildHistoryList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Logout"),
            content: Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _signOut();
    }
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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
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
