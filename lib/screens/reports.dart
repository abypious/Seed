import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Report Screen Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
