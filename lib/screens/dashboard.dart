import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Dashboard Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
