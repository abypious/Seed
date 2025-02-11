import 'package:flutter/material.dart';
import 'functions/ai_assistant_screen.dart';
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
    HomeScreen(),
    const IrrigationScreen(),
    const Center(child: Text('Alerts', style: TextStyle(fontSize: 18))),
    const Center(child: Text('Profile', style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          _screens[_selectedIndex],

          // Aligning floating action button & text at bottom right
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: const BoxDecoration
                      (
                        color: Color(0xFFC8E6C9),
                          borderRadius: BorderRadius.only
                            (
                              topLeft:Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft:Radius.circular(8),
                              bottomRight:Radius.circular(0),
                            ),
                      ),
                    child: const Text(
                      "What can I help you with?",
                      style: TextStyle(color: Colors.black87, fontSize: 13,),


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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Irrigation'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
