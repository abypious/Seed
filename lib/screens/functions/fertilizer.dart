import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:seed/components/colors.dart';
import 'dart:convert';
import '../../models/crop_prediction/esp_service.dart';



class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  _FertilizerRecommendationScreenState createState() =>
      _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState
    extends State<FertilizerRecommendationScreen> {
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();

  final String geminiAPIKey = "AIzaSyCtF2iUXbWtKdk2OCeeavJXR5cjPvoo4AU";

  String? _selectedCrop;
  String _recommendation = "";
  bool _isLoading = false;
  bool _dataFetched = false;
  String espIp = "172.16.21.30";

  @override
  void initState() {
    super.initState();
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }



  void _showNotification(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _fetchDataFromESP() async {
    _showLoadingDialog("Fetching Data");

    try {
      final data = await ESPService.getSensorData();

      if (!mounted) return;
      setState(() {
        _phController.text = data["pH"].toString();
        _nitrogenController.text = data["nitrogen"].toString();
        _phosphorusController.text = data["phosphorus"].toString();
        _potassiumController.text = data["potassium"].toString();
        _dataFetched = true;
      });

    } catch (e) {
      _showNotification("Error fetching data!", Colors.red);
    } finally {
      if (mounted) Navigator.pop(context); // Close the dialog
    }
  }


  Future<void> _getFertilizerRecommendation() async {
    if (_selectedCrop == null || _selectedCrop!.isEmpty) {
      _showNotification("Please select a crop!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    const String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

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
                Provide a fertilizer recommendation for $_selectedCrop based on:
                - pH: ${_phController.text}
                - Nitrogen: ${_nitrogenController.text} mg/kg
                - Phosphorus: ${_phosphorusController.text} mg/kg
                - Potassium: ${_potassiumController.text} mg/kg

                Response should include:
                1. Analysis: Mention if nitrogen, phosphorus, and potassium levels are normal, high, or low.
                2. Recommended Fertilizers: Suggest specific fertilizers (Urea, DAP, Potash) with exact amounts in kg per acre.
                3. Duration: Mention how often to apply each fertilizer (e.g., weekly, monthly).
                4. Application: Briefly describe how to apply for best absorption.

                Keep the response concise (30-50 words) without special symbols.
                """
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendation = data["candidates"][0]["content"]["parts"][0]["text"];

        if (!mounted) return;
        setState(() {
          _recommendation = recommendation;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch recommendation. Error: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recommendation = "Failed to get recommendation. Please try again.";
        _isLoading = false;
      });
      _showNotification("Error: ${e.toString()}", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Soil pH", _phController),
            _buildTextField("Nitrogen (mg/kg)", _nitrogenController),
            _buildTextField("Phosphorus (mg/kg)", _phosphorusController),
            _buildTextField("Potassium (mg/kg)", _potassiumController),

            const SizedBox(height: 25),

            DropdownButton<String>(
              value: _selectedCrop,
              isExpanded: true,
              hint: const Text("Select Your Crop"),
              items: [
                "Tomato", "Watermelon", "Tapioca", "Sweet Potato", "Sunflower",
                "Sugarcane", "Spinach", "Soybean", "Rice", "Pumpkin", "Peanut",
                "Okra", "Mustard Greens", "Muskmelon", "MungBeans", "Maize",
                "Lentil", "KidneyBeans", "Ginger", "Garlic", "Cucumber", "Cotton",
                "Chilli", "Cauliflower", "Carrot", "Cabbage", "Brinjal", "Banana"
              ]
                  .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCrop = value!),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _dataFetched ? _getFertilizerRecommendation : _fetchDataFromESP,
              label: Text(_dataFetched ? "Get AI Recommendation" : "Fetch Data" ,style:const TextStyle(color: AppColors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dataFetched ? AppColors.primary: Colors.greenAccent,
                minimumSize: const Size(35, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),
            if (_recommendation.isNotEmpty)
              Card(
                color: AppColors.primary,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_recommendation, style: const TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
