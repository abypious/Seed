import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seed/models/crop_prediction/tflite_model.dart';
import 'package:seed/routes.dart';
import 'package:seed/screens/onboarding.dart';
import 'screens/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
        await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyD9kPXrU_g3mY22k3OZi2-z36jNJT1OyqI",
        authDomain: "seed-16df7.firebaseapp.com",
        projectId: "seed-16df7",
        storageBucket: "seed-16df7.firebasestorage.app",
        messagingSenderId: "245489876869",
        appId: "1:245489876869:web:88b8834af1583e29f7ceec",
        measurementId: "G-JR0L1G7MT4"));
  }else {
        await Firebase.initializeApp();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TFLiteModel()), // Register Provider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Prediction',
      initialRoute: '/',
      onUnknownRoute: (settings) =>
          MaterialPageRoute(
            builder: (context) =>
                Scaffold(
                  body: Center(child: Text("404: Route Not Found!")),
                ),
          ),
      // Use the defined routes
      routes: routes, // Handle unknown routes gracefully
      home: OnboardingScreen(),
    );
  }
}
