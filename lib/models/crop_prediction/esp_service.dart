import 'dart:convert';
import 'package:http/http.dart' as http;

class ESPService {
  static Future<Map<String, dynamic>> getSensorData() async {
    try {
      final response = await http.get(Uri.parse('http://172.16.21.30/data'));

      if (response.statusCode == 200) {
        print("✅ ESP32 Raw Data: ${response.body}"); // Debugging
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch sensor data from ESP32.");
      }
    } catch (e) {
      print("❌ ESP32 Error: $e");
      return {};
    }
  }
}
