import 'package:flutter/material.dart';

class WeatherOutlookScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Outlook'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Weather Outlook Content Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
