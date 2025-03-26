import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:seed/screens/dashboard.dart';
import 'package:seed/screens/auth/signup.dart';
import 'package:seed/screens/auth/change_email.dart';
import 'package:seed/screens/auth/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _obscurePassword = true;

  // Save email to SharedPreferences
  Future<void> _saveEmailToPrefs(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // Sign in with Email & Password
  Future<void> _signInWithEmail() async {
    setState(() => _isLoadingEmail = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      print('User signed in: ${userCredential.user?.uid}');
      if (userCredential.user != null && mounted) {
        await _saveEmailToPrefs(userCredential.user!.email!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    } catch (e) {
      print('Login Error: $e'); // Debugging line
      _showSnackbar('Failed to sign in: ${e.toString()}'); // Show error details
    } finally {
      if (mounted) setState(() => _isLoadingEmail = false);
    }
  }

  // Sign in with Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoadingGoogle = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoadingGoogle = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _saveEmailToPrefs(userCredential.user!.email!); // Save email to preferences
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    } catch (e) {
      _showSnackbar("Google Sign-In failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text('Welcome Back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Sign In Button
              _isLoadingEmail
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 5,
                  ),
                  icon: const Icon(Icons.email, size: 22, color: Colors.white),
                  label: const Text('Sign In with Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _signInWithEmail,
                ),
              ),
              const SizedBox(height: 30),

              // Google Sign-In Button
              _isLoadingGoogle
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Colors.grey)),
                  ),
                  icon: Image.asset('assets/images/google_logo.png', height: 24),
                  label: const Text('Sign in with Google', style: TextStyle(fontSize: 16)),
                  onPressed: _signInWithGoogle,
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen())),
                    child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                ],
              ),

              // Forgot Password & Change Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen())),
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w300)),
                  ),
                  const Text(" | ", style: TextStyle(fontSize: 12, color: Colors.black)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeEmailScreen())),
                    child: const Text('Change Email', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w300)),
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
