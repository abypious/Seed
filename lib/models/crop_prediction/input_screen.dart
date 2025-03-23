import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  String espIp = "172.16.21.30";

  @override
  void initState() {
    super.initState();
    _fetchRainfallData();
    _checkESPConnection();
  }

  Future<void> _checkESPConnection() async {
    try {
      final result = await InternetAddress.lookup(espIp);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _showNotification("ESP32 is connected!", Colors.green);
      }
    } catch (e) {
      _showNotification("ESP32 is NOT connected!", Colors.red);
    }
  }

  Future<void> _fetchRainfallData() async {
    try {
      double rainfall = await ExcelService.getCurrentMonthRainfall(widget.district);
      setState(() {
        rainfallData = rainfall;
      });
      _showNotification("Rainfall data fetched successfully!", Colors.green);
    } catch (e) {
      _showNotification("Error fetching rainfall data!", Colors.red);
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

      if (!mounted) return;

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

      _showNotification("Sample ${currentSample} collected!", Colors.green);
    } catch (e) {
      _showNotification("Error fetching ESP32 data!", Colors.red);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _deleteSample(int index) {
    setState(() {
      collectedSamples.removeAt(index);
      currentSample--;
    });
    _showNotification("Sample ${index + 1} deleted!", Colors.orange);
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

  void _restartProcess() {
    setState(() {
      isLoading = false;
      rainfallData = null;
      currentSample = 0;
      collectedSamples.clear();
      _fetchRainfallData();
      _checkESPConnection();
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
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("District: ${widget.district}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Observatory: ${widget.observatory}", style: const TextStyle(fontSize: 16)),
                    Text("Land Area: ${widget.landArea} acres", style: const TextStyle(fontSize: 16)),
                    Text("Total Samples: ${widget.samples}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: currentSample / widget.samples,
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
              minHeight: 8,
            ),
            const SizedBox(height: 20),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SAMPLE ${index + 1}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text("Moisture: ${sample["moisture"]!.toStringAsFixed(2)}%"),
                                Text("Temperature: ${sample["temperature"]!.toStringAsFixed(2)}°C"),
                                Text("pH: ${sample["pH"]!.toStringAsFixed(2)}"),
                                Text("Nitrogen (N): ${sample["nitrogen"]!.toStringAsFixed(2)}"),
                                Text("Phosphorus (P): ${sample["phosphorus"]!.toStringAsFixed(2)}"),
                                Text("Potassium (K): ${sample["potassium"]!.toStringAsFixed(2)}"),
                                Text("Rainfall: ${sample["rainfall"]!.toStringAsFixed(2)} mm"),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSample(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : (currentSample >= widget.samples ? _navigateToResultScreen : _fetchSampleData),
                  icon: Icon(
                    currentSample >= widget.samples ? Icons.arrow_forward : Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    currentSample >= widget.samples ? "Proceed" : "Take Sample",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
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
