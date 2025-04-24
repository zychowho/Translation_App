import 'package:flutter/material.dart';
import 'package:translation_app/pages/homepage.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/utils/theme_provider.dart';

class NormalPage extends StatefulWidget {
  @override
  _NormalPageState createState() => _NormalPageState();
}

class _NormalPageState extends State<NormalPage> {
  String _sourceLanguage = 'en'; // Default source language is English
  String _selectedLanguage = 'tl'; // Default to Filipino
  final translator = GoogleTranslator();
  bool _loadingPhrases = false;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _currentlySpeakingPhrase = '';
  String _currentlySpeakingCategory = '';

  // Create a key for caching translations
  String get _cacheKey => 'phrases_${_sourceLanguage}_${_selectedLanguage}_v2';

  // Timestamp for cache expiration (24 hours)
  final int _cacheExpirationHours = 24;

  // Simplified phrase list for testing
  final Map<String, List<String>> _phraseCategories = {
    'Greetings': [
      'Hello',
      'Good morning',
      'How are you?',
      'Goodbye',
      'Welcome',
    ],
    'Basic Phrases': [
      'Thank you',
      'Please',
      'I\'m sorry',
      'Yes',
      'No',
    ],
    'Shopping': [
      'How much is this?',
      'Do you have this in another size?',
      'Do you accept credit cards?',
      'I\'m just looking',
      'Can I try this on?',
    ],
    'Emergency': [
      'I need a doctor',
      'Help!',
      'I need help',
      'Where is the hospital?',
      'Call an ambulance',
    ],
  };

  // Store the original English phrases
  Map<String, List<String>> _originalEnglishPhrases = {};

  // Map to store translated phrases
  Map<String, Map<String, String>> _translatedCategoryPhrases = {};

  // Simplified language list for testing
  final Map<String, String> languages = {
    'Afrikaans': 'af',
    'Albanian': 'sq',
    'Amharic': 'am',
    'Arabic': 'ar',
    'Armenian': 'hy',
    'Basque': 'eu',
    'Bengali': 'bn',
    'Bulgarian': 'bg',
    'Catalan': 'ca',
    'Chichewa': 'ny',
    'Chinese (Simplified)': 'zh-cn',
    'Chinese (Traditional)': 'zh-tw',
    'Croatian': 'hr',
    'Czech': 'cs',
    'Danish': 'da',
    'Dutch': 'nl',
    'English': 'en',
    'Estonian': 'et',
    'Filipino': 'tl',
    'Finnish': 'fi',
    'French': 'fr',
    'German': 'de',
    'Greek': 'el',
    'Gujarati': 'gu',
    'Hausa': 'ha',
    'Hebrew': 'iw',
    'Hindi': 'hi',
    'Hungarian': 'hu',
    'Icelandic': 'is',
    'Igbo': 'ig',
    'Indonesian': 'id',
    'Italian': 'it',
    'Japanese': 'ja',
    'Kannada': 'kn',
    'Khmer': 'km',
    'Korean': 'ko',
    'Latin': 'la',
    'Latvian': 'lv',
    'Lithuanian': 'lt',
    'Malay': 'ms',
    'Malayalam': 'ml',
    'Marathi': 'mr',
    'Myanmar (Burmese)': 'my',
    'Nepali': 'ne',
    'Norwegian': 'no',
    'Polish': 'pl',
    'Portuguese': 'pt',
    'Romanian': 'ro',
    'Russian': 'ru',
    'Serbian': 'sr',
    'Sinhala': 'si',
    'Slovak': 'sk',
    'Slovenian': 'sl',
    'Spanish': 'es',
    'Swahili': 'sw',
    'Swedish': 'sv',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Thai': 'th',
    'Turkish': 'tr',
    'Ukrainian': 'uk',
    'Urdu': 'ur',
    'Vietnamese': 'vi',
    'Welsh': 'cy',
    'Yoruba': 'yo',
    'Zulu': 'zu'
  };

