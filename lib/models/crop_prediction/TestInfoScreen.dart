import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'input_screen.dart';
import 'package:seed/components/colors.dart';

class TestInfoScreen extends StatefulWidget {
  @override
  _TestInfoScreenState createState() => _TestInfoScreenState();
}

class _TestInfoScreenState extends State<TestInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController landAreaController = TextEditingController();
  int sampleCount = 4; // Default sample count

  final List<String> districts = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta','Alappuzha', 'Kottayam', 'Idukki','Ernakulam',
    'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasargod'
  ];

// Observatories mapped to districts
  final Map<String, List<String>> observatories = {
    'Thiruvananthapuram': ['Neyyattinkara', 'Thiruvananthapuram AP', 'Thiruvananthapuram', 'Varkala'],
    'Kollam': ['Aryankavu', 'Kollam', 'Punalur'],
    'Pathanamthitta': ['Konni', 'Kurudamannil'],
    'Alappuzha': ['Alappuzha (OBSY)', 'Cherthala', 'Haripad', 'Kayamkulam (AGRO)', 'Kayamkulam (RARS)', 'Mancompu', 'Mavelikara'],
    'Kottayam': ['Kanjirappally', 'Kottayam', 'Kozha', 'Kumarakom', 'Vaikom'],
    'Idukki': ['Idukki', 'Munnar', 'Myladumpara Agri', 'Peermade', 'Thodupuzha'],
    'Ernakulam': ['Alwaye PWD', 'NAS Kochi (OBSY)', 'Perumbavoor', 'Piravam', 'Ernakulam'],
    'Thrissur': ['Chalakudi', 'Enamakkal', 'Irinjalakuda', 'Kodungallur', 'Kunnakulam', 'Vadakkancherry', 'Vellanikkara'],
    'Palakkad': ['Alathur', 'Chittur', 'Kollengode', 'Mannarkad', 'Ottapalam', 'Palakkad', 'Parambikulam', 'Pattambi', 'Trithala'],
    'Malappuram': ['Angadipuram', 'Karipur', 'Manjeri', 'Nilambur', 'Perinthalmanna', 'Ponnani'],
    'Kozhikode': ['Kozhikode', 'Quilandi', 'Vadakara'],
    'Wayanad': ['Ambalavayil', 'Kuppadi', 'Mananthavady', 'Vythiri'],
    'Kannur': ['Irikkur', 'Kannur', 'Mahe', 'Taliparamba', 'Thalassery'],
    'Kasargod': ['Hosdurg', 'Kudulu'],
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter details to improve accuracy.',
                  style: TextStyle(fontSize: 16, color:  AppColors.black),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: landAreaController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Land Area (in acres)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateSampleRequirement(),
                ),


                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Select District'),
                  value: selectedDistrict,
                    dropdownColor: AppColors.white,
                    iconEnabledColor: AppColors.black,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
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
                    decoration: _inputDecoration('Select Observatory'),
                    value: selectedObservatory,
                      dropdownColor: AppColors.white,
                      iconEnabledColor: AppColors.black,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
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
                    const SizedBox(height: 20),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 15,
                        activeTrackColor:AppColors.secondary,
                        inactiveTrackColor: Colors.grey,
                        thumbColor: AppColors.primary,
                        valueIndicatorColor: AppColors.primary,
                        valueIndicatorTextStyle: const TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text('Next Step'),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

}
