import 'dart:typed_data';
import 'package:flutter/material.dart'; // Required for ChangeNotifier
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteModel extends ChangeNotifier {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // List of crop names corresponding to the 30 crops in your model
  final List<String> cropNames = [
    "Tomato", "Watermelon", "Tapioca", "Sweet Potato", "Sunflower",
    "Sugarcane", "Spinach", "Soybean", "Rice", "Pumpkin",
    "Peanut", "Okra", "Mustard Greens", "Muskmelon", "MungBeans",
    "Maize", "Lentil", "KidneyBeans", "Ginger", "Garlic",
    "Elephant Foot Yam", "Cucumber", "Cotton", "Colocasia", "Chilli",
    "Cauliflower", "Carrot", "Cabbage", "Brinjal", "Banana"
  ];

  // Load TFLite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ensemble_model.tflite');
      _isModelLoaded = true;  // Set flag to true after loading
      notifyListeners();
    } catch (e) {
      print("Error loading model: $e");
      throw 'Failed to load model';
    }
  }

  // Check if model is loaded
  bool get isModelLoaded => _isModelLoaded;

  // Make predictions
  Future<List<Map<String, dynamic>>> predict(List<double> inputs) async {
    if (!_isModelLoaded) throw 'Model not loaded';

    // Prepare input tensor (1x7 shape, assuming 7 input parameters)
    var inputTensor = Float32List.fromList(inputs).reshape([1, 7]);

    // Prepare output tensor (30 elements for 30 crops)
    var outputTensor = List.filled(30, 0.0).reshape([1, 30]);

    try {
      _interpreter!.run(inputTensor, outputTensor);

      // Get the top 3 predictions by sorting the output tensor
      List<Map<String, dynamic>> predictions = [];
      var sortedIndexes = List.generate(30, (index) => index)
        ..sort((a, b) => outputTensor[0][b].compareTo(outputTensor[0][a]));

      // Add the top 3 predictions to the list
      for (int i = 0; i < 3; i++) {
        predictions.add({
          'crop': cropNames[sortedIndexes[i]], // Crop name
          'confidence': outputTensor[0][sortedIndexes[i]].toStringAsFixed(2) // Confidence percentage
        });
      }

      return predictions;
    } catch (e) {
      print("Error making prediction: $e");
      throw 'Prediction failed';
    }
  }

  // Close the interpreter
  void close() {
    _interpreter?.close();
    notifyListeners();
  }
}
