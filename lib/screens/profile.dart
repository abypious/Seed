import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _name = "John Doe";
  String _email = "johndoe@example.com";
  String _bio = "Mobile Developer | Tech Enthusiast";

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: _name);
        TextEditingController emailController = TextEditingController(text: _email);
        TextEditingController bioController = TextEditingController(text: _bio);

        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: bioController, decoration: const InputDecoration(labelText: "Bio")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                  _email = emailController.text;
                  _bio = bioController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/profile.png"), // Replace with actual image
            ),
            const SizedBox(height: 12),

            // Name
            Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            // Email
            Text(_email, style: const TextStyle(fontSize: 16, color: Colors.grey)),

            // Bio
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(_bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            ),

            const SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
