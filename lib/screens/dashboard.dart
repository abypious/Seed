import 'package:flutter/material.dart';
// import 'pest/pest.dart'; // Import
import 'package:seed/pest/pest.dart';
import 'package:seed/models/crop_prediction/input_screen.dart';
import 'functions/ai_assistant_screen.dart';
import 'functions/fertilizer.dart';
import 'functions/irrigation_planner_screen.dart';
import 'functions/weather_outlook_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    const WeatherOutlookScreen(),

    InputScreen(),
    const IrrigationScreen(),
    const FertilizerRecommendationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          _screens[_selectedIndex],

          // Show Pest Detection Button & Chatbot only on Home Screen (_selectedIndex == 0)
          if (_selectedIndex == 0)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Pest Detection Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlantDiseaseScreen()),
                        );
                      },
                      icon: Icon(Icons.bug_report, color: Colors.white),
                      label: Text("Disease Detection"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Chatbot Bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFC8E6C9),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                      child: const Text(
                        "What can I help you with?",
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Chatbot Icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AIAssistantScreen()),
                        );
                      },
                      child: Image.asset(
                        'assets/images/chatbot1.png',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: List.generate(4, (index) {
          return BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(6),
              child: Icon(
                _getIcon(index),
                size: _selectedIndex == index ? 32 : 24,
                color: _selectedIndex == index ? Colors.green : Colors.grey,
              ),
            ),
            label: _getLabel(index),
          );
        }),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Home";
      case 1:
        return "Crop Advisor";
      case 2:
        return "Irrigation";
      case 3:
        return "Fertilizer Recommendation";
      default:
        return "Dashboard";
    }
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.agriculture;
      case 2:
        return Icons.water_drop;
      case 3:
        return Icons.science;
      default:
        return Icons.home;
    }
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Crop";
      case 2:
        return "Irrigation";
      case 3:
        return "Fertilizer";
      default:
        return "";
    }
  }
}
