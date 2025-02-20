import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
        "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=5"));

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
                height: 350,
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Weather Info",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: const Icon(Icons.add, color: Colors.black),
                            value: null,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
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
                      ],
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Map<String, dynamic>>(
                      future: fetchWeather(selectedCity),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: Colors.green));
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Failed to load weather"));
                        } else {
                          final weatherData = snapshot.data!;
                          final temperature = weatherData['current']['temp_c'];
                          final weatherCondition = weatherData['current']['condition']['text'];
                          final cityName = weatherData['location']['name'];
                          final forecastDays = weatherData['forecast']['forecastday'];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(cityName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text("🌡 Temperature: $temperature°C", style: const TextStyle(fontSize: 16)),
                              Text("☁ Condition: $weatherCondition", style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 15),
                              const Text("3-Day Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: forecastDays.length,
                                  itemBuilder: (context, index) {
                                    final day = forecastDays[index];
                                    final date = DateFormat('EEE, MMM d').format(DateTime.parse(day['date']));
                                    final temp = day['day']['avgtemp_c'];
                                    final condition = day['day']['condition']['text'];
                                    final icon = day['day']['condition']['icon'];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Image.network("https:$icon", width: 40, height: 40),
                                          Text("$temp°C", style: const TextStyle(fontSize: 16)),
                                          Text(condition, style: const TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      },
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
