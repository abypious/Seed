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
  final List<Map<String, String>> _messages = [
    {"bot": "Hey! I'm SEED, your personal assistant. How can I help you today?"}
  ];

  bool _selectionComplete = false;

  String? selectedDistrict;
  String? selectedObservatory;
  String? selectedLandArea;

  final String geminiAPIKey = "AIzaSyCtF2iUXbWtKdk2OCeeavJXR5cjPvoo4AU";

  final Map<String, List<String>> _observatoriesByDistrict = {
    'Thiruvananthapuram': ['Neyyattinkara', 'Thiruvananthapur AP (OBSY)', 'Thiruvananthapur (OBSY)', 'Varkala'],
    'Kollam': ['Aryankavu', 'Kollam (RLY)', 'Punalur (OBSY)'],
    'Pathanamthitta': ['Konni', 'Kurudamannil'],
    'Alappuzha': ['Alappuzha', 'Cherthala', 'Haripad', 'Kayamkulam (Agro)', 'Kayamkulam (RARS)', 'Mancompu', 'Mavelikara'],
    'Kottayam': ['Kanjirappally', 'Kottayam (RRII) (OBSY  )', 'Kozha', 'Kumarakom', 'Vaikom'],
    'Idukki': ['Idukki', 'Munnar (KSEB)', 'Myladumpara Agri', 'Peermade(TO)', 'Thodupuzha'],
    'Ernakulam': ['Alwaye PWD', 'CIAL Kochi (OBSY)', 'Ernakulam', 'NAS Kochi (OBSY)', 'Perumpavur', 'Piravam'],
    'Thrissur': ['Chalakudi', 'Enamakal', 'Irinjalakuda', 'Kodungallur', 'Kunnamkulam', 'Vadakkancherry', 'Vellanikkarai (OBSY)'],
    'Palakkad': ['Alathur (Hydro)', 'Chittur', 'Kollengode', 'Mannarkad', 'Ottapalam', 'Palakkad (OBSY)', 'Parambikulam', 'Pattambi (Agro)', 'Trithala'],
    'Malappuram': ['Angadipuram', 'Karipur AP (OBSY)', 'Manjeri', 'Nilambur', 'Perinthalamanna', 'Ponnani'],
    'Kozhikode': ['Kozhikode (OBSY)', 'Quilandi', 'Vadakara'],
    'Wayanad': ['Ambalavayal', 'Kuppadi', 'Mananthavady', 'Vythiri'],
    'Kannur': ['Irikkur', 'Kannur (OBSY)', 'Mahe', 'Taliparamba', 'Thalasserry'],
    'Kasargod': ['Hosdurg', 'Kudulu'],
  };

  final List<String> _landAreas = [
    "Less than 1 acre",
    "1 - 3 acres",
    "More than 3 acres"
  ];

  Future<void> _sendMessage() async {
    if (!_selectionComplete) return;

    String userMessage = _controller.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.insert(0, {"user": userMessage});
      });

      _controller.clear();
      HapticFeedback.lightImpact();

      String botResponse = await _fetchGeminiResponse(userMessage);
      botResponse = _cleanResponse(botResponse);

      setState(() {
        _messages.insert(0, {"bot": botResponse});
      });
    }
  }
  Future<String> _fetchGeminiResponse(String prompt) async {
    const String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";


    try {
      final response = await http.post(
        Uri.parse("$apiUrl?key=$geminiAPIKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text": """
                Context: The user is interacting with an AI assistant named SEED.
                The AI should prioritize answering agricultural questions but also respond to general queries.
                Limit response length to 4-5 sentences.

                Selected Inputs:
                - District: ${selectedDistrict ?? "Not provided"}
                - Observatory: ${selectedObservatory ?? "Not provided"}
                - Land Area: ${selectedLandArea ?? "Not provided"}

                User Query: $prompt
                """
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey("candidates") && data["candidates"].isNotEmpty) {
          String aiResponse = data["candidates"][0]["content"]["parts"][0]["text"].trim();

          // Limit response to 3-4 sentences max
          List<String> sentences = aiResponse.split('. ');
          return '${sentences.take(3).join('. ')}.';
        } else {
          return "No valid response from Gemini API.";
        }
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }



  String _cleanResponse(String response) {
    return response.replaceAll("*", "").replaceAll("_", "").replaceAll("`", "").replaceAll("\n\n", "\n");
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
              'assets/images/chat.png', // Background Image
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
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser)
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
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2)],
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

              if (!_selectionComplete)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedDistrict,
                        hint: const Text("Select District"),
                        items: _observatoriesByDistrict.keys.map((String district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistrict = value;
                            selectedObservatory = null;
                            selectedLandArea = null;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (selectedDistrict != null)
                        DropdownButtonFormField<String>(
                          value: selectedObservatory,
                          hint: const Text("Select Observatory"),
                          items: _observatoriesByDistrict[selectedDistrict]!.map((String observatory) {
                            return DropdownMenuItem<String>(
                              value: observatory,
                              child: Text(observatory),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedObservatory = value;
                              selectedLandArea = null;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      const SizedBox(height: 10),

                      if (selectedObservatory != null)
                        DropdownButtonFormField<String>(
                          value: selectedLandArea,
                          hint: const Text("Select Land Area"),
                          items: _landAreas.map((String landArea) {
                            return DropdownMenuItem<String>(
                              value: landArea,
                              child: Text(landArea),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedLandArea = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      const SizedBox(height: 10),

                      if (selectedLandArea != null)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _messages.insert(0, {"bot": "Thank you! Now you can ask me anything."});
                              _selectionComplete = true;
                            });
                          },
                          child: const Text("Confirm Selection"),
                        ),
                    ],
                  ),
                ),

              if (_selectionComplete)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
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
