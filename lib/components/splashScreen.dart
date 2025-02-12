import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/functions/weather_outlook_screen.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Replace with your home screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color if needed
      body: Center(
        child: Image.asset('assets/images/seed.jpg', width: 150), // Replace with your logo
      ),
    );
  }
}
