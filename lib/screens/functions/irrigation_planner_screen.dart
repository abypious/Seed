import 'package:flutter/material.dart';

class IrrigationPlannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Irrigation Planner'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Irrigation Planner Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
