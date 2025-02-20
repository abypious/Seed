import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tflite_model.dart';
import 'result.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController kController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final model = Provider.of<TFLiteModel>(context, listen: false);
    model.loadModel();
    _fetchSensorData(); // Fetch data from ESP device (except rainfall)
  }

  Future<void> _fetchSensorData() async {
    try {
      const String espUrl = "http://192.168.4.1/"; // Change this to your ESP32 device's IP
      final response = await http.get(Uri.parse(espUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          nController.text = data["nitrogen"].toString();
          pController.text = data["phosphorus"].toString();
          kController.text = data["potassium"].toString();
          tempController.text = data["temperature"].toString();
          phController.text = data["pH"].toString();
          humidityController.text = data["moisture"].toString();
          _isLoading = false; // Data fetched, stop loading indicator
        });
      } else {
        throw Exception("Failed to fetch data from ESP.");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _predictCrop() async {
    final model = Provider.of<TFLiteModel>(context, listen: false);

    if (!model.isModelLoaded) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      List<double> inputValues = [
        double.parse(nController.text),
        double.parse(pController.text),
        double.parse(kController.text),
        double.parse(tempController.text),
        double.parse(phController.text),
        double.parse(humidityController.text),
        double.parse(rainfallController.text.isEmpty ? "0" : rainfallController.text), // Manual input
      ];

      try {
        List<Map<String, dynamic>> predictions = await model.predict(inputValues);

        String predictionResult = "Top 3 Crops:\n";
        predictions.asMap().forEach((index, prediction) {
          double confidence = double.tryParse(prediction['confidence'].toString()) ?? 0.0;
          int confidencePercentage = (confidence * 100).toInt();
          predictionResult += "${index + 1}. ${prediction['crop']}: $confidencePercentage%\n";
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(predictionResult: predictionResult),
          ),
        );
      } catch (e) {
        print("Error during prediction: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Enter Parameters',
          style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : SingleChildScrollView(
        child: Container(
          color: const Color(0xFFD9FFD2),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter the required parameters to predict the best crop for your land.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildTextField(nController, 'Nitrogen'),
                _buildTextField(pController, 'Phosphorus'),
                _buildTextField(kController, 'Potassium'),
                _buildTextField(tempController, 'Temperature (°C)'),
                _buildTextField(phController, 'pH Level'),
                _buildTextField(humidityController, 'Humidity (%)'),
                _buildTextField(rainfallController, 'Rainfall (mm)', optional: true), // Manual input
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _predictCrop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    ),
                    child: const Text('Predict', style: TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (!optional && (value == null || value.isEmpty)) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }
}
