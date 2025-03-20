import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;

class AtlasMap extends StatefulWidget {
  const AtlasMap({super.key});

  @override
  _AtlasMapState createState() => _AtlasMapState();
}

class _AtlasMapState extends State<AtlasMap> {
  String selectedDistrict = "";
  String svgData = "";

  // District bounding boxes (Manually estimated)
  final Map<String, Rect> districtBounds = {
    "path11533": Rect.fromLTWH(100, 200, 80, 100), // Kozhikode
    "path11534": Rect.fromLTWH(120, 400, 70, 90), // Thiruvananthapuram
    "path11535": Rect.fromLTWH(200, 250, 90, 110), // Ernakulam
  };

  final Map<String, String> districtMap = {
    "path11533": "Kozhikode",
    "path11534": "Thiruvananthapuram",
    "path11535": "Ernakulam",
    "path11536": "Kollam",
    "path11537": "Alappuzha",
    "path11538": "Pathanamthitta",
    "path11539": "Kottayam",
    "path11540": "Idukki",
    "path11541": "Thrissur",
    "path11542": "Palakkad",
    "path11543": "Malappuram",
    "path11544": "Wayanad",
    "path11545": "Kannur",
    "path11546": "Kasaragod",
  };

  @override
  void initState() {
    super.initState();
    _loadSVG();
  }

  Future<void> _loadSVG() async {
    String rawSvg = await rootBundle.loadString('assets/atlas/KeralaMapNew.svg');
    setState(() {
      svgData = rawSvg;
    });
  }

  void _onTapUp(TapUpDetails details) {
    Offset position = details.localPosition;

    // Check if tap is within any district's bounding box
    for (var entry in districtBounds.entries) {
      if (entry.value.contains(position)) {
        String tappedPathId = entry.key;
        if (districtMap.containsKey(tappedPathId)) {
          _onDistrictTap(districtMap[tappedPathId]!);
          return;
        }
      }
    }
  }

  void _onDistrictTap(String districtName) {
    setState(() {
      selectedDistrict = districtName;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(districtName),
        content: Text("More details about $districtName."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Kerala Map')),
      body: GestureDetector(
        onTapUp: _onTapUp,
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(50),
          minScale: 1.0,
          maxScale: 5.0, // Allows zoom up to 5x
          child: Center(
            child: svgData.isEmpty
                ? const CircularProgressIndicator()
                : SvgPicture.string(
              svgData,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      floatingActionButton: selectedDistrict.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => _onDistrictTap(selectedDistrict),
        label: Text(selectedDistrict),
        icon: const Icon(Icons.location_on),
        backgroundColor: Colors.green,
      )
          : null,
    );
  }
}
