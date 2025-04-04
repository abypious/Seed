import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;

  late String _name;
  late String _email;
  late String _photoUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();

    _name = user?.displayName ?? "User";
    _email = user?.email ?? "No Email";
    _photoUrl = user?.photoURL ?? "assets/images/profile.png"; // Default image

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeInAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture with Border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: _photoUrl.startsWith("http")
                            ? NetworkImage(_photoUrl)
                            : AssetImage(_photoUrl) as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // User Name
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    // User Email
                    Text(
                      _email,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),

                    const SizedBox(height: 20),

                    // Profile Details Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _profileInfoTile(Icons.person, "Full Name", _name),
                            _profileInfoTile(Icons.email, "Email", _email),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Edit Profile Button
                    ElevatedButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white70)),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: _name);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text("Edit Profile"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await user?.updateDisplayName(nameController.text);
                setState(() {
                  _name = nameController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
