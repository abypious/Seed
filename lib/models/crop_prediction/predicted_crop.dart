import 'package:flutter/material.dart';
import 'package:seed/components/colors.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class PredictedCropScreen extends StatefulWidget {
  final Map<String, double> inputValues;

  const PredictedCropScreen({Key? key, required this.inputValues}) : super(key: key);

  @override
  _PredictedCropScreenState createState() => _PredictedCropScreenState();
}

class _PredictedCropScreenState extends State<PredictedCropScreen> {
  late tfl.Interpreter _interpreter;
  List<Map<String, dynamic>> _predictions = [];

  final Map<String, String> cropDescriptions = {
    "banana": "Banana is a tropical fruit rich in potassium and vitamins.",
    "brinjal": "Brinjal, also known as eggplant, is a versatile vegetable used in many cuisines.",
    "cabbage": "Cabbage is a leafy green vegetable that is great for salads and stir-fries.",
    "carrot": "Carrots are rich in beta-carotene, which is good for vision.",
    "cauliflower": "Cauliflower is a cruciferous vegetable known for its high fiber and vitamin C content.",
    "chilli": "Chilli peppers add spice to dishes and contain capsaicin for health benefits.",
    "colocasia": "Colocasia, or taro root, is a starchy vegetable commonly used in Indian and Asian dishes.",
    "cotton": "Cotton is a fiber-producing crop essential for textile manufacturing worldwide.",
    "cucumber": "Cucumber is a refreshing vegetable with high water content, perfect for hydration.",
    "elephant-foot-yam": "Elephant foot yam is a root vegetable rich in fiber and often used in curries.",
    "garlic": "Garlic is a pungent spice known for its medicinal properties and strong flavor.",
    "ginger": "Ginger is a root spice used in cooking and traditional medicine for its digestive benefits.",
    "kidney-beans": "Kidney beans are a protein-rich legume widely used in Indian and Mexican cuisine.",
    "ladyfinger": "Ladyfinger, also known as okra, is a green vegetable rich in fiber and vitamins.",
    "lentil": "Lentils are small, protein-packed legumes commonly used in soups and stews.",
    "maize": "Maize, or corn, is a staple crop used for food, fodder, and industrial purposes.",
    "mung-beans": "Mung beans are a protein-rich legume used in curries and sprouts.",
    "musk-melon": "Musk melon is a sweet and juicy fruit, ideal for summer hydration.",
    "mustard-beans": "Mustard beans are used for their seeds and leaves, known for their pungent taste.",
    "peanut": "Peanuts are protein-rich nuts often consumed as snacks or used for oil extraction.",
    "pumkin": "Pumpkin is a nutrient-dense vegetable rich in beta-carotene and fiber.",
    "rice": "Rice is a staple grain consumed worldwide and is a primary source of carbohydrates.",
    "soybean": "Soybeans are a high-protein legume used for food, oil, and animal feed.",
    "spinach": "Spinach is a leafy green rich in iron, calcium, and vitamins.",
    "sugarcane": "Sugarcane is a cash crop used for producing sugar and ethanol.",
    "sunflower": "Sunflowers are grown for their oil-rich seeds and bright yellow flowers.",
    "sweet-potato": "Sweet potatoes are a nutritious tuber rich in fiber and antioxidants.",
    "tapioca": "Tapioca is a starch extracted from cassava roots, used in puddings and snacks.",
    "tomato": "Tomatoes are a versatile fruit used in sauces, salads, and cooking.",
    "watermelon": "Watermelon is a hydrating fruit with high water content and refreshing sweetness."
  };


  final List<String> cropLabels = [
    "banana", "brinjal", "cabbage", "carrot", "cauliflower", "chilli", "colocasia",
    "cotton", "cucumber", "elephant-foot-yam", "garlic", "ginger", "kidney-beans",
    "ladyfinger", "lentil", "maize", "mung-beans", "musk-melon", "mustard-beans",
    "peanut", "pumkin", "rice", "soybean", "spinach", "sugarcane", "sunflower",
    "sweet-potato", "tapioca", "tomato", "watermelon"
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset("assets/crop_predict/ensemble_model.tflite");
      _predictCrop();
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  void _predictCrop() async {
    List<double> input = [
      widget.inputValues["Nitrogen"]!,
      widget.inputValues["Phosphorus"]!,
      widget.inputValues["Potassium"]!,
      widget.inputValues["pH Level"]!,
      widget.inputValues["Temperature"]!,
      widget.inputValues["Moisture"]!,
      widget.inputValues["Rainfall"]!
    ];

    var output = List.filled(30, 0.0).reshape([1, 30]);
    _interpreter.run([input], output);

    List<double> probabilities = output[0];
    List<Map<String, dynamic>> sortedPredictions = List.generate(30, (index) => {
      "crop": cropLabels[index],
      "probability": probabilities[index]
    }).toList();

    sortedPredictions.sort((a, b) => b["probability"].compareTo(a["probability"]));
    setState(() {
      _predictions = sortedPredictions.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Predicted Crops',
          style: TextStyle(color: Colors.black,fontSize: 21),
        ),
        backgroundColor:AppColors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Top 3 Recommended Crops',
              style: TextStyle(fontSize: 20, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            ..._predictions.map((prediction) => _buildCropCard(prediction)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> prediction) {
    String cropName = prediction["crop"];
    String imagePath = 'assets/crop_predict/crop_images/${cropName.toLowerCase().replaceAll(" ", "-")}.jpg';

    return GestureDetector(
      onTap: () => _showCropDetails(cropName),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Image not found: $imagePath');
                    return const Icon(Icons.image, size: 80, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName.toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${(prediction["probability"] * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 20, color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCropDetails(String cropName) {
    String description = cropDescriptions[cropName] ?? "No description available.";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 10,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                height: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cropName.toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
