import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:seed/components/colors.dart';
import 'package:seed/screens/functions/pest.dart';
import 'package:seed/screens/home.dart';
import 'package:seed/screens/profile.dart';
import '../components/loading.dart';
import '../models/crop_prediction/TestInfoScreen.dart';
import 'functions/ai_assistant_screen.dart';
import 'functions/credits.dart';
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
  late PageController _pageController;

  final List<Widget> _screens = [
    const WeatherOutlookScreen(),
    TestInfoScreen(),
    const IrrigationScreen(),
    const FertilizerRecommendationScreen(),
    const AtlasMap(),
  ];

  final items = <Widget>[
    const Icon(Icons.home),
    const Icon(Icons.agriculture),
    const Icon(Icons.wb_cloudy),
    const Icon(Icons.science),
    const Icon(Icons.location_searching_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _startBlinkingEffect();
  }

  void _startBlinkingEffect() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _opacity = _opacity == 1.0 ? 0.0 : 1.0;
      });
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 20), // Faster transition
      curve: Curves.easeInQuart,
    );
  }

  void _showNavigation(BuildContext context, Widget page) {
    LoadingDialog.show(context);
    Future.delayed(const Duration(seconds: 2), () {
      LoadingDialog.hide(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBody: true,
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(_getAppBarTitle(_selectedIndex)),
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.black,
            automaticallyImplyLeading: false, // Remove default back button
            leading: _selectedIndex == 0
                ? IconButton(
              icon: const Icon(Icons.menu, color: AppColors.black),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
                : null,

            actions: _selectedIndex == 0
                ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    hoverColor: Colors.transparent,
                    highlightElevation: 0,
                    splashColor: Colors.transparent,
                    onPressed: () => _showNavigation(context,  PlantDiseaseScreen()),
                    child: Lottie.asset(
                      'assets/lottie/scan.json',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ]
                : [],

          ),
          drawer: _buildDrawer(),
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _screens,
              ),
              if (_selectedIndex == 0) _buildChatbotAssistant(),
            ],
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: AppColors.black),
            ),
            child: CurvedNavigationBar(
              backgroundColor: Colors.transparent,
              color: AppColors.secondary,
              buttonBackgroundColor: AppColors.primary,
              height: 60,
              animationDuration: const Duration(milliseconds: 500),
              index: _selectedIndex,
              onTap: _onItemTapped,
              items: items,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "Guest User"),
            accountEmail: Text(user?.email ?? "No Email"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage("assets/images/profile.png") as ImageProvider,
            ),
            decoration: const BoxDecoration(color: AppColors.secondary),
          ),
          ..._drawerItems(),
        ],
      ),
    );
  }


  List<Widget> _drawerItems() {
    return [
      _buildDrawerItem(Icons.home, "Home", 0),
      _buildDrawerItem(Icons.agriculture, "Crop Advisor", 1),
      _buildDrawerItem(Icons.cloud , "Irrigation", 2),
      _buildDrawerItem(Icons.science, "Fertilizer", 3),
      _buildDrawerItem(Icons.location_searching_outlined, "Atlas", 4),
      const Divider(),
      _buildDrawerItem(Icons.account_circle, "Profile", null, onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserProfileScreen()),
        );
      }),
      _buildDrawerItem(Icons.logout, "Logout", null, onTap: _logout),
      _buildDrawerItem(Icons.code_outlined, "Credits", null, onTap:(){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreditsPage()),
        );
      }),
    ];
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }


  Widget _buildDrawerItem(IconData icon, String title, int? index, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the drawer first
        if (onTap != null) {
          onTap();
        } else if (index != null) {
          _onItemTapped(index);
        }
      },
    );
  }

  Widget _buildChatbotAssistant() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 70),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _opacity > 0
                  ? Container(
                key: const ValueKey(1),
                padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  "What can I help you with?",
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showNavigation(context, const AIAssistantScreen()),
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                'assets/images/chatbot1.png',
                width: 55,
                height: 55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) => ["Home", "Crop Advisor", "Irrigation", "Fertilizer", "Atlas"][index];
}
