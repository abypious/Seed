import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_time') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEED App',
      home: isFirstTime ? OnboardingScreen() : HomeScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Analyze Your Soil",
      "desc": "Get the best crop suggestions based on your soil type."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Smart Farming",
      "desc": "Use AI to improve yield and reduce waste."
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Start Your Journey",
      "desc": "Login now and make farming smarter!"
    },
  ];

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView (Behind the dots)
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              return Container(
                color: const Color(0xff7de26d),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20), // Space for dots at the top
                    Image.asset(onboardingData[index]['image']!, height: 250),
                    const SizedBox(height: 20),
                    Text(
                      onboardingData[index]['title']!,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        onboardingData[index]['desc']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (index == onboardingData.length - 1)
                      ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // Dots Indicator (Fixed at the Top)
          Positioned(
            top: 60, // Adjust as needed
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (dotIndex) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == dotIndex ? Colors.white : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomSheet: _currentPage != onboardingData.length - 1
          ? Container(
        color: Color(0xff7de26d),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _completeOnboarding,
              child: Text("Skip", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward, size: 28, color: Colors.grey[700],),
              onPressed: () {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
            ),
          ],
        ),
      )
          : null,
    );
  }
}
