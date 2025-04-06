import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Adjust speed
    )..repeat(reverse: true);

    _backgroundColor = ColorTween(
      begin: Colors.black,
      end: Colors.green[900],
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      maxScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/bg.json', // Ensure this file exists
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 750), // Start from bottom
                  const Text(
                    "SEED - The Smart Agriculture",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text("Developers", style: TextStyle(fontSize: 22, color: Colors.white)),
                  const SizedBox(height: 20),
                  _creditSection("Aby Pious Vinoy"),
                  _creditSection("Ashwin Joseph"),
                  _creditSection("Athira Vijayan"),
                  _creditSection("Sreeraj K"),
                  const SizedBox(height: 30),
                  const Text("Guide", style: TextStyle(fontSize: 22, color: Colors.white)),
                  const SizedBox(height: 20),
                  _creditSection("Pillai Praveen Thulasidharan"),
                  const SizedBox(height: 30),
                  const Text(
                    "Thank You for Using SEED!\nEmpowering Farmers",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _creditSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
        ],
      ),
    );
  }
}
