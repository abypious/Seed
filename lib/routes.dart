import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/auth/login.dart';

Map<String, WidgetBuilder> routes = {
  '/': (context) => HomeScreen(),
  '/login': (context) => LoginScreen(),
};
