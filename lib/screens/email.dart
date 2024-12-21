import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orion/screens/home.dart';
import 'package:lottie/lottie.dart';

class EmailVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 19, 42),
      body: Center( // Center the entire body
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
              children: [
                Lottie.asset(
                  'assets/email.json', // Try different path variations
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  // Add error handling
                  errorBuilder: (context, error, stackTrace) {
                    print("Lottie load error: $error");
                    return Text('Failed to load animation');
                  },
                ),

                Text(
                  'A verification link has been sent to your email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 50),
                // Using the GIF from assets
                  
                ElevatedButton(
                  onPressed: () async {
                    // Check if the user has verified their email
                    User? user = FirebaseAuth.instance.currentUser;
                    await user?.reload();
                    if (user?.emailVerified ?? false) {
                      // If email is verified, navigate to the home screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else {
                      // If not, show a message to try again
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please verify your email to continue.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6200EA), // Elegant dark purple
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Check Email Verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
