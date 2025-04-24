import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translation_app/homescreen/homescreen.dart';
import 'package:translation_app/services/firestore_service.dart';
import 'package:translation_app/models/translation_history.dart';
import 'package:translation_app/models/avatar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/utils/theme_provider.dart';
import 'package:translation_app/pages/homepage.dart';

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
  String _selectedAvatarId = "avatar1"; // Default avatar
  bool _isLoading = true;
  String _selectedHistoryType = 'all';
  
  // Add these controllers for account settings
  final TextEditingController nameController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _isUpdatingName = false;
  bool _isUpdatingPassword = false;

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
            _selectedAvatarId = userData['avatarId'] ?? "avatar1";
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

  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Avatar",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height *
                    0.6, // Taller to fit more avatars
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics:
                      AlwaysScrollableScrollPhysics(), // Ensure it's scrollable
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1, // Perfect squares
                  ),
                  itemCount: avatarOptions.length,
                  itemBuilder: (context, index) {
                    final avatar = avatarOptions[index];
                    final isSelected = avatar.id == _selectedAvatarId;

                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _selectedAvatarId = avatar.id;
                        });

                        Navigator.of(context).pop();

                        // Update avatar in Firestore
                        await _firestoreService.updateUserAvatar(avatar.id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            avatar.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.person),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
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
                            // Avatar with selection functionality
                            GestureDetector(
                              onTap: _showAvatarSelectionDialog,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                backgroundImage: AssetImage(
                                  avatarOptions
                                      .firstWhere(
                                        (avatar) =>
                                            avatar.id == _selectedAvatarId,
                                        orElse: () => avatarOptions.first,
                                      )
                                      .assetPath,
                                ),
                                onBackgroundImageError: (e, s) => Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            // Profile name
                            Text(
                              _userName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
                          labelColor: isDarkMode ? Colors.blue[400] : Colors.blue[700],
                          unselectedLabelColor: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                          indicatorColor: isDarkMode ? Colors.blue[400] : Colors.blue[700],
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
                        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.grey[50],
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
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),

                              // Change Avatar option (moved to first position)
                              _buildModernOption(
                                context,
                                "Change Avatar",
                                "Select profile picture",
                                Icons.face,
                                Colors.orange[600]!,
                                _showAvatarSelectionDialog,
                              ),

                              // Appearance option with dark mode toggle
                              _buildDarkModeOption(
                                context,
                                themeProvider,
                              ),

                              // Account settings option (moved to third position)
                              _buildModernOption(
                                context,
                                "Account Settings",
                                "Privacy and security",
                                Icons.person_outline,
                                Colors.blue[700]!,
                                _showAccountSettingsDialog,
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
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
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
                        color: isDarkMode ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New method for Dark Mode toggle
  Widget _buildDarkModeOption(BuildContext context, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple[600]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.purple[600],
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appearance",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Dark mode",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDarkMode,
              onChanged: (_) {
                themeProvider.toggleTheme();
              },
              activeColor: Colors.purple[600],
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSettingsDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Set the initial name
    nameController.text = _userName;
    
    // Clear password controllers
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Account Settings",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Name Section
                    Text(
                      "Display Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.grey[100],
                        hintText: "Enter your name",
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : null,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdatingName ? null : () async {
                          if (nameController.text.trim().isEmpty) {
                            _showMessage('Name cannot be empty');
                            return;
                          }
                          
                          setState(() {
                            _isUpdatingName = true;
                          });
                          
                          try {
                            // Update name in Firestore
                            await _firestoreService.updateUserProfile(
                              name: nameController.text.trim(),
                            );
                            
                            // Update local state
                            this.setState(() {
                              _userName = nameController.text.trim();
                            });
                            
                            _showMessage('Name updated successfully');
                          } catch (e) {
                            _showMessage('Error updating name: $e');
                          } finally {
                            setState(() {
                              _isUpdatingName = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: isDarkMode 
                              ? Colors.blue[900]!.withOpacity(0.6) 
                              : Colors.blue.withOpacity(0.6),
                        ),
                        child: _isUpdatingName
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text("Update Name", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    
                    Divider(height: 32, thickness: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                    
                    // Password Section
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildPasswordField(
                      controller: currentPasswordController,
                      label: "Current Password",
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 12),
                    _buildPasswordField(
                      controller: newPasswordController,
                      label: "New Password",
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 12),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: "Confirm New Password",
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdatingPassword ? null : () async {
                          if (currentPasswordController.text.isEmpty ||
                              newPasswordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty) {
                            _showMessage('All password fields are required');
                            return;
                          }

                          if (newPasswordController.text != confirmPasswordController.text) {
                            _showMessage('New passwords do not match');
                            return;
                          }

                          setState(() {
                            _isUpdatingPassword = true;
                          });

                          try {
                            User? user = _auth.currentUser;
                            if (user != null && user.email != null) {
                              // Reauthenticate user first
                              AuthCredential credential = EmailAuthProvider.credential(
                                email: user.email!,
                                password: currentPasswordController.text,
                              );

                              await user.reauthenticateWithCredential(credential);
                              await user.updatePassword(newPasswordController.text);

                              _showMessage('Password updated successfully');

                              // Clear password fields
                              currentPasswordController.clear();
                              newPasswordController.clear();
                              confirmPasswordController.clear();
                            }
                          } catch (e) {
                            _showMessage('Error updating password: $e');
                          } finally {
                            setState(() {
                              _isUpdatingPassword = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: isDarkMode 
                              ? Colors.blue[900]!.withOpacity(0.6) 
                              : Colors.blue.withOpacity(0.6),
                        ),
                        child: _isUpdatingPassword
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text("Update Password",
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isDarkMode,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.grey[100],
        hintText: label,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : null,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(
        fontSize: 16, 
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
