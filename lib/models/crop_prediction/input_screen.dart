import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seed/models/crop_prediction/result.dart';
import 'ExcelService.dart';
import 'esp_service.dart';

class InputScreen extends StatefulWidget {
  final double landArea;
  final String district;
  final String observatory;
  final int samples;

  const InputScreen({
    required this.landArea,
    required this.district,
    required this.observatory,
    required this.samples,
  });

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  bool isLoading = false;
  double? rainfallData;
  int currentSample = 0;
  List<Map<String, double>> collectedSamples = [];

  @override
  void initState() {
    super.initState();
    _fetchRainfallData();
  }

  Future<void> _fetchRainfallData() async {
    try {
      double rainfall = await ExcelService.getCurrentMonthRainfall(widget.district);
      setState(() {
        rainfallData = rainfall;
      });
    } catch (e) {
      print("Error fetching rainfall: $e");
      setState(() {
        rainfallData = null;
      });
    }
  }

  Future<void> _fetchSampleData() async {
    if (currentSample >= widget.samples) return;
    if (rainfallData == null) return;

    setState(() => isLoading = true);

    try {
      Map<String, dynamic> sensorData = await ESPService.getSensorData();

      setState(() {
        collectedSamples.add({
          "moisture": sensorData["moisture"]?.toDouble() ?? 0.0,
          "temperature": sensorData["temperature"]?.toDouble() ?? 0.0,
          "pH": sensorData["pH"]?.toDouble() ?? 0.0,
          "nitrogen": sensorData["nitrogen"]?.toDouble() ?? 0.0,
          "phosphorus": sensorData["phosphorus"]?.toDouble() ?? 0.0,
          "potassium": sensorData["potassium"]?.toDouble() ?? 0.0,
          "rainfall": rainfallData ?? 0.0,
        });
        currentSample++;
      });
    } catch (e) {
      print("Error fetching ESP32 data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _restartProcess() {
    setState(() {
      isLoading = false;
      rainfallData = null;
      currentSample = 0;
      collectedSamples.clear();
      _fetchRainfallData();
    });
  }

  void _navigateToResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(samples: collectedSamples),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Soil Sample Collection"),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // District & Land Info
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity, // Full width
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🌍 District: ${widget.district}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("📍 Observatory: ${widget.observatory}",
                        style: const TextStyle(fontSize: 16)),
                    Text("🏡 Land Area: ${widget.landArea} acres",
                        style: const TextStyle(fontSize: 16)),
                    Text("🧪 Total Samples: ${widget.samples}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Progress Bar
            LinearProgressIndicator(
              value: currentSample / widget.samples,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
              minHeight: 8,
            ),

            const SizedBox(height: 20),

            // Sample List
            Expanded(
              child: ListView.builder(
                itemCount: collectedSamples.length,
                itemBuilder: (context, index) {
                  var sample = collectedSamples[index];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sample Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SAMPLE ${index + 1}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text("💧 Moisture: ${sample["moisture"]!.toStringAsFixed(2)}%"),
                                Text("🌡️ Temperature: ${sample["temperature"]!.toStringAsFixed(2)}°C"),
                                Text("🔬 pH: ${sample["pH"]!.toStringAsFixed(2)}"),
                                Text("🟡 Nitrogen (N): ${sample["nitrogen"]!.toStringAsFixed(2)}"),
                                Text("🟣 Phosphorus (P): ${sample["phosphorus"]!.toStringAsFixed(2)}"),
                                Text("🟠 Potassium (K): ${sample["potassium"]!.toStringAsFixed(2)}"),
                                Text("🌧️ Rainfall: ${sample["rainfall"]!.toStringAsFixed(2)} mm"),
                              ],
                            ),
                          ),

                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                collectedSamples.removeAt(index);
                                currentSample--; // Allows retaking the sample
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Buttons in a Single Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Take Sample / Proceed Button (Dynamic)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : (currentSample == widget.samples)
                        ? _navigateToResultScreen
                        : _fetchSampleData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : (currentSample == widget.samples)
                        ? const Icon(Icons.arrow_forward, color: Colors.white)
                        : const Icon(Icons.add, color: Colors.white),
                    label: isLoading
                        ? const Text("")
                        : (currentSample == widget.samples)
                        ? const Text("Proceed", style: TextStyle(color: Colors.white, fontSize: 18))
                        : const Text("Take Sample", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),

                const SizedBox(width: 10),

                // Restart Button (Only Icon)
                IconButton(
                  icon: const Icon(Icons.restart_alt, color: Colors.red, size: 32),
                  onPressed: _restartProcess,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
