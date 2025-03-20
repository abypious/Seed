import 'package:flutter/material.dart';
import 'ExcelService.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _landSizeController = TextEditingController();
  final TextEditingController _testSamplesController = TextEditingController();

  String? selectedDistrict;
  String? selectedObservatory;
  double? rainfall;

  final List<String> districts = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam', 'Idukki',
    'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasargod'
  ];

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

  void _fetchRainfallData() async {
    if (selectedDistrict == null || selectedObservatory == null) {
      return;
    }

    double? avgRainfall = await ExcelService.getRainfallAverage(selectedDistrict!, selectedObservatory!);
    setState(() {
      rainfall = avgRainfall;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Input Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _landSizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter land size (in acres)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedDistrict,
              hint: const Text('Select District'),
              items: districts.map((district) {
                return DropdownMenuItem(
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
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedObservatory,
              hint: const Text('Select Observatory'),
              items: (selectedDistrict != null)
                  ? observatories[selectedDistrict!]!.map((obs) {
                return DropdownMenuItem(
                  value: obs,
                  child: Text(obs),
                );
              }).toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  selectedObservatory = value;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _testSamplesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of test samples',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _fetchRainfallData,
              child: const Text('Get Rainfall Data'),
            ),
            const SizedBox(height: 20),

            if (rainfall != null)
              Text(
                'Average Rainfall for this month: ${rainfall!.toStringAsFixed(2)} mm',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
