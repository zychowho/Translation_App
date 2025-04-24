import 'package:flutter/material.dart';
import 'package:translation_app/pages/homepage.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart'; // <-- TTS Import
import 'package:translation_app/services/translation_history_service.dart';
import 'package:translation_app/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/utils/theme_provider.dart';

class NormalPage extends StatefulWidget {
  @override
  _NormalPageState createState() => _NormalPageState();
}

class _NormalPageState extends State<NormalPage> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _selectedLanguage = 'tl'; // Default to Filipino
  String _sourceLanguage = 'auto'; // Default to auto-detect
  String _detectedLanguage = '';
  bool _isDetecting = false;
  final translator = GoogleTranslator();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _flutterTts = FlutterTts(); // <-- TTS instance
  String _selectedVoice = 'Default'; // Default voice
  bool _isSpeaking = false;
  final TranslationHistoryService _historyService = TranslationHistoryService();
  final FirestoreService _firestoreService = FirestoreService();

  // Voice options with pitch and rate settings
  final Map<String, Map<String, double>> _voiceOptions = {
    'Default': {'pitch': 1.0, 'rate': 0.5},
    'Male': {
      'pitch': 0.1,
      'rate': 0.4
    }, // Absolute minimum pitch for deepest possible voice
    'Girl': {
      'pitch': 1.6,
      'rate': 0.55
    }, // Higher pitch with slightly faster rate for girly voice
    'Kid': {
      'pitch': 2.0,
      'rate': 0.75
    }, // Maximum pitch with faster rate for child-like voice
    'Robot': {'pitch': 0.8, 'rate': 0.3},
  };

  final Map<String, String> languages = {
    'Auto-detect': 'auto',
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
    _speech = stt.SpeechToText();
    _initTts();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Only attempt detection when there's sufficient text (at least 10 characters)
    if (_textController.text.length > 10 && _sourceLanguage == 'auto') {
      _detectLanguage(_textController.text);
    }
  }

  Future<void> _detectLanguage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isDetecting = true;
      _detectedLanguage = '';
    });

    try {
      // Using translation to English as a way to get the detected language
      // The translator automatically detects when 'auto' is passed as source
      var translation = await translator.translate(
          text.substring(
              0,
              text.length > 50
                  ? 50
                  : text
                      .length), // Use only first 50 chars for faster detection
          from: 'auto',
          to: 'en');

      setState(() {
        _detectedLanguage = translation.sourceLanguage.code;
        _isDetecting = false;
      });
    } catch (e) {
      print('Error detecting language: $e');
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(_voiceOptions[_selectedVoice]!['pitch']!);
    await _flutterTts.setSpeechRate(_voiceOptions[_selectedVoice]!['rate']!);
  }

  // Get language name from code
  String _getLanguageName(String languageCode) {
    if (languageCode.isEmpty) return 'Unknown';
    String name = 'Unknown';
    languages.forEach((key, value) {
      if (value == languageCode) {
        name = key;
      }
    });
    return name;
  }

  void _translateText() async {
    if (_textController.text.isNotEmpty) {
      String sourceLanguage = _sourceLanguage;

      if (sourceLanguage == 'auto' && _detectedLanguage.isNotEmpty) {
        sourceLanguage = _detectedLanguage;
      } else if (sourceLanguage == 'auto') {
        // If auto is selected but no language detected yet, try to detect now
        await _detectLanguage(_textController.text);
        sourceLanguage =
            _detectedLanguage.isNotEmpty ? _detectedLanguage : 'en';
      }

      var translation = await translator.translate(
        _textController.text,
        from: sourceLanguage,
        to: _selectedLanguage,
      );

      setState(() {
        _translatedText = translation.text;
      });

      // Save to Firestore with type
      await _firestoreService.addTranslation(
        originalText: _textController.text,
        translatedText: _translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: _selectedLanguage,
        translationType: 'text',
      );
    }
  }

  Future<void> _speak() async {
    if (_translatedText.isEmpty) return;

    try {
      setState(() {
        _isSpeaking = true;
      });

      await _flutterTts.setLanguage(_selectedLanguage);
      await _flutterTts.setPitch(_voiceOptions[_selectedVoice]!['pitch']!);
      await _flutterTts.setSpeechRate(_voiceOptions[_selectedVoice]!['rate']!);
      await _flutterTts.speak(_translatedText);

      _flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
      });
    } catch (e) {
      print("TTS Error: $e");
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _stopSpeaking() {
    _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
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
          title: Text(
            "Text Translation",
            style: TextStyle(
              color: isDarkMode ? Colors.blue[400] : Colors.blue[700],
            ),
          ),
          backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.blue[400] : Colors.blue[700],
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Language selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Source language selector
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _sourceLanguage,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                  ),
                                  items: languages.entries.map((entry) {
                                    return DropdownMenuItem<String>(
                                      value: entry.value,
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _sourceLanguage = newValue!;
                                    });
                                  },
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                  dropdownColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.arrow_forward, 
                              color: isDarkMode ? Colors.blue[400] : Colors.blue, 
                              size: 20
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLanguage,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                  ),
                                  items: languages.entries
                                      .where((entry) => entry.value != 'auto')
                                      .map((entry) {
                                    return DropdownMenuItem<String>(
                                      value: entry.value,
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedLanguage = newValue!;
                                    });
                                  },
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                  dropdownColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Input section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black26 : Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Text input field
                      Container(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          controller: _textController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Enter text to translate',
                            hintStyle: TextStyle(
                              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      // ... rest of the input section ...
                    ],
                  ),
                ),
              ),
              
              // Voice selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVoice,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode ? Colors.grey[400] : Colors.blue[700],
                      ),
                      items: _voiceOptions.keys.map((voice) {
                        return DropdownMenuItem<String>(
                          value: voice,
                          child: Text(
                            voice,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVoice = value!;
                        });
                      },
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      dropdownColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Translate and Speak buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Translate button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _translateText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.blue[700] : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Translate",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Speak button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _translatedText.isEmpty 
                            ? null 
                            : (_isSpeaking ? _stopSpeaking : _speak),
                        icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up, size: 20),
                        label: Text(_isSpeaking ? "Stop" : "Speak"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode 
                              ? (_isSpeaking ? Colors.red[700] : Colors.green[700])
                              : (_isSpeaking ? Colors.red : Colors.green),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDarkMode 
                              ? Colors.grey[800] 
                              : Colors.grey[300],
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Output section
              if (_translatedText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black26 : Colors.black12, 
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Translation',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _translatedText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        // ... rest of the output section ...
                      ],
                    ),
                  ),
                ),
              // ... other widgets ...
            ],
          ),
        ),
      ),
    );
  }
}
