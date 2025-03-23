import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_screen.dart';

class TestInfoScreen extends StatefulWidget {
  @override
  _TestInfoScreenState createState() => _TestInfoScreenState();
}

class _TestInfoScreenState extends State<TestInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController landAreaController = TextEditingController();
  int sampleCount = 4; // Default sample count

  final List<String> districts = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam', 'Idukki',
    'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasargod'
  ];

  // Observatories mapped to districts
  final Map<String, List<String>> observatories = {
    'Thiruvananthapuram': ['Neyyattinkara', 'Thiruvananthapur AP (OBSY)', 'Thiruvananthapur (OBSY)', 'Varkala'],
    'Kollam': ['Aryankavu', 'Kollam (RLY)', 'Punalur (OBSY)'],
    'Pathanamthitta': ['Konni', 'Kurudamannil'],
    'Alappuzha': ['Alappuzha', 'Cherthala', 'Haripad'],
    'Kottayam': ['Kanjirappally', 'Kottayam (RRII) (OBSY)', 'Kozha'],
    'Idukki': ['Idukki', 'Munnar (KSEB)', 'Peermade(TO)'],
    'Ernakulam': ['Alwaye PWD', 'CIAL Kochi (OBSY)', 'Ernakulam'],
    'Thrissur': ['Chalakudi', 'Irinjalakuda', 'Kodungallur'],
    'Palakkad': ['Alathur (Hydro)', 'Chittur', 'Kollengode'],
    'Malappuram': ['Angadipuram', 'Karipur AP (OBSY)', 'Manjeri'],
    'Kozhikode': ['Kozhikode (OBSY)', 'Quilandi', 'Vadakara'],
    'Wayanad': ['Ambalavayal', 'Kuppadi', 'Mananthavady'],
    'Kannur': ['Irikkur', 'Kannur (OBSY)', 'Taliparamba'],
    'Kasargod': ['Hosdurg', 'Kudulu']
  };

  String? selectedDistrict;
  String? selectedObservatory;
  String rainfallData = "No data available";
  int minSamples = 4; // Default min samples based on land area

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      landAreaController.text = prefs.getString('landArea') ?? '';
      selectedDistrict = prefs.getString('selectedDistrict');
      selectedObservatory = prefs.getString('selectedObservatory');
      sampleCount = prefs.getInt('sampleCount') ?? 4;
    });
  }

  // Save user input to SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('landArea', landAreaController.text);
    await prefs.setString('selectedDistrict', selectedDistrict ?? '');
    await prefs.setString('selectedObservatory', selectedObservatory ?? '');
    await prefs.setInt('sampleCount', sampleCount);
  }


  // Determine min samples based on land area
  void _updateSampleRequirement() {
    double? landArea = double.tryParse(landAreaController.text);
    if (landArea == null || landArea <= 0) {
      minSamples = 4;
    } else if (landArea <= 1) {
      minSamples = 4;
    } else if (landArea <= 3) {
      minSamples = 6;
    } else {
      minSamples = 8;
    }

    setState(() {
      sampleCount = sampleCount < minSamples ? minSamples : sampleCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFD9FFD2),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter test details to improve prediction accuracy.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: landAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Land Area (in acres)',
                    prefixIcon: Icon(Icons.landscape),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateSampleRequirement(),
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Select District', Icons.location_city),
                  value: selectedDistrict,
                  items: districts.map((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedObservatory = null;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a district' : null,
                ),

                if (selectedDistrict != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Observatory', Icons.location_on),
                    value: selectedObservatory,
                    items: observatories[selectedDistrict!]!.map((obs) {
                      return DropdownMenuItem<String>(
                        value: obs,
                        child: Text(obs),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedObservatory = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select an observatory' : null,
                  ),
                ],

                if (selectedObservatory != null) ...[
                  const SizedBox(height: 16),
                  Text(rainfallData, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],

                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of Test Samples (Min: $minSamples)',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: sampleCount.toDouble(),
                      min: minSamples.toDouble(),
                      max: 10,
                      divisions: 10 - minSamples,
                      label: sampleCount.toString(),
                      onChanged: (value) {
                        setState(() {
                          sampleCount = value.toInt();
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveData();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InputScreen(
                              landArea: double.tryParse(landAreaController.text) ?? 0.0,
                              district: selectedDistrict!,
                              observatory: selectedObservatory!,
                              samples: sampleCount,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Proceed', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }
}
