import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seed/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seed/models/crop_prediction/tflite_model.dart';
import 'package:seed/screens/onboarding.dart';
import 'package:seed/screens/dashboard.dart';
import 'components/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyD9kPXrU_g3mY22k3OZi2-z36jNJT1OyqI",
          authDomain: "seed-16df7.firebaseapp.com",
          projectId: "seed-16df7",
          storageBucket: "seed-16df7.firebasestorage.app",
          messagingSenderId: "245489876869",
          appId: "1:245489876869:web:88b8834af1583e29f7ceec",
          measurementId: "G-JR0L1G7MT4",
        ));
  } else {
    await Firebase.initializeApp();
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_time') ?? true;

  runApp(
    ChangeNotifierProvider<TFLiteModel>(
      create: (context) => TFLiteModel(),
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool showOnboarding;
  User? user;

  @override
  void initState() {
    super.initState();
    showOnboarding = widget.isFirstTime;
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    String? storedEmail = prefs.getString('user_email');

    setState(() {
      showOnboarding = isFirstTime;
      user = FirebaseAuth.instance.currentUser;

      if (storedEmail != null && storedEmail.isNotEmpty) {
        user = FirebaseAuth.instance.currentUser;
      }
    });
  }


  // Mark onboarding as completed
  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    setState(() {
      showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEED App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.white,
      ),
      home: _getStartingScreen(),
    );
  }

  Widget _getStartingScreen() {
    if (showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    } else if (user != null) {
      return DashboardScreen();
    } else {
      return HomeScreen();
    }
  }
}

