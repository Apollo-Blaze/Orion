import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add your navigation or functionality here
                print('Button Pressed');
              },
              child: Text('Get Started'),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.task),
                    title: Text('Task 1'),
                    subtitle: Text('Details about Task 1'),
                    onTap: () {
                      // Handle Task 1 tap
                      print('Task 1 selected');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.task),
                    title: Text('Task 2'),
                    subtitle: Text('Details about Task 2'),
                    onTap: () {
                      // Handle Task 2 tap
                      print('Task 2 selected');
                    },
                  ),
                  // Add more ListTiles as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
