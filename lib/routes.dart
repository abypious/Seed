import 'package:flutter/material.dart';
import 'package:seed/screens/dashboard.dart';
import 'screens/home.dart';
import 'screens/auth/login.dart';

Map<String, WidgetBuilder> routes = {
  '/': (context) => HomeScreen(),
  '/login': (context) => LoginScreen(),
  '/dashboard' :(context) =>  const DashboardScreen(),
};
