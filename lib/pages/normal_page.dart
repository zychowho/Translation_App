import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class NormalPage extends StatefulWidget {
  final String languageCode;

  NormalPage({required this.languageCode});

  @override
  _NormalPageState createState() => _NormalPageState();
}

class _NormalPageState extends State<NormalPage> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _selectedLanguage = '';
  String _translatedButtonText = "";
  String _translatedHintText = "";
  String _translatedPlaceholder = "";
  String _translatedSelectLanguage = "";
  final translator = GoogleTranslator();

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

  Future<void> _translateAll() async {
    try {
      var translations = await Future.wait([
        translator.translate("Translate", to: widget.languageCode),
        translator.translate("Enter text to translate", to: widget.languageCode),
        translator.translate("Translation will appear here", to: widget.languageCode),
        translator.translate("Select Language", to: widget.languageCode),
      ]);

      setState(() {
        _translatedButtonText = translations[0].text;
        _translatedHintText = translations[1].text;
        _translatedPlaceholder = translations[2].text;
        _translatedSelectLanguage = translations[3].text;
      });
    } catch (e) {
      print("Translation Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation error. Please check your connection.')),
      );
    }
  }

  Future<void> _translateText() async {
    if (_textController.text.isNotEmpty) {
      try {
        var translation = await translator.translate(_textController.text, to: widget.languageCode);
        setState(() {
          _translatedText = translation.text;
        });
      } catch (e) {
        print("Translation Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation error. Please check your connection.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.languageCode;
    _translateAll(); // Translate initial static text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "SpeakWise",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.blue),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.language, size: 80, color: Colors.black),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: _translatedHintText.isEmpty ? "Enter text to translate" : _translatedHintText,
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: _translatedSelectLanguage.isEmpty ? "Select Language" : _translatedSelectLanguage,
              ),
              items: languages.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                  _translateAll();
                  _translateText();
                });
              },
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Text(
                _translatedText.isEmpty ? _translatedPlaceholder : _translatedText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _translateText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _translatedButtonText.isEmpty ? "Translate" : _translatedButtonText,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}