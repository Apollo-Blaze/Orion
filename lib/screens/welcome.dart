import 'package:flutter/material.dart';
import '../components/loader.dart';
import 'login.dart'; // Import LoginScreen
import 'signup.dart'; // Import SignupScreen

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500), // Total duration adjusted for delays
    );

    // Create staggered animations for fade and slide
    _fadeAnimations = List.generate(3, (index) {
      double delay = index == 2 ? 0.3 : 0.2; // Add a 300ms delay for the buttons
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(index * 0.2 + delay, 1.0, curve: Curves.easeIn),
      );
    });

    _slideAnimations = List.generate(3, (index) {
      double delay = index == 2 ? 0.3 : 0.2; // Add a 300ms delay for the buttons
      return Tween<Offset>(
        begin: Offset(0, 0.5),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2 + delay, 1, curve: Curves.easeOut),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 17, 34, 54),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // The custom loader (no animation)
            CustomLoader(size: 150.0),

            SizedBox(height: 20), // Spacing

            // App Name
            FadeTransition(
              opacity: _fadeAnimations[0],
              child: SlideTransition(
                position: _slideAnimations[0],
                child: Text(
                  "Welcome to Orion,",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 10), // Spacing

            // App Description
            FadeTransition(
              opacity: _fadeAnimations[1],
              child: SlideTransition(
                position: _slideAnimations[1],
                child: Text(
                  "Guiding You at Every Decision.",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 202, 202, 202),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 60), // Spacing

            // Buttons Row
            FadeTransition(
              opacity: _fadeAnimations[2],
              child: SlideTransition(
                position: _slideAnimations[2],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Login Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Fade and slide transition
                              var begin = Offset(1.0, 0.0); // Start from the right
                              var end = Offset.zero; // End at the current position
                              var curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: animation, child: child));
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 40, 102, 165),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 244, 244, 244), fontWeight: FontWeight.w900),
                      ),
                    ),

                    SizedBox(width: 20), // Space between buttons

                    // Signup Button
                    // Signup Button
                    OutlinedButton(
                      onPressed: () {
                        // Navigate to signup with a custom transition
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => SignupScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Slide from right with fade transition
                              var begin = Offset(1.0, 0.0); // Start from the right
                              var end = Offset.zero; // End at the current position
                              var curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: animation, child: child));
                            },
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: BorderSide(color: const Color.fromARGB(255, 244, 244, 244), width: 2),
                      ),
                      child: Text(
                        "SignUp",
                        style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 244, 244, 244)),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
