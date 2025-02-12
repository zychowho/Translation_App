import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedPlan; // Stores the selected subscription plan

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
            // 🌎 App Icon
            Icon(Icons.language, size: 50, color: Colors.black),

            SizedBox(height: 10),

            // 📢 Tagline
            Text(
              "Make your translations more convenient for a reasonable price!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // 📜 Subscription Plans (Now Selectable)
            Expanded(
              child: ListView(
                children: [
                  _buildSubscriptionCard(
                    title: "SILVER",
                    description:
                    "You can use the regular text-to-text translation and picture-to-text translation feature!",
                    color: Colors.grey.shade300,
                  ),
                  _buildSubscriptionCard(
                    title: "GOLD",
                    description:
                    "You're free to use text-to-text, picture-to-text, and also voice recognition translation!",
                    color: Colors.amber.shade600,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 📌 Subscribe Button (Disabled until a plan is selected)
            ElevatedButton(
              onPressed: selectedPlan == null
                  ? null // Disable button if no plan is selected
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subscribed to $selectedPlan Plan!")),
                );
                // 🚀 Navigate to main app or perform subscription logic
                Navigator.pushReplacementNamed(context, '/main_app');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPlan == null
                    ? Colors.grey // Grey out if disabled
                    : Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Subscribe",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            SizedBox(height: 10),

            // ⏭ Skip Subscription Button (Now Navigates to Onboarding Page)
            TextButton(
              onPressed: () {
                // 🚀 Skip and go to the Onboarding Page
                Navigator.pushReplacementNamed(context, '/onboarding_page');
              },
              child: Text(
                "Skip Subscription",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Subscription Card Widget (Selectable)
  Widget _buildSubscriptionCard({
    required String title,
    required String description,
    required Color color,
  }) {
    bool isSelected = selectedPlan == title; // Check if this plan is selected

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = title; // Update selected plan
        });
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: isSelected ? color.withOpacity(0.6) : Colors.white, // Highlight selected plan
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
