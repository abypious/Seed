import 'package:flutter/material.dart';
import 'package:seed/components/colors.dart';
import 'predicted_crop.dart';

class ResultScreen extends StatelessWidget {
  final List<Map<String, double>> samples;

  const ResultScreen({Key? key, required this.samples}) : super(key: key);

  Map<String, double> computeAverages() {
    Map<String, double> averages = {
      "Moisture": 0,
      "Temperature": 0,
      "pH Level": 0,
      "Nitrogen": 0,
      "Phosphorus": 0,
      "Potassium": 0,
      "Rainfall": 0,
    };

    if (samples.isEmpty) return averages;

    for (var sample in samples) {
      averages["Nitrogen"] = (averages["Nitrogen"]! + sample["nitrogen"]!);
      averages["Phosphorus"] = (averages["Phosphorus"]! + sample["phosphorus"]!);
      averages["Potassium"] = (averages["Potassium"]! + sample["potassium"]!);
      averages["Temperature"] = (averages["Temperature"]! + sample["temperature"]!);
      averages["pH Level"] = (averages["pH Level"]! + sample["pH"]!);
      averages["Moisture"] = (averages["Moisture"]! + sample["moisture"]!);
      averages["Rainfall"] = (averages["Rainfall"]! + sample["rainfall"]!);
    }

    int count = samples.length;
    averages.updateAll((key, value) => value / count);

    return averages;
  }

  @override
  Widget build(BuildContext context) {
    final averages = computeAverages();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Soil Analysis Result',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.white,
        shadowColor: Colors.black54,
        elevation: 2,
      ),
      body: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Averaged Soil Sample Data',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDataRow("Moisture", "${averages["Moisture"]!.toStringAsFixed(2)}%"),
                    _buildDataRow("Temperature", "${averages["Temperature"]!.toStringAsFixed(2)}°C"),
                    _buildDataRow("pH Level", "${averages["pH Level"]!.toStringAsFixed(2)}"),
                    _buildDataRow("Nitrogen", "${averages["Nitrogen"]!.toStringAsFixed(2)}"),
                    _buildDataRow("Phosphorus", "${averages["Phosphorus"]!.toStringAsFixed(2)}"),
                    _buildDataRow("Potassium", "${averages["Potassium"]!.toStringAsFixed(2)}"),
                    _buildDataRow("Rainfall", "${averages["Rainfall"]!.toStringAsFixed(2)} mm"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredictedCropScreen(inputValues: computeAverages()),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 3,
              ),
              child: const Text(
                'Predict',
                style: TextStyle(color: Colors.black87, fontSize: 18,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
