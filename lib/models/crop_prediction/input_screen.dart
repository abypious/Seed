import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    final model = Provider.of<TFLiteModel>(context, listen: false);
    model.loadModel();
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
        double.parse(rainfallController.text),
      ];

      try {
        List<Map<String, dynamic>> predictions = await model.predict(inputValues);

        String predictionResult = "Top 3 Crops:\n";
        predictions.asMap().forEach((index, prediction) {
          double confidence = double.tryParse(prediction['confidence'].toString()) ?? 0.0;
          int confidencePercentage = (confidence * 100).toInt();
          predictionResult += "${index + 1}. ${prediction['crop']}: $confidencePercentage%\n";
        });

        // Navigate to ResultScreen and pass the prediction result
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
      body: SingleChildScrollView(  // Wrap the body in SingleChildScrollView
        child: Container(
          color: const Color(0xFFD9FFD2), // Light pink background
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
                _buildTextField(rainfallController, 'Rainfall (mm)'),
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

  Widget _buildTextField(TextEditingController controller, String label) {
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
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }
}
