import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class ExcelService {
  static Future<double> getCurrentMonthRainfall(String district) async {
    try {
      String filePath = 'assets/rain_data/$district.xlsx';
      print("Loading file: $filePath");

      ByteData data = await rootBundle.load(filePath);
      List<int> bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      // Debug: Print sheet names
      print("Sheet Names: ${excel.tables.keys.toList()}");

      // Get first sheet
      Sheet? sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) throw Exception("Sheet not found!");

      // Debug: Print first two rows
      for (var row in sheet.rows.take(2)) {
        print(row.map((cell) => cell?.value).toList());
      }

      // Get current month in lowercase
      String currentMonth = DateFormat.MMM().format(DateTime.now()).toLowerCase();
      print("Current month: $currentMonth");

      // Find column index
      int monthIndex = sheet.rows.first.indexWhere(
              (cell) => cell?.value.toString().trim().toLowerCase() == currentMonth
      );

      if (monthIndex == -1) throw Exception("Current month data not found!");

      // Fetch average rainfall
      double avgRainfall = sheet.rows[1][monthIndex]?.value != null
          ? double.tryParse(sheet.rows[1][monthIndex]!.value.toString()) ?? 0.0
          : 0.0;

      print("Fetched Rainfall Data: $avgRainfall mm");
      return avgRainfall;
    } catch (e) {
      print("Error reading Excel file: $e");
      throw Exception("Failed to fetch rainfall data for $district");
    }
  }
}