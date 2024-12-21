import 'package:orion/screens/homeComponents/analytics.dart';
import 'package:orion/screens/homeComponents/chats.dart';
import 'package:orion/screens/homeComponents/profile.dart';
import 'package:orion/screens/homeComponents/todo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/welcome.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFirstLaunch = true;

  late AnimationController _animationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _navbarSlideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = [
    ChatsScreen(),
    TodoScreen(), // Changed to make Todo come before Analytics
    AnalyticsScreen(), // Changed to make Analytics come after Todo
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _navbarSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: InkSplash.splashFactory,
        splashColor: const Color.fromARGB(71, 182, 40, 8),
        highlightColor: const Color.fromARGB(57, 183, 13, 13),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 10, 19, 42),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 10, 19, 42),
          elevation: 0,
          title: _isFirstLaunch
              ? FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: _buildAppBarTitle(),
                )
              : _buildAppBarTitle(),
          actions: [
            FadeTransition(
              opacity:
                  _titleFadeAnimation, // Apply the same animation as the title
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  setState(() {
                    _isFirstLaunch = true;
                  });

                  // Start the animation reversal for smooth transition
                  await _animationController.reverse();

                  try {
                    // Firebase logout
                    await FirebaseAuth.instance.signOut();

                    // Clear cached user details from SharedPreferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('name');
                    await prefs.remove('email');
                    await prefs.remove('phoneNumber');
                    await prefs.remove('profileImageUrl');
                    await prefs.remove('bio');
                    // Show Snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logged out successfully")),
                    );

                    // Navigate to the WelcomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => WelcomeScreen()),
                    );
                  } catch (e) {
                    // Handle any errors during logout
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error logging out. Please try again.")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        body: _isFirstLaunch
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: _pages[_currentIndex],
              )
            : _pages[_currentIndex],
        bottomNavigationBar: SlideTransition(
          position: _isFirstLaunch
              ? _navbarSlideAnimation
              : AlwaysStoppedAnimation(Offset(0, 0)),
          child: BottomNavigationBar(
            backgroundColor: Color.fromARGB(255, 10, 19, 42),
            selectedItemColor: const Color.fromARGB(255, 87, 196, 196),
            unselectedItemColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _isFirstLaunch = false;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 0
                      ? Icons.blur_circular_rounded
                      : Icons.blur_on,
                ),
                label: "Chats",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 1
                      ? Icons.check_box_rounded
                      : Icons.check_box_outlined, // Todo
                ),
                label: "To-Do", // Changed label position
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 2
                      ? Icons.analytics
                      : Icons.analytics_outlined, // Analytics
                ),
                label: "Analytics", // Changed label position
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _currentIndex == 3
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        const SizedBox(width: 10),
        LoadingAnimationWidget.beat(
          color: const Color.fromARGB(255, 61, 118, 175),
          size: 29.0,
        ),
        const SizedBox(width: 20),
        const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Text(
            "Orion",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
