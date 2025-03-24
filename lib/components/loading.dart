import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/loading.json', // Replace with your Lottie animation
                width: 150,
                height: 150,
                repeat: true,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.pop(context); // Close the loading dialog
  }
}
