import 'package:flutter/material.dart';

class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  _FertilizerRecommendationScreenState createState() => _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState extends State<FertilizerRecommendationScreen> {
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  String _selectedCrop = "Wheat"; // Default crop
  String _recommendation = "";

  void _getFertilizerRecommendation() {
    double ph = double.tryParse(_phController.text) ?? 0.0;
    int nitrogen = int.tryParse(_nitrogenController.text) ?? 0;
    int phosphorus = int.tryParse(_phosphorusController.text) ?? 0;
    int potassium = int.tryParse(_potassiumController.text) ?? 0;

    // Simple recommendation logic (can be replaced with AI/ML model)
    if (ph < 5.5) {
      _recommendation = "Add Lime to increase soil pH.";
    } else if (ph > 7.5) {
      _recommendation = "Add Sulfur to lower soil pH.";
    } else if (nitrogen < 50) {
      _recommendation = "Use Urea or Ammonium Nitrate for nitrogen boost.";
    } else if (phosphorus < 30) {
      _recommendation = "Apply Single Super Phosphate (SSP).";
    } else if (potassium < 30) {
      _recommendation = "Use Muriate of Potash (MOP) for potassium boost.";
    } else {
      _recommendation = "Your soil is well-balanced. Maintain regular composting!";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Soil pH", _phController),
            _buildTextField("Nitrogen (mg/kg)", _nitrogenController),
            _buildTextField("Phosphorus (mg/kg)", _phosphorusController),
            _buildTextField("Potassium (mg/kg)", _potassiumController),

            // Crop Type Dropdown
            const SizedBox(height: 10),
            const Text("Select Crop:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCrop,
              isExpanded: true,
              items: ["Wheat", "Rice", "Maize", "Soybean", "Potato"]
                  .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // Recommendation Button
            Center(
              child: ElevatedButton(
                onPressed: _getFertilizerRecommendation,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Get Recommendation"),
              ),
            ),

            const SizedBox(height: 20),

            // Display Recommendation
            if (_recommendation.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.lightGreen[100], borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "Recommendation: $_recommendation",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Text Field Helper
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
