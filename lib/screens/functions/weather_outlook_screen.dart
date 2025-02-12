import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class WeatherOutlookScreen extends StatefulWidget {
  const WeatherOutlookScreen({super.key});

  @override
  _WeatherOutlookScreenState createState() => _WeatherOutlookScreenState();
}

class _WeatherOutlookScreenState extends State<WeatherOutlookScreen> {
  final String apiKey = "ede05a6991004763b9074142252101";

  final List<String> cities = [
    'Thiruvananthapuram', 'Kollam', 'Pathanamthitta', 'Alappuzha', 'Kottayam',
    'Idukki', 'Ernakulam', 'Thrissur', 'Palakkad', 'Malappuram',
    'Kozhikode', 'Kalpatta', 'Kannur', 'Kasargod'
  ];
  String selectedCity = "Thiruvananthapuram";

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http.get(Uri.parse(
        "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),


            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              color: Colors.green[100],
              child: Container(
                width: double.infinity,
                height: 230,
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Weather Info",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight
                              .bold),
                        ),
                        DropdownButtonHideUnderline(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ),
                            child: DropdownButton<String>(
                              icon: const Icon(Icons.add, color: Colors.black),
                              value: null,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                              items: cities.map((String city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: (String? newCity) {
                                if (newCity != null) {
                                  setState(() {
                                    selectedCity = newCity;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: fetchWeather(selectedCity),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState
                              .waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                ));
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text("Failed to load weather"));
                          } else {
                            final weatherData = snapshot.data!;
                            final temperature = weatherData['current']['temp_c'];
                            final weatherCondition = weatherData['current']['condition']['text'];
                            final cityName = weatherData['location']['name'];

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(cityName, style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text("🌡 Temperature: $temperature°C",
                                    style: const TextStyle(fontSize: 16)),
                                Text("☁ Condition: $weatherCondition",
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}