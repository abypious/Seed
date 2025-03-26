import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:seed/components/colors.dart';

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
        "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=5&aqi=no&alerts=no"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// **Background Image**
          FutureBuilder<Map<String, dynamic>>(
            future: fetchWeather(selectedCity),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              } else if (snapshot.hasError) {
                return const Center(child: Text("Failed to load weather"));
              } else {
                final weatherData = snapshot.data!;
                final isDay = weatherData['current']['is_day'] == 1; // ✅ Check if it's day
                final backgroundImage = isDay
                    ? "assets/weather/clear.jpg"   // 🌞 Day Background
                    : "assets/weather/night.jpg"; // 🌙 Night Background

                return Stack(
                  children: [
                    /// **Dynamic Background Image**
                    Positioned.fill(
                      child: Image.asset(
                        backgroundImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// **Dark Overlay for Better Readability**
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1), // Top (More Transparent)
                            Colors.black.withOpacity(0.5), // Middle (Semi-Transparent)
                            Colors.black.withOpacity(0.7), // Bottom (Less Transparent)
                          ],
                        ),
                      ),
                    ),

                    /// **Weather Content Goes Here**
                  ],
                );
              }
            },
          ),


          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1), // Top (More Transparent)
                  Colors.black.withOpacity(0.5), // Middle (Semi-Transparent)
                  Colors.black.withOpacity(0.8), // Bottom (Less Transparent)
                ],
              ),
            ),
          ),

          /// **Weather Content**
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
                final weatherCondition =
                weatherData['current']['condition']['text'];
                final forecastDays = weatherData['forecast']['forecastday'];
                final hourlyForecast = forecastDays[0]['hour']; // Get hourly data

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align Left
                    children: [
                      /// **Tap to Change City**
                      GestureDetector(
                        onTap: () async {
                          String? newCity = await showMenu<String>(
                            context: context,
                            position: const RelativeRect.fromLTRB(20, 80, 100, 100),
                            items: cities.map((String city) {
                              return PopupMenuItem<String>(
                                value: city,
                                child: Text(
                                  city,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          );

                          if (newCity != null) {
                            setState(() {
                              selectedCity = newCity;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.secondary, size: 24),
                            const SizedBox(width: 5),
                            Text(
                              selectedCity,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// **Temperature & Condition**
                      Text(
                        "${temperature.round()}°C", // Rounds the temperature
                        style: const TextStyle(
                            fontSize: 60,
                            color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          weatherCondition,
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 50),

                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: forecastDays.length,
                          itemBuilder: (context, index) {
                            final day = forecastDays[index];
                            final date = DateFormat('EEE, d').format(DateTime.parse(day['date']));
                            final minTemp = day['day']['mintemp_c'].round(); // ✅ Rounded Temp
                            final maxTemp = day['day']['maxtemp_c'].round(); // ✅ Rounded Temp
                            final iconUrl = "https:${day['day']['condition']['icon']}"; // ✅ Extract Icon URL

                            return Container(
                              width: 105,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(iconUrl, width: 40, height: 40), // ✅ API Icon
                                  const SizedBox(height: 5),
                                  Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 5),
                                  Text("$minTemp°- $maxTemp°", style: const TextStyle(fontSize: 14)), // ✅ Rounded Temp
                                ],
                              ),
                            );
                          },
                        ),
                      ),



                      const SizedBox(height: 50),

                      /// **24-Hour Forecast**
                      const Text("24-Hour Forecast",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 24,
                          itemBuilder: (context, index) {
                            final hourData = hourlyForecast[index];
                            final time = DateFormat('h a').format(
                                DateTime.parse(hourData['time']));
                            final temp = hourData['temp_c'];
                            final icon = hourData['condition']['icon'];

                            return Container(
                              width: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(time,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(height: 5),
                                  Image.network("https:$icon",
                                      width: 40, height: 40),
                                  const SizedBox(height: 5),
                                  Text("${temp.round()}°C",
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
