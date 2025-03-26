import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  late String _name;
  late String _email;
  late String _photoUrl;

  @override
  void initState() {
    super.initState();
    _name = user?.displayName ?? "User";
    _email = user?.email ?? "No Email";
    _photoUrl = user?.photoURL ?? "assets/images/profile.png"; // Default image
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: _name);

        return AlertDialog(
          title: const Text("Edit Profile"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await user?.updateDisplayName(nameController.text);
                setState(() {
                  _name = nameController.text;
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers everything vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Centers everything horizontally
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundImage: _photoUrl.startsWith("http")
                    ? NetworkImage(_photoUrl)
                    : AssetImage(_photoUrl) as ImageProvider,
              ),
              const SizedBox(height: 12),

              // Name
              Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              // Email
              Text(_email, style: const TextStyle(fontSize: 16, color: Colors.grey)),

              const SizedBox(height: 20),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
