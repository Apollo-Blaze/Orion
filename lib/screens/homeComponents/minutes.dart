import 'package:flutter/material.dart';

class MinutesScreen extends StatefulWidget {
  final String data;
  const MinutesScreen({super.key, required this.data});

  @override
  State<MinutesScreen> createState() => _MinutesScreenState();
}

class _MinutesScreenState extends State<MinutesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minutes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade800,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          // Ensure the container takes the full screen height
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade900,
                Colors.purple.shade600,
                Colors.deepPurpleAccent.shade200,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white.withOpacity(0.9),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            widget.data,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
