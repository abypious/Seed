import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:seed/screens/profile.dart';
import '../components/loading.dart';
import '../models/crop_prediction/TestInfoScreen.dart';
import '../pest/pest.dart';
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

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {

  int _selectedIndex = 0;
  double _opacity = 1.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<AnimationController?> _controllers ;

  final List<String> _lottieFiles = [
    'assets/lottie/home.json',
    'assets/lottie/crop.json',
    'assets/lottie/irrigation.json',
    'assets/lottie/fertilizer.json',
    'assets/lottie/atlas.json',
  ];

  final List<Widget> _screens = [
    const WeatherOutlookScreen(),
    TestInfoScreen(),
    const IrrigationScreen(),
    const FertilizerRecommendationScreen(),
    const AtlasMap(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers(); // Initialize Lottie controllers
    _startBlinkingEffect();   // Start blinking effect
  }

  void _initializeControllers() {
    _controllers = List.generate(
      _lottieFiles.length,
          (_) => AnimationController(vsync: this)..stop(),
    );
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
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    super.dispose();
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      for (int i = 0; i < _controllers.length; i++) {
        if (i == _selectedIndex) {
          _controllers[i]?.repeat(); // ✅ Play animation for the selected tab
        } else {
          _controllers[i]?.stop(); // ✅ Stop all other animations
        }
      }
    });
  }

  Widget _getLottieIcon(int index) {
    return Lottie.asset(
      _lottieFiles[index],
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      controller: _controllers[index],
      animate: index == _selectedIndex, // ✅ This prevents unnecessary animation
      onLoaded: (composition) {
        setState(() {
          _controllers[index]!.duration = composition.duration;
          if (index == _selectedIndex) {
            _controllers[index]!.repeat();
          } else {
            _controllers[index]!.stop();
          }
        });
      },
    );
  }


  void _showPlantDiseaseNavigation(BuildContext context) {
    LoadingDialog.show(context);

    Future.delayed(const Duration(seconds: 2), () {
      LoadingDialog.hide(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlantDiseaseScreen()),
      );
    });
  }

  void _showChatBotNavigation(BuildContext context) {
    LoadingDialog.show(context);

    Future.delayed(const Duration(seconds: 2), () {
      LoadingDialog.hide(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: _selectedIndex == 0
            ? [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.account_circle, size: 40, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                );
              },
            ),
          ),
        ]
            : null,
      ),

      // 🟢 Drawer Added Here
      drawer: _buildDrawer(),

      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_selectedIndex == 0) _buildChatbotAssistant(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            hoverElevation: 0,
            splashColor: Colors.transparent,
            onPressed: () {
              _showPlantDiseaseNavigation(context);
            },
            child: Lottie.asset(
              'assets/lottie/scan.json',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ],
      )
          : null,


      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: List.generate(5, (index) {
          return BottomNavigationBarItem(
            icon: _getLottieIcon(index),
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


  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Ashwin"),
            accountEmail: const Text("ashwin@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset("assets/images/profile.png"), // Replace with actual image
            ),
            decoration: const BoxDecoration(color: Colors.green),
          ),
          _buildDrawerItem(Icons.home, "Home", 0),
          _buildDrawerItem(Icons.agriculture, "Crop Advisor", 1),
          _buildDrawerItem(Icons.water_drop, "Irrigation", 2),
          _buildDrawerItem(Icons.science, "Fertilizer", 3),
          _buildDrawerItem(Icons.map, "Atlas", 4),
          const Divider(),
          _buildDrawerItem(Icons.account_circle, "Profile", null, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          }),
          _buildDrawerItem(Icons.logout, "Logout", null, onTap: () {
            // Handle logout action here
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int? index, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      onTap: onTap ?? () {
        if (index != null) {
          _onItemTapped(index);
        }
      },
    );
  }

  Widget _buildChatbotAssistant() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 30),
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
                _showChatBotNavigation(context);
              },
              child: Image.asset(
                'assets/images/chatbot1.png',
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }


  String _getAppBarTitle(int index) {
    return ["Home", "Crop Advisor", "Irrigation", "Fertilizer Recommendation", "Atlas"][index];
  }

  String _getLabel(int index) {
    return ["Home", "Crop", "Irrigation", "    Fertilizer", "Atlas"][index];
  }
}

Widget _getLottieIcon(int index) {
  List<String> lottieFiles = [
    'assets/lottie/home.json',
    'assets/lottie/crop.json',
    'assets/lottie/irrigation.json',
    'assets/lottie/fertilizer.json',
    'assets/lottie/atlas.json',
  ];

  return Lottie.asset(
    lottieFiles[index],
    width: 40,
    height: 40,
    fit: BoxFit.cover,
  );
}