import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'dashboard.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7de26d),
      ),
      drawer: Drawer( // Sidebar menu
        child: Container(color: Colors.green,
          child: ListView(
            padding: EdgeInsets.only(left: 20.0,right: 20.0),
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(

                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // Add logout functionality
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF7de26d),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/images/on.png',
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                )
              ),

              const SizedBox(height: 70),
              const Text(
                'Welcome to Seed App!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Smart Farming Starts Here.!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      "Dashboard",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