  @override
  void initState() {
    super.initState();
    _initTts();
    // Create a copy of the original English phrases
    _storeOriginalEnglish();
    _loadAndTranslatePhrases();
  }

  // Store the original English phrases for reference
  void _storeOriginalEnglish() {
    for (String category in _phraseCategories.keys) {
      _originalEnglishPhrases[category] =
          List.from(_phraseCategories[category]!);
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);

    // Set voice parameters for better speech quality
    await _flutterTts
        .setSpeechRate(0.5); // Slower speech rate for better clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Enable this for debugging TTS issues
    _flutterTts.setErrorHandler((error) {
      print("TTS Error: $error");
    });
  }

  // Get language name from code
  String _getLanguageName(String languageCode) {
    String name = 'Unknown';
    languages.forEach((key, value) {
      if (value == languageCode) {
        name = key;
      }
    });
    return name;
  }

  // Check if cached translations exist and are valid
  Future<Map<String, Map<String, String>>?> _getCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey);

      if (cacheData != null) {
        final cache = jsonDecode(cacheData) as Map<String, dynamic>;
        final timestamp = cache['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Check if cache is still valid (not older than 24 hours)
        if (now - timestamp < _cacheExpirationHours * 60 * 60 * 1000) {
          final translations = cache['translations'] as Map<String, dynamic>;

          // Convert from dynamic to the correct type
          Map<String, Map<String, String>> result = {};
          translations.forEach((category, phrases) {
            result[category] = Map<String, String>.from(phrases as Map);
          });

          return result;
        }
      }
    } catch (e) {
      print('Error reading cache: $e');
    }

    return null;
  }

  // Save translations to cache
  Future<void> _cacheTranslations(
      Map<String, Map<String, String>> translations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'translations': translations,
      };

      await prefs.setString(_cacheKey, jsonEncode(cacheData));
    } catch (e) {
      print('Error caching translations: $e');
    }
  }

  // Load phrases from cache or translate them
  Future<void> _loadAndTranslatePhrases() async {
    setState(() {
      _loadingPhrases = true;
    });

    // If source language is not English, update phrase categories for display
    if (_sourceLanguage != 'en') {
      await _updatePhrasesForSourceLanguage();
    } else {
      // Reset to original English phrases
      for (String category in _originalEnglishPhrases.keys) {
        _phraseCategories[category] =
            List.from(_originalEnglishPhrases[category]!);
      }
    }

    // First try to get cached translations
    final cachedTranslations = await _getCachedTranslations();

    if (cachedTranslations != null) {
      print(
          "Using cached translations for $_sourceLanguage to $_selectedLanguage");
      setState(() {
        _translatedCategoryPhrases = cachedTranslations;
        _loadingPhrases = false;
      });
      return;
    }

    print(
        "No cache found, translating phrases from $_sourceLanguage to $_selectedLanguage");

    // If no cache, translate all phrases
    await _translateAllPhrases();

    setState(() {
      _loadingPhrases = false;
    });
  }

  // Translate all phrases in categories
  Future<void> _translateAllPhrases() async {
    Map<String, Map<String, String>> translatedCategories = {};

    // When source is not English, we need a special approach
    if (_sourceLanguage != 'en') {
      await _translateViaEnglish(translatedCategories);
    } else {
      // Direct translation from English to target language
      await _translateFromEnglish(translatedCategories);
    }

    // Save to cache
    await _cacheTranslations(translatedCategories);

    setState(() {
      _translatedCategoryPhrases = translatedCategories;
    });
  }

  // Translate from English to target language
  Future<void> _translateFromEnglish(
      Map<String, Map<String, String>> translatedCategories) async {
    print("Translating from English to $_selectedLanguage");

    for (String category in _phraseCategories.keys) {
      translatedCategories[category] = {};

      for (String phrase in _phraseCategories[category]!) {
        try {
          print("Translating: '$phrase'");
          var translation = await translator.translate(
            phrase,
            from: 'en',
            to: _selectedLanguage,
          );
          print("Result: '${translation.text}'");
          translatedCategories[category]![phrase] = translation.text;
        } catch (e) {
          print("Error translating '$phrase': $e");
          translatedCategories[category]![phrase] = "$phrase (error)";
        }

        // Update UI periodically
        setState(() {
          _translatedCategoryPhrases = Map.from(translatedCategories);
        });
      }
    }
  }

  // Translate when source is not English (via English as intermediate)
  Future<void> _translateViaEnglish(
      Map<String, Map<String, String>> translatedCategories) async {
    print(
        "Translating from $_sourceLanguage to $_selectedLanguage via English");

    for (String category in _originalEnglishPhrases.keys) {
      translatedCategories[category] = {};
      final displayedPhrases = _phraseCategories[category]!;
      final englishPhrases = _originalEnglishPhrases[category]!;

      // Make sure we have the same number of phrases in both lists
      int minLength = displayedPhrases.length < englishPhrases.length
          ? displayedPhrases.length
          : englishPhrases.length;

      for (int i = 0; i < minLength; i++) {
        String displayedPhrase = displayedPhrases[i];
        String englishPhrase = englishPhrases[i];

        try {
          print(
              "Original English: '$englishPhrase', Now translating to $_selectedLanguage");

          // Translate directly from English to target language
          var translation = await translator.translate(
            englishPhrase, // Use English phrase
            from: 'en', // From English
            to: _selectedLanguage, // To target language
          );

          print("Result: '${translation.text}'");
          translatedCategories[category]![displayedPhrase] = translation.text;
        } catch (e) {
          print("Error translating: $e");
          translatedCategories[category]![displayedPhrase] =
              "$displayedPhrase (error)";
        }

        // Update UI periodically
        setState(() {
          _translatedCategoryPhrases = Map.from(translatedCategories);
        });
      }
    }
  }

  Future<void> _speakPhrase(String phrase, String category, String originalPhrase) async {
    if (_isSpeaking) {
      await _stopSpeaking();
      
      // If the same phrase was clicked again, just stop speaking
      if (phrase == _currentlySpeakingPhrase && category == _currentlySpeakingCategory) {
        return;
      }
    }

    try {
      setState(() {
        _isSpeaking = true;
        _currentlySpeakingPhrase = phrase;
        _currentlySpeakingCategory = category;
      });

      // Map language codes to TTS-compatible language codes
      Map<String, String> ttsLanguageCodes = {
        'en': 'en-US',
        'tl': 'fil-PH',
        'es': 'es-ES',
        'fr': 'fr-FR',
        'de': 'de-DE',
        'ja': 'ja-JP',
        'ko': 'ko-KR',
        'zh-cn': 'zh-CN',
        'zh-tw': 'zh-TW',
        'ar': 'ar-SA',
        'ru': 'ru-RU',
        'it': 'it-IT',
        'pt': 'pt-PT',
        'hi': 'hi-IN',
        'af': 'af-ZA',
        'sq': 'sq-AL',
        'am': 'am-ET',
        'hy': 'hy-AM',
        'bn': 'bn-IN',
        'bg': 'bg-BG',
        'ca': 'ca-ES',
        'hr': 'hr-HR',
        'cs': 'cs-CZ',
        'da': 'da-DK',
        'nl': 'nl-NL',
        'et': 'et-EE',
        'fi': 'fi-FI',
        'el': 'el-GR',
        'gu': 'gu-IN',
        'iw': 'he-IL', // Hebrew
        'hu': 'hu-HU',
        'is': 'is-IS',
        'id': 'id-ID',
        'kn': 'kn-IN',
        'km': 'km-KH',
        'lv': 'lv-LV',
        'lt': 'lt-LT',
        'ms': 'ms-MY',
        'ml': 'ml-IN',
        'mr': 'mr-IN',
        'my': 'my-MM',
        'ne': 'ne-NP',
        'no': 'nb-NO',
        'pl': 'pl-PL',
        'ro': 'ro-RO',
        'sr': 'sr-RS',
        'si': 'si-LK',
        'sk': 'sk-SK',
        'sl': 'sl-SI',
        'sw': 'sw-KE',
        'sv': 'sv-SE',
        'ta': 'ta-IN',
        'te': 'te-IN',
        'th': 'th-TH',
        'tr': 'tr-TR',
        'uk': 'uk-UA',
        'ur': 'ur-PK',
        'vi': 'vi-VN',
        'cy': 'cy-GB',
      };

      // Get the proper TTS language code
      String ttsLanguage =
          ttsLanguageCodes[_selectedLanguage] ?? _selectedLanguage;

      print("Speaking in language: $ttsLanguage");
      print("Phrase to speak: $phrase");

      // Check available languages if needed
      List<dynamic>? availableLanguages = await _flutterTts.getLanguages;
      bool isLanguageAvailable = availableLanguages != null && 
          (availableLanguages.contains(ttsLanguage) || 
           availableLanguages.any((lang) => lang.toString().startsWith(ttsLanguage.split('-')[0])));
      
      if (!isLanguageAvailable) {
        print("Language $ttsLanguage not directly available, trying language code only");
        // Try with just the language code without region
        String languageCode = ttsLanguage.split('-')[0];
        ttsLanguage = languageCode;
      }

      // Set the language first
      await _flutterTts.setLanguage(ttsLanguage);

      // For Chinese, Japanese, Korean and Arabic, adjust speech rate
      if (['zh-CN', 'zh-TW', 'ja-JP', 'ko-KR', 'ar-SA', 'th-TH', 'he-IL', 'hi-IN', 
           'bn-IN', 'gu-IN', 'kn-IN', 'ml-IN', 'mr-IN', 'ta-IN', 'te-IN', 'ur-PK', 
           'my-MM', 'km-KH', 'si-LK'].contains(ttsLanguage)) {
        await _flutterTts.setSpeechRate(0.4); // Slower for complex scripts
      } else {
        await _flutterTts.setSpeechRate(0.5); // Default rate
      }

      // Speak the phrase
      var result = await _flutterTts.speak(phrase);
      if (result != 1) {
        throw Exception("TTS failed to start speaking");
      }

      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingPhrase = '';
          _currentlySpeakingCategory = '';
        });
      });
    } catch (e) {
      print("TTS Error: $e");
      setState(() {
        _isSpeaking = false;
        _currentlySpeakingPhrase = '';
        _currentlySpeakingCategory = '';
      });

      // Show a snackbar to inform the user about the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot speak this language on this device"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _currentlySpeakingPhrase = '';
      _currentlySpeakingCategory = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme context
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.blue[400] : Colors.blue),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          title: Text(
            "Common Phrases",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[400] : Colors.blue,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: isDarkMode ? Color(0xFF1E1E1E) : Colors.blue[50],
              child: Column(
                children: [
                  Text(
                    "Select Languages",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          isDense: true,
                          value: _sourceLanguage,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "From",
                            labelStyle: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : null,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          dropdownColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                          items: languages.entries
                              .where(
                                  (entry) => entry.value != _selectedLanguage)
                              .map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.value,
                              child: Text(
                                entry.key,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != _sourceLanguage) {
                              setState(() {
                                print(
                                    "Source language changed from $_sourceLanguage to $value");
                                _sourceLanguage = value!;
                                // If new source language is the same as target language,
                                // change target language to prevent overlap
                                if (_sourceLanguage == _selectedLanguage) {
                                  // Find an alternative language (default to English if not already selected)
                                  String newTarget =
                                      _sourceLanguage == 'en' ? 'tl' : 'en';
                                  _selectedLanguage = newTarget;
                                }
                                _translatedCategoryPhrases.clear();
                              });
                              _loadAndTranslatePhrases();
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward, color: isDarkMode ? Colors.blue[400] : Colors.blue),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          isDense: true,
                          value: _selectedLanguage,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "To",
                            labelStyle: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : null,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          dropdownColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                          items: languages.entries
                              .where((entry) => entry.value != _sourceLanguage)
                              .map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.value,
                              child: Text(
                                entry.key,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != _selectedLanguage) {
                              setState(() {
                                print(
                                    "Target language changed from $_selectedLanguage to $value");
                                _selectedLanguage = value!;
                                // If new target language is the same as source language,
                                // change source language to prevent overlap
                                if (_selectedLanguage == _sourceLanguage) {
                                  // Find an alternative language (default to English if not already selected)
                                  String newSource =
                                      _selectedLanguage == 'en' ? 'tl' : 'en';
                                  _sourceLanguage = newSource;
                                }
                                _translatedCategoryPhrases.clear();
                              });
                              _loadAndTranslatePhrases();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loadingPhrases
                  ? Center(child: _buildProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.all(16),
                      children: _phraseCategories.keys.map((category) {
                        return _buildPhraseCategory(category);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    // Get theme context
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    int totalPhrases = 0;
    int translatedPhrases = 0;

    // Count total phrases
    _phraseCategories.forEach((category, phrases) {
      totalPhrases += phrases.length;
    });

    // Count translated phrases
    _translatedCategoryPhrases.forEach((category, phrases) {
      translatedPhrases += phrases.length;
    });

    // Calculate progress
    double progress = totalPhrases > 0 ? translatedPhrases / totalPhrases : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(value: progress),
        SizedBox(height: 20),
        Text(
          "Translating phrases... (${(progress * 100).toInt()}%)",
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          "$translatedPhrases of $totalPhrases phrases",
          style: TextStyle(
            fontSize: 14, 
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          "From: ${_getLanguageName(_sourceLanguage)} To: ${_getLanguageName(_selectedLanguage)}",
          style: TextStyle(
            fontSize: 14, 
            color: isDarkMode ? Colors.blue[400] : Colors.blue[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPhraseCategory(String category) {
    // Get theme context
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    final phrases = _phraseCategories[category]!;
    final translatedPhrases = _translatedCategoryPhrases[category] ?? {};

    return ExpansionTile(
      key: ValueKey(category),
      title: Text(
        category,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      iconColor: isDarkMode ? Colors.blue[400] : Colors.blue[700],
      collapsedIconColor: isDarkMode ? Colors.grey[400] : Colors.grey[700],
      children: phrases.map((phrase) {
        final translatedPhrase = translatedPhrases[phrase] ?? '...';
        // Check if this phrase is the one being spoken
        final bool isThisPhraseSpeaking = _isSpeaking && 
                                         _currentlySpeakingPhrase == translatedPhrase && 
                                         _currentlySpeakingCategory == category;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phrase,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.blue[400] : Colors.blue[800],
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        translatedPhrase,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _speakPhrase(translatedPhrase, category, phrase),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isThisPhraseSpeaking
                              ? (isDarkMode ? Colors.grey[800] : Colors.grey[300])
                              : (isDarkMode ? Colors.blue[900]!.withOpacity(0.3) : Colors.blue[50]),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isThisPhraseSpeaking
                              ? Icons.stop
                              : Icons.volume_up,
                          size: 20,
                          color: isThisPhraseSpeaking
                              ? (isDarkMode ? Colors.grey[400] : Colors.grey[700])
                              : (isDarkMode ? Colors.blue[400] : Colors.blue[800]),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Update phrases display for non-English source languages
  Future<void> _updatePhrasesForSourceLanguage() async {
    // Only do this when switching to a non-English source language
    if (_sourceLanguage == 'en') return;

    // Temporarily translate English phrases to source language for display
    for (String category in _originalEnglishPhrases.keys) {
      final List<String> englishPhrases = _originalEnglishPhrases[category]!;
      List<String> translatedPhrases = [];

      for (String phrase in englishPhrases) {
        try {
          var translation = await translator.translate(
            phrase,
            from: 'en',
            to: _sourceLanguage,
          );
          translatedPhrases.add(translation.text);
        } catch (e) {
          print("Error translating to source language: $e");
          translatedPhrases.add(phrase); // Keep original on error
        }
      }

      setState(() {
        _phraseCategories[category] = translatedPhrases;
      });
    }
  }
}
