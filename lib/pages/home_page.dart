import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class HomePage extends StatefulWidget {
  final String languageCode;

  const HomePage({super.key, required this.languageCode});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedPlan;
  final translator = GoogleTranslator();
  String translatedTagline = "";
  String translatedSilver = "SILVER";
  String translatedGold = "GOLD";
  String translatedSilverDescription = "";
  String translatedGoldDescription = "";
  String translatedSubscribe = "Subscribe";
  String translatedSkipSubscription = "Skip Subscription";

  @override
  void initState() {
    super.initState();
    translateContent();
  }

  Future<void> translateContent() async {
    final translations = await Future.wait([
      translator.translate("Make your translations more convenient for a reasonable price!", from: 'en', to: widget.languageCode),
      translator.translate("SILVER", from: 'en', to: widget.languageCode),
      translator.translate("GOLD", from: 'en', to: widget.languageCode),
      translator.translate("You can use the regular text-to-text translation and picture-to-text translation feature!", from: 'en', to: widget.languageCode),
      translator.translate("You're free to use text-to-text, picture-to-text, and also voice recognition translation!", from: 'en', to: widget.languageCode),
      translator.translate("Subscribe", from: 'en', to: widget.languageCode),
      translator.translate("Skip Subscription", from: 'en', to: widget.languageCode),
    ]);

    setState(() {
      translatedTagline = translations[0].text;
      translatedSilver = translations[1].text;
      translatedGold = translations[2].text;
      translatedSilverDescription = translations[3].text;
      translatedGoldDescription = translations[4].text;
      translatedSubscribe = translations[5].text;
      translatedSkipSubscription = translations[6].text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "SpeakWise",
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.language, size: 50, color: Colors.black),
            SizedBox(height: 10),
            Text(
              translatedTagline.isEmpty ? "Translating..." : translatedTagline,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildSubscriptionCard(
                    title: translatedSilver,
                    description: translatedSilverDescription.isEmpty ? "Translating..." : translatedSilverDescription,
                    color: Colors.grey.shade300,
                  ),
                  _buildSubscriptionCard(
                    title: translatedGold,
                    description: translatedGoldDescription.isEmpty ? "Translating..." : translatedGoldDescription,
                    color: Colors.amber.shade600,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedPlan == null
                  ? null
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subscribed to $selectedPlan Plan!")),
                );
                Navigator.pushReplacementNamed(context, '/main_app');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPlan == null ? Colors.grey : Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                translatedSubscribe,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/onboarding_page');
              },
              child: Text(
                translatedSkipSubscription,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String description,
    required Color color,
  }) {
    bool isSelected = selectedPlan == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = title;
        });
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: isSelected ? color.withOpacity(0.6) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}