import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'home_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String selectedLanguage = "English";
  String selectedLanguageCode = "en";
  List<Map<String, String>> languages = [];
  List<Map<String, String>> filteredLanguages = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLanguages();
    searchController.addListener(_filterLanguages);
  }

  Future<void> fetchLanguages() async {
    final supportedLanguages = {
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

    setState(() {
      languages = supportedLanguages.entries
          .map((entry) => {"name": entry.key, "code": entry.value})
          .toList();
      filteredLanguages = languages;
    });
  }

  void _filterLanguages() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredLanguages = languages
          .where((language) => language["name"]!.toLowerCase().contains(query))
          .toList();
    });
  }

  Widget _buildLanguageTile(String language, String code) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language;
          selectedLanguageCode = code;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selectedLanguage == language ? Colors.blue[200] : Colors.transparent,
          border: Border.all(color: Colors.blue.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            Text(
              language,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Choose Your Language:",
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search your language",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.yellow),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredLanguages.isEmpty
                  ? Center(child: Text("No languages found"))
                  : ListView.builder(
                itemCount: filteredLanguages.length,
                itemBuilder: (context, index) {
                  return _buildLanguageTile(
                      filteredLanguages[index]["name"]!,
                      filteredLanguages[index]["code"]!
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(languageCode: selectedLanguageCode)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Select",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}