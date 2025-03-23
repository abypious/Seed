import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class AtlasMap extends StatefulWidget {
  const AtlasMap({super.key});

  @override
  State<AtlasMap> createState() => AtlasMapState();
}



class AtlasMapState extends State<AtlasMap> {
  District? currentDistrict;
  String? currentRainfall;
  List<District> districts = [];

  @override
  void initState() {
    super.initState();
    loadDistricts();

  }

  Future<void> loadDistricts() async {
    try {
      districts = await loadSvgImage(svgImage: 'assets/atlas/map-cropped.svg');
      if (districts.isEmpty) {
        print("No valid districts found in SVG file!");
      }
      setState(() {});
    } catch (e) {
      print("Error loading SVG: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  maxScale: 3,
                  minScale: 1.0,
                  constrained: true,
                  child: SizedBox(
                    width: size.width < 1200 ? 1200 : size.width - 200,
                    height: size.height < 800 ? 800 : size.height - 200,
                    child: Stack(
                      children: districts.map((district) {
                        return Stack(
                          children: [
                            _getBorder(district: district),
                            _getClippedImage(
                              clipper: DistrictPathClipper(svgPath: district.path),
                              color: currentDistrict?.id == district.id ? Colors.green : const Color(0xFFD7D3D2),
                              district: district,
                              onDistrictSelected: onDistrictSelected,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildLegendBox(),
        ],
      ),
    );
  }

  void onDistrictSelected(District district) {
    setState(() {
      currentDistrict = district;
      currentRainfall = "Fetching...";
    });
    getWeatherData(district.id);
  }


  Widget _buildLegendBox() {
    if (currentDistrict == null) {
      return const SizedBox();
    }

    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${capitalizeFirstLetter(currentDistrict!.id)}\n",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 5),
            Text(
              "Top Crops: ${getTopCrops(currentDistrict!.id)}",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "Soil Type: ${getSoilType(currentDistrict!.id)}",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "Rainfall: ${currentRainfall ?? 'Loading...'}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }



  String getTopCrops(String district) {
    Map<String, String> cropData = {
      "Thiruvananthapuram": "Coconut, Paddy, Rubber",
      "kollam": "Cashew, Coconut, Banana",
      "Pathanamthitta": "Rubber, Pepper, Cocoa",
      "alappuzha": "Paddy, Coconut, Banana",
      "kottayam": "Rubber, Pepper, Cocoa",
      "idukki": "Tea, Coffee, Cardamom",
      "ernakulam": "Paddy, Coconut, Pepper",
      "thrissur": "Coconut, Paddy, Banana",
      "palakkad": "Paddy, Coconut, Banana",
      "malappuram": "Paddy, Coconut, Arecanut",
      "Kozhikode": "Coconut, Banana, Pepper",
      "wayanad": "Coffee, Tea, Pepper",
      "kannur": "Coconut, Cashew, Arecanut",
      "kasaragod": "Coconut, Arecanut, Rubber",
    };

    return cropData[district] ?? "Data not available";
  }

  String getSoilType(String district) {
    Map<String, String> cropData = {
      "Thiruvananthapuram": "Laterite Soil",
      "kollam": "Laterite Soil",
      "Pathanamthitta": "Laterite Soil",
      "alappuzha": "Alluvial Soil",
      "kottayam": "Laterite Soil",
      "idukki": "Forest Soil",
      "ernakulam": "Laterite Soil",
      "thrissur": "Laterite Soil",
      "palakkad": "Alluvial Soil, Black Soil",
      "malappuram": "Laterite Soil",
      "Kozhikode": "Laterite Soil",
      "wayanad": "Forest Soil",
      "kannur": "Laterite Soil",
      "kasaragod": "Laterite Soil",
    };

    return cropData[district] ?? "Data not available";
  }

  Future<void> getWeatherData(String district) async {
    String apiKey = "ede05a6991004763b9074142252101";
    final response = await http.get(Uri.parse(
        "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$district&days=1"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        currentRainfall = "${data['forecast']['forecastday'][0]['day']['totalprecip_mm']} mm";
      });
    } else {
      setState(() {
        currentRainfall = "Rainfall data unavailable";
      });
    }
  }




  Widget _getBorder({required District district}) {
    final path = parseSvgPathData(district.path);
    return CustomPaint(painter: DistrictBorderPainter(path: path));
  }

  Widget _getClippedImage({
    required DistrictPathClipper clipper,
    required Color color,
    required District district,
    required Function(District district) onDistrictSelected,
  }) {
    bool isSelected = currentDistrict?.id == district.id;

    return ClipPath(
      clipper: clipper,
      child: GestureDetector(
        onTap: () => onDistrictSelected(district),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          color: isSelected ? Colors.green : const Color(0xFFD7D3D2),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isSelected ? 1.08 : 1.0,
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.9,
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

Future<List<District>> loadSvgImage({required String svgImage}) async {
  List<District> maps = [];
  try {
    String svgContent = await rootBundle.loadString(svgImage);
    XmlDocument document = XmlDocument.parse(svgContent);
    final paths = document.findAllElements('path');

    for (var element in paths) {
      String? partId = element.getAttribute('id');
      String? partPath = element.getAttribute('d');

      if (partId == null || partPath == null || partId == 'Outline') {
        continue;
      }

      maps.add(District(id: partId, path: partPath));
    }
  } catch (e) {
    print("Error parsing SVG: $e");
  }
  return maps;
}

class District {
  final String id;
  final String path;
  District({required this.id, required this.path});
}

class DistrictPathClipper extends CustomClipper<Path> {
  final String svgPath;

  DistrictPathClipper({required this.svgPath});

  @override
  Path getClip(Size size) {
    try {
      var path = parseSvgPathData(svgPath);
      final Matrix4 matrix = Matrix4.identity()
        ..translate(-840.0, 700.0)
        ..scale(1.0, -1.0);
      return path.transform(matrix.storage);
    } catch (e) {
      print("Error clipping path: $e");
      return Path();
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DistrictBorderPainter extends CustomPainter {
  final Path path;
  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = Colors.black;

  DistrictBorderPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    final Matrix4 matrix = Matrix4.identity()
      ..translate(-840.0, 700.0)
      ..scale(1.0, -1.0);
    canvas.drawPath(path.transform(matrix.storage), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
