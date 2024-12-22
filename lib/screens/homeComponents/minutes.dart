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
    // Assuming widget.data contains the raw summary text
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Meeting Summary
                          Text(
                            'Meeting Summary:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Project Planning & Technology Stack Discussion',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          // Attendees
                          Text(
                            'Attendees:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Orion, Apollo Blaze, alna',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          // Key Discussion Points
                          Text(
                            'Key Discussion Points:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '* Gemini model integration into the application.\n'
                            '* Implementing a basic chat application using various technologies.\n'
                            '* Utilizing Firestore for database and FireAuth for authorization.\n'
                            '* Building the application using Flutter.\n'
                            '* Brainstorming additional features (resource generation, project guidance, to-do list).\n'
                            '* Identifying necessary resources (tutorials, documentation, video tutorials).\n'
                            '* Addressing concerns about catching up and Flutter expertise.\n'
                            '* Setting a goal of starting project implementation at HFT today.',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          // Decisions Made
                          Text(
                            'Decisions Made:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Apollo Blaze decided to begin implementing the project today at HFT.\n'
                            'Orion agreed to provide resources for integrating the Gemini model.',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          // Action Items
                          Text(
                            'Action Items:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Apollo Blaze: Check tutorials on FireAuth, gather resources regarding Flutter and video tutorials, integrate after getting data from Gemini.',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),
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
