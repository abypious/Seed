import 'package:flutter/material.dart';
import 'models/crop_prediction/input_screen.dart';
import 'models/crop_prediction/result.dart';

import 'screens/home.dart';
import 'screens/auth/login.dart';


Map<String, WidgetBuilder> routes = {
  '/': (context) => HomeScreen(),
  '/login': (context) => LoginScreen(),
  '/result': (context) => ResultScreen(),
  '/inputScreen': (context) => InputScreen(),
};
