import 'package:flutter/material.dart';

class TestInfoScreen extends StatefulWidget {
  @override
  _TestInfoScreenState createState() => _TestInfoScreenState();
}

class _TestInfoScreenState extends State<TestInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController landAreaController = TextEditingController();
  int sampleCount = 1; // Default test sample count

  // Districts list
  final List<String> districts = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam', 'Idukki',
    'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasargod'
  ];

  // Observatories mapped to districts
  final Map<String, List<String>> observatories = {
    'Thiruvananthapuram': ['Neyyattinkara', 'Thiruvananthapur AP (OBSY)', 'Thiruvananthapur (OBSY)', 'Varkala'],
    'Kollam': ['Aryankavu', 'Kollam (RLY)', 'Punalur (OBSY)'],
    'Pathanamthitta': ['Konni', 'Kurudamannil'],
    'Alappuzha': ['Alappuzha', 'Cherthala', 'Haripad', 'Kayamkulam (Agro)', 'Kayamkulam (RARS)', 'Mancompu', 'Mavelikara'],
    'Kottayam': ['Kanjirappally', 'Kottayam (RRII) (OBSY)', 'Kozha', 'Kumarakom', 'Vaikom'],
    'Idukki': ['Idukki', 'Munnar (KSEB)', 'Myladumpara Agri', 'Peermade(TO)', 'Thodupuzha'],
    'Ernakulam': ['Alwaye PWD', 'CIAL Kochi (OBSY)', 'Ernakulam', 'NAS Kochi (OBSY)', 'Perumpavur', 'Piravam'],
    'Thrissur': ['Chalakudi', 'Enamakal', 'Irinjalakuda', 'Kodungallur', 'Kunnamkulam', 'Vadakkancherry', 'Vellanikkarai (OBSY)'],
    'Palakkad': ['Alathur (Hydro)', 'Chittur', 'Kollengode', 'Mannarkad', 'Ottapalam', 'Palakkad (OBSY)', 'Parambikulam', 'Pattambi (Agro)', 'Trithala'],
    'Malappuram': ['Angadipuram', 'Karipur AP (OBSY)', 'Manjeri', 'Nilambur', 'Perinthalamanna', 'Ponnani'],
    'Kozhikode': ['Kozhikode (OBSY)', 'Quilandi', 'Vadakara'],
    'Wayanad': ['Ambalavayal', 'Kuppadi', 'Mananthavady', 'Vythiri'],
    'Kannur': ['Irikkur', 'Kannur (OBSY)', 'Mahe', 'Taliparamba', 'Thalasserry'],
    'Kasargod': ['Hosdurg', 'Kudulu']
  };

  String? selectedDistrict;
  String? selectedObservatory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFD9FFD2), // Light green background
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter the test details to improve the accuracy of prediction.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                /// **Land Area Input**
                _buildTextField(landAreaController, 'Land Area (in acres or hectares)'),

                /// **District Selection**
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Select District'),
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
                      selectedObservatory = null; // Reset observatory selection
                    });
                  },
                  validator: (value) => value == null ? 'Please select a district' : null,
                ),

                /// **Observatory Selection**
                if (selectedDistrict != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Observatory'),
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

                /// **Test Samples Counter**
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Number of Test Samples:', style: TextStyle(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (sampleCount > 1) {
                              setState(() {
                                sampleCount--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                        Text(sampleCount.toString(), style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              sampleCount++;
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// **Submit Button**
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushNamed(
                          context,
                          '/inputScreen',
                          arguments: {
                            'landArea': landAreaController.text,
                            'district': selectedDistrict,
                            'observatory': selectedObservatory,
                            'samples': sampleCount,
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    ),
                    child: const Text('Proceed', style: TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Reusable Input Field Widget**
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a value' : null,
    );
  }

  /// **Reusable Input Decoration**
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}
