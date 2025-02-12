import 'package:flutter/material.dart';
import 'package:seed/screens/profile.dart';
import 'functions/ai_assistant_screen.dart';
import 'functions/crop_advisor_screen.dart';
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
    CropAdvisorScreen(),
    const IrrigationScreen(),
    const FertilizerRecommendationScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()), // Dynamic title
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          _screens[_selectedIndex],

          // Show chatbot only on the Home screen (_selectedIndex == 0)
          if (_selectedIndex == 0)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                    const SizedBox(height: 6), // Space between text & button
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
                size: _selectedIndex == index ? 32 : 24, // Animated size
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

// Function to get dynamic AppBar title
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

// Function to get icon for BottomNavigationBar
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

// Function to get label for BottomNavigationBar
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
