import 'package:flutter/material.dart';
import 'package:seed/screens/functions/ai_assistant_screen.dart';
import 'package:seed/screens/functions/crop_advisor_screen.dart';
import 'package:seed/screens/functions/irrigation_planner_screen.dart';
import 'package:seed/screens/functions/weather_outlook_screen.dart';

import '../widgets/cards.dart';


class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two cards per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            FeatureCard(
              title: "Crop Advisor",
              description: "Get insights on the best crops for your soil.",
              icon: Icons.local_florist,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CropAdvisorScreen()),
                );
              },
            ),
            FeatureCard(
              title: "Weather Outlook",
              description: "Stay updated with the latest weather forecasts.",
              icon: Icons.wb_sunny,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherOutlookScreen()),
                );
              },
            ),
            FeatureCard(
              title: "Irrigation Planner",
              description: "Plan your irrigation based on weather and soil needs.",
              icon: Icons.water_drop,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IrrigationPlannerScreen()),
                );
              },
            ),
            FeatureCard(
              title: "AI Assistant",
              description: "Receive AI-driven advice for better farming practices.",
              icon: Icons.smart_toy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AIAssistantScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
