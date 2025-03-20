import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seed/models/crop_prediction/input_screen.dart';
import 'functions/ai_assistant_screen.dart';
import 'functions/cropAtlas.dart';
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
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startBlinkingEffect();
  }

  void _startBlinkingEffect() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _opacity = _opacity == 1.0 ? 0.0 : 1.0;
        });
      }
    });
  }

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
    const AtlasMap(),
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
          if (_selectedIndex == 0)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 90),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 1000),
                      opacity: _opacity,
                      child: Container(
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
                    ),
                    const SizedBox(height: 0),
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


      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => _showAtlasNavigation(context),
          child: const Icon(Icons.fmd_good_outlined, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: List.generate(4, (index) {
          return BottomNavigationBarItem(
            icon: Icon(
              _getIcon(index),
              size: _selectedIndex == index ? 32 : 24,
              color: _selectedIndex == index ? Colors.green : Colors.grey,
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

  void _showAtlasNavigation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Navigate to Atlas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Click the button below to navigate to Atlas."),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AtlasMap()),
                    );
                  },
                  child: const Text("Go to Atlas", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0: return "Home";
      case 1: return "Crop Advisor";
      case 2: return "Irrigation";
      case 3: return "Fertilizer Recommendation";
      default: return "Dashboard";
    }
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0: return Icons.home;
      case 1: return Icons.agriculture;
      case 2: return Icons.water_drop;
      case 3: return Icons.science;
      default: return Icons.home;
    }
  }

  String _getLabel(int index) {
    switch (index) {
      case 0: return "Home";
      case 1: return "Crop";
      case 2: return "Irrigation";
      case 3: return "Fertilizer";
      default: return "";
    }
  }
}
