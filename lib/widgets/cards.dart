import 'package:flutter/material.dart';

// Custom Card Widget to display the project features with Hover Effects
class FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Function onTap;

  FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  _FeatureCardState createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;  // To track hover state

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;  // On hover, set to true
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;  // On exit, set to false
        });
      },
      child: GestureDetector(
        onTap: () => widget.onTap(),
        child: Card(
          margin: EdgeInsets.all(10),
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: _isHovered ? Colors.green.shade600 : Colors.green.shade500, // Hover effect on card color
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_isHovered ? Colors.green.shade500 : Colors.green.shade300, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered ? Colors.black45 : Colors.transparent,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Icon(widget.icon, color: Colors.white, size: 40),
                title: Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,  // Added letter spacing
                  ),
                ),
                subtitle: Text(
                  widget.description,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
