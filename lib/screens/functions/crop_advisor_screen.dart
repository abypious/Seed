import 'package:flutter/material.dart';

class CropAdvisorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Advisor'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Crop Advisor Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
