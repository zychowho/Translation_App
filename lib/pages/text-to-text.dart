import 'package:flutter/material.dart';
import 'package:translation_app/pages/homepage.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart'; // <-- TTS Import

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

  Future<void> _pickImageAndExtractText() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

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
        _textController.text = extractedText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          title: Text(
            "SpeakWise",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.text_fields, size: 60, color: Colors.red),
              SizedBox(height: 15),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter text to translate",
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sourceLanguage,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: _isDetecting
                            ? "Detecting..."
                            : (_sourceLanguage == 'auto' &&
                                    _detectedLanguage.isNotEmpty)
                                ? "Detected: ${_getLanguageName(_detectedLanguage)}"
                                : "From",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        isDense: true,
                      ),
                      isExpanded: true,
                      items: languages.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(
                            entry.key,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _sourceLanguage = value!;
                          // Clear detected language if manual language selected
                          if (_sourceLanguage != 'auto') {
                            _detectedLanguage = '';
                          } else if (_textController.text.length > 10) {
                            // Try to detect if switching to auto and have text
                            _detectLanguage(_textController.text);
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child:
                        Icon(Icons.arrow_forward, color: Colors.blue, size: 20),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "To",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        isDense: true,
                      ),
                      isExpanded: true,
                      items: languages.entries
                          .where((entry) =>
                              entry.value !=
                              'auto') // Remove auto-detect from target languages
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
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedVoice,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Voice Type",
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  isDense: true,
                ),
                isExpanded: true,
                items: _voiceOptions.keys.map((voice) {
                  return DropdownMenuItem<String>(
                    value: voice,
                    child: Text(voice),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVoice = value!;
                  });
                },
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _translateText,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Translate",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSpeaking ? _stopSpeaking : _speak,
                      icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up,
                          size: 18),
                      label: Text(_isSpeaking ? "Stop" : "Speak",
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSpeaking ? Colors.red : Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(15),
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _translatedText.isEmpty
                        ? "Translation will appear here"
                        : _translatedText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
