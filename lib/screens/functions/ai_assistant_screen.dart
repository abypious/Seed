import 'package:flutter/material.dart';

class AIAssistantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'AI Assistant Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
