import 'package:orion/components/auth.dart';
import 'package:orion/components/loader2.dart';
import 'package:orion/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for retrieving user data
import '../components/loader.dart'; // Import CustomLoader
import 'signup.dart'; // Import SignupScreen
import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500), // Total duration adjusted for delays
    );

    // Create staggered animations for fade and slide
    _fadeAnimations = List.generate(5, (index) {
      double delay = index == 3 || index == 4 ? 0.4 : 0.2; // Added more delay for buttons (index 3, 4)
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(index * 0.1 + delay, 1.0, curve: Curves.easeIn),
      );
    });

    _slideAnimations = List.generate(5, (index) {
      double delay = index == 3 || index == 4 ? 0.4 : 0.2; // Added more delay for buttons (index 3, 4)
      return Tween<Offset>(
        begin: Offset(0, 0.5),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1 + delay, 1, curve: Curves.easeOut),
        ),
      );
    });

    _controller.forward(); // Start the animations
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      _isEmailValid = _emailController.text.isNotEmpty;
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    // Navigate to Loading Screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoadingScreen()),
    );

    try {
      // Firebase authentication for login
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Get user details from Firebase Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          // Get user data from Firestore
          final userData = userDoc.data() as Map<String, dynamic>;

          // Save user information locally using SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true); // Store login status
          await prefs.setString('email', email); // Store email
          await prefs.setString('name', userData['name'] ?? 'No Name'); // Store name
          await prefs.setString('phoneNumber', userData['phoneNumber'] ?? 'No Phone'); // Store phone number
          await prefs.setString('profileImageUrl', userData['profileImageUrl'] ?? ''); // Store profile image URL

          // Navigate to HomeScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false, // Remove all previous routes
          );
        } else {
          // Handle case where user data doesn't exist
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User data not found.")),
          );
        }
      }
    } catch (e) {
      // Handle any errors during Firebase authentication
      Navigator.pop(context); // Close loading screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to login. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 12, 13, 33), // Black background
      body: SingleChildScrollView(
        // Make the screen scrollable
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              // The custom loader (no animation)
              CustomLoader(size: 150.0),

              SizedBox(height: 20), // Spacing

              // Title
              FadeTransition(
                opacity: _fadeAnimations[0],
                child: SlideTransition(
                  position: _slideAnimations[0],
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: 10), // Spacing

              // Description
              FadeTransition(
                opacity: _fadeAnimations[1],
                child: SlideTransition(
                  position: _slideAnimations[1],
                  child: Text(
                    "Manage your projects with ease.",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 202, 202, 202),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: 60), // Spacing

              // Email input
              FadeTransition(
                opacity: _fadeAnimations[2],
                child: SlideTransition(
                  position: _slideAnimations[2],
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    onChanged: (_) => _validateEmail(),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isEmailValid ? Colors.white : Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20), // Spacing

              // Password input
              FadeTransition(
                opacity: _fadeAnimations[2],
                child: SlideTransition(
                  position: _slideAnimations[2],
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    onChanged: (_) => _validatePassword(),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _isPasswordValid ? Colors.white : Colors.red,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40), // Spacing

              // Login Button with added transition delay
              FadeTransition(
                opacity: _fadeAnimations[3],
                child: SlideTransition(
                  position: _slideAnimations[3],
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 40, 102, 165),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 244, 244, 244),
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20), // Spacing

              // Signup Button without border with added transition delay
              FadeTransition(
                opacity: _fadeAnimations[4],
                child: SlideTransition(
                  position: _slideAnimations[4],
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to signup
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: BorderSide.none, // Remove the border for signup
                    ),
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 244, 244, 244)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}