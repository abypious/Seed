import 'package:flutter/material.dart';

// CustomButton Widget
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  // Constructor with parameters for label, onPressed function, background color, and text color
  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.green, // Default background color
    this.textColor = Colors.white, // Default text color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // Set the background color of the button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Optional: Rounded corners
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Button padding
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor, // Set the text color
          fontSize: 16, // Font size
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
    );
  }
}
