import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class PlantDiseaseScreen extends StatefulWidget {
  @override
  _PlantDiseaseScreenState createState() => _PlantDiseaseScreenState();
}

class _PlantDiseaseScreenState extends State<PlantDiseaseScreen> {
  File? _image;
  String _diseaseName = "";
  String _recommendation = "";
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();
  final String apiKey = "AIzaSyCY0DbUQNbhYCMWcSwiH5WIBdyQYbf7z10"; // Replace with your API key

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _diseaseName = "";
        _recommendation = "";
        _loading = true;
      });
      await _detectDisease(_image!);
    }
  }
  Future<void> _detectDisease(File image) async {
    setState(() => _loading = true);

    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey");

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": "Analyze this plant image and detect the disease. Provide only the disease name and a structured treatment plan categorized into: \n"
                "1. **Cultural Practices** (Prevention techniques like pruning, crop rotation).\n"
                "2. **Chemical Treatment** (Recommended fungicides and application methods).\n"
                "3. **Organic Remedies** (Eco-friendly treatments, home remedies).\n"
                "Avoid unnecessary formatting like *** or markdown syntax."},
            {"inlineData": {"mimeType": "image/jpeg", "data": base64Image}}
          ]
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey("candidates")) {
        final String responseText = data["candidates"][0]["content"]["parts"][0]["text"];

        List<String> responseLines = responseText.split("\n\n");
        setState(() {
          _diseaseName = responseLines.isNotEmpty ? responseLines[0] : "Disease Not Identified";
          _recommendation = responseLines.length > 1 ? responseLines.sublist(1).join("\n\n") : "No recommendation provided.";
        });
      } else {
        setState(() {
          _diseaseName = "Detection failed.";
          _recommendation = "No response from AI.";
        });
      }
    } else {
      setState(() {
        _diseaseName = "Detection failed.";
        _recommendation = "Try again.";
      });
    }

    setState(() => _loading = false);
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Disease Prediction', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 250, fit: BoxFit.cover),
                )
                    : Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                SizedBox(height: 20),
                _loading
                    ? CircularProgressIndicator()
                    : _diseaseName.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Disease Name:",
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _diseaseName,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Treatment:",
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _recommendation,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Container(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text("Take Photo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.image),
                      label: Text("Upload Photo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),


    );
  }
}
