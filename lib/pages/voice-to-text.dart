import 'package:flutter/material.dart';
import 'package:translation_app/pages/homepage.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translation_app/services/translation_history_service.dart';
import 'package:translation_app/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:translation_app/utils/theme_provider.dart';

class VoiceToTextPage extends StatefulWidget {
  @override
  _VoiceToTextPageState createState() => _VoiceToTextPageState();
}

class _VoiceToTextPageState extends State<VoiceToTextPage> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _selectedLanguage = 'tl'; // Default to Filipino
  final translator = GoogleTranslator();
  late stt.SpeechToText _speech; // Speech-to-Text instance
  bool _isListening = false; // To track if speech recognition is active
  final ImagePicker _picker =
      ImagePicker(); // For picking images from gallery or camera
  FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _selectedVoice = 'Default'; // Default voice
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
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(_voiceOptions[_selectedVoice]!['pitch']!);
    await _flutterTts.setSpeechRate(_voiceOptions[_selectedVoice]!['rate']!);
  }

  void _translateText() async {
    if (_textController.text.isNotEmpty) {
      var translation = await translator.translate(_textController.text,
          to: _selectedLanguage);
      setState(() {
        _translatedText = translation.text;
      });

      // Save to Firestore with type
      await _firestoreService.addTranslation(
        originalText: _textController.text,
        translatedText: _translatedText,
        sourceLanguage: 'en', // Assuming speech is in English
        targetLanguage: _selectedLanguage,
        translationType: 'voice',
      );
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
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

  // OCR function to extract text from image
  Future<void> _pickImageAndExtractText() async {
    final XFile? pickedFile = await _picker.pickImage(
        source:
            ImageSource.gallery); // You can use ImageSource.camera for camera

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);

      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += line.text + '\n';
        }
      }

      setState(() {
        _textController.text = extractedText; // Display extracted text
      });
    }
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
          MaterialPageRoute(builder: (context) => HomePage()), // Go to HomePage
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.blue[400] : Colors.blue[700]),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()), // Go back to homepage
              );
            },
          ),
          title: Text(
            "Voice Translation",
            style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.blue[400] : Colors.blue[700]),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Voice recording section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black26 : Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic,
                        size: 60,
                        color: isDarkMode ? Colors.orange[300] : Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Speak to translate",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap the microphone button and start speaking",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: _isListening ? _stopListening : _startListening,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isListening
                                ? Colors.red.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              size: 40,
                              color: _isListening ? Colors.red : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _isListening ? "Listening..." : "Tap to start speaking",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isListening ? Colors.red : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Language selector
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                      hint: Text(
                        "Target Language",
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
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
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      dropdownColor: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Voice selection dropdown
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                      hint: Text(
                        "Voice Type",
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
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
                
                SizedBox(height: 24),
                
                // Recognized speech container
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recognized Speech",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 120,
                        child: SingleChildScrollView(
                          child: Text(
                            _textController.text.isEmpty
                                ? "Recognized speech will appear here"
                                : _textController.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Buttons row
                Row(
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
                    // Speak button for recognized speech
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _translatedText.isEmpty 
                            ? null 
                            : () async {
                                if (_isSpeaking) {
                                  _stopSpeaking();
                                  return;
                                }
                                
                                try {
                                  setState(() {
                                    _isSpeaking = true;
                                  });
                                  
                                  // Use the selected language and voice settings for the translated text
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
                              },
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
                
                SizedBox(height: 24),
                
                // Translation result
                if (_translatedText.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Translation",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
