import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  final String geminiAPIKey = "AIzaSyCdIb66lRkSPFYuUkQwPtjB2ZQrtw-A68o"; // Replace with your Gemini API key

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String userMessage = _controller.text.trim();

      setState(() {
        _messages.insert(0, {"user": userMessage});
        _isTyping = true;
      });

      _controller.clear();
      HapticFeedback.lightImpact();

      String botResponse = await _fetchGeminiResponse(userMessage);
      botResponse = _cleanResponse(botResponse); // Remove formatting
      setState(() {
        _messages.insert(0, {"bot": botResponse});
        _isTyping = false;
      });
    }
  }

  Future<String> _fetchGeminiResponse(String prompt) async {
    const String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

    final response = await http.post(
      Uri.parse("$apiUrl?key=$geminiAPIKey"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"].trim();
    } else {
      return "Sorry, I couldn't fetch a response.";
    }
  }

  /// Removes markdown formatting (*, _, -) from text
  String _cleanResponse(String response) {
    return response
        .replaceAll("*", "") // Remove bold/italic formatting
        .replaceAll("_", "") // Remove underscores
        .replaceAll("`", "") // Remove inline code formatting
        .replaceAll("\n\n", "\n"); // Reduce extra new lines
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('AI Assistant', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("End Chat", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/chat.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message.containsKey("user");

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start, // User on right, bot on left
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) // Bot's avatar (stick to the left)
                            const CircleAvatar(
                              radius: 18,
                              backgroundImage: AssetImage('assets/images/chatbot1.png'),
                            ),
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(left: 10, right: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blueAccent : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(15),
                                  topRight: const Radius.circular(15),
                                  bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
                                ],
                              ),
                              child: Text(
                                message.values.first,
                                style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: AssetImage('assets/images/chatbot1.png'),
                      ),
                      SizedBox(width: 8),
                      Text("typing...", style: TextStyle(color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
