import 'package:flutter/material.dart';
import 'package:seed/screens/auth/verification.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _pinCodeController = TextEditingController();

  String? selectedDistrict;
  String? selectedObservatory;

  final List<String> districts = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam', 'Idukki',
    'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram', 'Kozhikode', 'Wayanad', 'Kannur', 'Kasargod'
  ];

  Map<String, List<String>> observatories = {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,)),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.man, color: Colors.green),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your name';
                        } else if ((value?.length ?? 0) < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pinCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Pin Code',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin, color: Colors.green),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your pin code';
                        } else if ((value?.length ?? 0) != 6) {
                          return 'Pin code must be exactly 6 digits';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'Select District',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city, color: Colors.green),
                      ),
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
                    if (selectedDistrict != null)
                      const SizedBox(height: 16),
                    if (selectedDistrict != null)
                      DropdownButtonFormField<String>(
                        value: selectedObservatory,
                        decoration: const InputDecoration(
                          labelText: 'Select Observatory',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home_work_rounded, color: Colors.green),
                        ),
                        items: observatories[selectedDistrict]!.map((observatory) {
                          return DropdownMenuItem<String>(
                            value: observatory,
                            child: Text(observatory),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedObservatory = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select an observatory' : null,
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          elevation: 5,
                        ),
                        label: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        icon: const Icon(Icons.navigate_next, size: 22, color: Colors.white),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerificationScreen(
                                  name: _nameController.text,
                                  pinCode: _pinCodeController.text,
                                  district: selectedDistrict ?? '',
                                  observatory: selectedObservatory ?? '',
                                ),
                              ),
                            );
                          }
                        },
                      ),
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
}
