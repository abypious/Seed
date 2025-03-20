import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

class ExcelService {
  /// **Get the average rainfall for the selected observatory & month**
  static Future<double?> getRainfallAverage(String district, String observatory) async {
    try {
      // Load the Excel file from assets
      ByteData data = await rootBundle.load('assets/rain_data/$district.xlsx');
      List<int> bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      // Select the first sheet (assuming it contains the data)
      var sheet = excel.tables.keys.first;
      var table = excel.tables[sheet];

      // Get the current month (1 = Jan, 2 = Feb, ...)
      DateTime now = DateTime.now();
      int currentMonth = now.month;

      // Store available years of rainfall data
      List<double> rainfallValues = [];

      for (var row in table!.rows.skip(1)) {
        String? obsName = row[0]?.value.toString(); // Column 1 = Observatory Name
        int? month = int.tryParse(row[2]?.value.toString() ?? ''); // Column 3 = Month
        double? rainfall = double.tryParse(row[3]?.value.toString() ?? ''); // Column 4 = Rainfall

        if (obsName == observatory && month == currentMonth && rainfall != null) {
          rainfallValues.add(rainfall);
        }
      }

      // **If there’s no data, return null**
      if (rainfallValues.isEmpty) {
        print("No rainfall data available for $observatory in $district.");
        return null;
      }

      // **Calculate average using available data (even if less than 5 years)**
      double averageRainfall = rainfallValues.reduce((a, b) => a + b) / rainfallValues.length;
      return averageRainfall;

    } catch (e) {
      print("Error reading Excel file: $e");
      return null;
    }
  }
}
