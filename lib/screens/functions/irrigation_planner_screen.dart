import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  _IrrigationScreenState createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  String? _selectedCrop;
  int _selectedDaysAgo = 7;
  String _recommendation = "";
  String _advisor = "";
  bool _isLoading = false;
  bool _showButton = true;

  double latitude = 10.1632;
  double longitude = 76.6413;

  final Map<int, String> daysAgoText = {
    2: "2 Days Ago",
    3: "3 Days Ago",
    7: "1 Week Ago",
    14: "2 Weeks Ago"
  };

  /// Fetch weather data and generate recommendation & advisor
  Future<void> _fetchWeatherData() async {
    if (_selectedCrop == null) {
      _showNotification("Please select a crop!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
      _showButton = false;
    });

    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude"
        "&daily=precipitation_sum,temperature_2m_max&past_days=15&forecast_days=15"
        "&timezone=auto";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _processWeatherData(data);
      } else {
        throw Exception("Failed to fetch weather data");
      }
    } catch (e) {
      setState(() {
        _recommendation = "Error fetching data!";
        _advisor = "";
        _showButton = true;
      });
      _showNotification("Error: ${e.toString()}", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Process fetched weather data and generate recommendation & advisor
  void _processWeatherData(Map<String, dynamic> data) {
    List pastRainfall = data["daily"]["precipitation_sum"].sublist(0, 15);
    List futureRainfall = data["daily"]["precipitation_sum"].sublist(15);

    double pastRainfallTotal = pastRainfall.reduce((a, b) => a + b);
    double futureRainfallTotal = futureRainfall.reduce((a, b) => a + b);

    String irrigationText = daysAgoText[_selectedDaysAgo] ?? "Unknown";

    String recommendation;
    if (pastRainfallTotal < 30 && futureRainfallTotal < 20 && _selectedDaysAgo > 7) {
      recommendation = "Low rainfall detected. Your crop ($_selectedCrop) needs irrigation this week.";
    } else if (futureRainfallTotal > 20) {
      recommendation = "Rain predicted soon. Delay irrigation for $_selectedCrop.";
    } else {
      recommendation = "Sufficient moisture. No immediate irrigation needed.";
    }

    setState(() {
      _recommendation = """
🌧 Past Rainfall: ${pastRainfallTotal.toStringAsFixed(2)} mm  
🌤 Predicted Rainfall: ${futureRainfallTotal.toStringAsFixed(2)} mm  
🕒 Last Irrigation: $irrigationText  

✅ Recommendation: $recommendation
""";
      _advisor = _getIrrigationAdvice();
    });
  }

  /// Generate Irrigation Advice (Custom Function)
  String _getIrrigationAdvice() {
    return "💡 Based on weather patterns:\n"
        "✔️ Ensure soil moisture levels are monitored.\n"
        "✔️ If rain is expected, avoid overwatering.\n"
        "✔️ Use mulch to retain soil moisture for better crop yield.";
  }

  /// Show Toast Notification
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

  /// Build Dropdown
  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  /// Build Information Card
  Widget _buildInfoCard(String content, Color? color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Subtle background
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Selection
            _buildDropdown<String>(
              label: "Select Crop",
              value: _selectedCrop,
              hint: "Choose the crop you are growing",
              items: ["Tomato", "Rice", "Sugarcane", "Cotton", "Carrot", "Pumpkin", "Banana"]
                  .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCrop = value),
            ),
            const SizedBox(height: 15),

            // Last Irrigation Selection
            _buildDropdown<int>(
              label: "Last Irrigation",
              value: _selectedDaysAgo,
              hint: "Select the last irrigation time",
              items: daysAgoText.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDaysAgo = value!),
            ),
            const SizedBox(height: 20),

            // Fetch Button
            if (_showButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _fetchWeatherData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.blue,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Get Irrigation Plan", style: TextStyle(fontSize: 16)),
                ),
              ),

            // Recommendation & Advisor Cards
            if (_recommendation.isNotEmpty)
              Column(
                children: [
                  _buildInfoCard(_recommendation, Colors.lightBlue[50]),
                  const SizedBox(height: 15),
                  _buildInfoCard(_advisor, Colors.green[50]),
                ],
              ),
          ],
        ),
      ),
    );
  }

}
