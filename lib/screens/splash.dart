import 'package:orion/components/loader.dart';
import 'package:orion/components/loader2.dart';
import 'package:orion/screens/home.dart'; // Import your Home screen
import 'package:orion/screens/welcome.dart'; // Import your Welcome (Login/Signup) screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Check if the user is already logged in
    User? user = auth.currentUser;

    // Wait for the current frame to finish before navigating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        // If logged in, replace splash with Home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // If not logged in, replace splash with Welcome screen
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 6, 20),
      body: Center(
        child: CustomLoader(size: 150.0), // Custom loader widget
      ),
    );
  }
}

