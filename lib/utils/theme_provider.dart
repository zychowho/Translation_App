import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Key for storing theme preference
  static const THEME_KEY = 'theme_mode';
  
  // Default to light theme
  ThemeMode _themeMode = ThemeMode.light;
  
  // Public getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Constructor - loads saved theme on initialization
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  // Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Method to toggle between light and dark theme
  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveThemeToPrefs();
    notifyListeners();
  }
  
  // Method to set a specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(THEME_KEY) ?? 1; // Default to light theme (1)
      _themeMode = ThemeMode.values[themeModeIndex];
      notifyListeners();
    } catch (e) {
      print('Error loading theme mode: $e');
    }
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(THEME_KEY, _themeMode.index);
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }
  
  // Light theme data
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue[700],
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
        primary: Colors.blue[700]!,
        secondary: Colors.blue[500]!,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[700]),
        titleTextStyle: TextStyle(
          color: Colors.blue[700],
          fontFamily: 'BerlinSansFBDemi',
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.black12,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[400],
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[700],
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        titleMedium: TextStyle(color: Colors.black87),
        labelLarge: TextStyle(color: Colors.black87),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue[700],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
      ),
      useMaterial3: true,
    );
  }
  
  // Dark theme data
  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue[400],
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        primary: Colors.blue[400]!,
        secondary: Colors.blue[300]!,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
        error: Colors.red[400]!,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[400]),
        titleTextStyle: TextStyle(
          color: Colors.blue[400],
          fontFamily: 'BerlinSansFBDemi',
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      cardTheme: CardTheme(
        color: Color(0xFF1E1E1E),
        shadowColor: Colors.black26,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Colors.blue[400],
        unselectedItemColor: Colors.grey[600],
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.blue[400],
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: Colors.blue[400],
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Color(0xFF1E1E1E),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[800],
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        labelLarge: TextStyle(color: Colors.white),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue[400],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[400]!),
        ),
        hintStyle: TextStyle(color: Colors.grey[600]),
        labelStyle: TextStyle(color: Colors.grey[400]),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue[400];
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue[400]!.withOpacity(0.5);
          }
          return null;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFF2C2C2C),
        selectedColor: Colors.blue[700],
        labelStyle: TextStyle(color: Colors.white),
        secondaryLabelStyle: TextStyle(color: Colors.white),
      ),
      useMaterial3: true,
    );
  }
} 