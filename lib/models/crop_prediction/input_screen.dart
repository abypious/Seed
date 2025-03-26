import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seed/models/crop_prediction/result.dart';
import '../../components/colors.dart';
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

    // Show the loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Taking Sample"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Collecting sample..."),
          ],
        ),
      ),
    );

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

      // Wait before closing the dialog
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context); // Close the dialog
        _showNotification("Sample $currentSample collected!", Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close the dialog
        _showNotification("Error fetching ESP32 data!", Colors.red);
      }
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text("Soil Sample Collection"),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: currentSample / widget.samples,
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[300],
                  color: Colors.teal,
                  minHeight: 8,
                );
              },
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
                                Text("Nitrogen: ${sample["nitrogen"]!.toStringAsFixed(2)}"),
                                Text("Phosphorus: ${sample["phosphorus"]!.toStringAsFixed(2)}"),
                                Text("Potassium: ${sample["potassium"]!.toStringAsFixed(2)}"),
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
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : (currentSample >= widget.samples ? _navigateToResultScreen : _fetchSampleData),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.transparent, // Removes button shadow
                backgroundColor: Colors.transparent, // Makes background fully transparent
                disabledForegroundColor: Colors.transparent.withOpacity(0), // Removes grey effect when disabled
                disabledBackgroundColor: Colors.transparent.withOpacity(0),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 180),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        currentSample >= widget.samples ? Icons.arrow_forward : Icons.add,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        currentSample >= widget.samples ? "Proceed" : "Take Sample",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
