import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _controller = TextEditingController();

  // Function to handle sending the support query
  void sendQuery() {
    final query = _controller.text;
    if (query.isNotEmpty) {
      // Here, you can implement backend logic or email functionality to send the query
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your query has been sent successfully!')),
      );
      _controller.clear(); // Clear the text field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your query.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Support'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need Help? We\'re here for you!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Please describe your issue or query below:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 5, // Allows for multiple lines
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your query...',
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: sendQuery,
                child: Text('Send Query'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
