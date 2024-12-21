import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart'; // Import the chat screen to navigate to the specific group
import 'package:firebase_auth/firebase_auth.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> _joinedGroups = []; // List to store group info (id and name)

  @override
  void initState() {
    super.initState();
    _loadJoinedGroups();
  }

  // Fetch current user ID (UID) from FirebaseAuth
  Future<String?> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      return user.uid; // Return the userId (UID)
    } else {
      print('No user is currently logged in');
      return null;
    }
  }

  // Load the joined groups from Firestore
  void _loadJoinedGroups() async {
    try {
      final userId = await _getCurrentUserId(); // Await the userId

      if (userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // Use the dynamic userId
            .get();

        // Check if user has any joined groups
        if (snapshot.exists && snapshot.data()?['joined_groups'] != null) {
          final joinedGroupIds = List<String>.from(snapshot.data()!['joined_groups']);

          List<Map<String, dynamic>> groups = [];
          for (var groupId in joinedGroupIds) {
            final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();

            if (groupDoc.exists) {
              final groupName = groupDoc['groupName']; // Fetch the group name from the group document

              groups.add({
                'groupId': groupId,
                'groupName': groupName,
              });
            } else {
              print("Group not found for id: $groupId");
            }
          }

          setState(() {
            _joinedGroups = groups; // List of group info (id and name)
          });
        } else {
          setState(() {
            _joinedGroups = [];
          });
        }
      } else {
        print('No user ID available');
      }
    } catch (e) {
      print("Error loading groups: $e");
    }
  }

  // Create a new group with a dialog to enter a group name and generate a 6-digit code
  void _createGroup() async {
    String groupName = '';
    String groupCode = DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6); // Create a 6-digit code

    // Show dialog to ask for the group name
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Group'),
          content: TextField(
            onChanged: (value) {
              groupName = value;
            },
            decoration: InputDecoration(hintText: 'Enter Group Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (groupName.isNotEmpty) {
                  // Create the group in Firestore
                  final groupRef = FirebaseFirestore.instance.collection('groups').doc();
                  await groupRef.set({
                    'groupId': groupRef.id,
                    'groupName': groupName,
                    'groupCode': groupCode,
                    'createdAt': Timestamp.now(),
                  });

                  // Fetch the current userId and save the group to the user's joined groups
                  final userId = await _getCurrentUserId();
                  if (userId != null) {
                    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
                    await userRef.update({
                      'joined_groups': FieldValue.arrayUnion([groupRef.id]), // Add groupId to joined_groups list
                    });
                  }

                  // Navigate to the ChatScreen with the newly created group
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(groupId: groupRef.id),
                    ),
                  );
                } else {
                  // Show error if the group name is empty
                  Navigator.pop(context);
                  _showErrorDialog('Please enter a valid group name');
                }
              },
              child: Text('Create'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to join an existing group by entering a code
  void _joinGroup() async {
    // Show dialog to prompt for the 6-digit group code
    String groupCode = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Group Code'),
          content: TextField(
            onChanged: (value) {
              groupCode = value;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: '6-digit code'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Check if the group exists
                final groupSnapshot = await FirebaseFirestore.instance
                    .collection('groups')
                    .where('groupCode', isEqualTo: groupCode)
                    .limit(1)
                    .get();

                if (groupSnapshot.docs.isNotEmpty) {
                  // Join the group if it exists
                  final groupId = groupSnapshot.docs.first.id;

                  // Fetch the current userId and add to the user's joined groups
                  final userId = await _getCurrentUserId();
                  if (userId != null) {
                    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
                    await userRef.update({
                      'joined_groups': FieldValue.arrayUnion([groupId]), // Add groupId to joined_groups list
                    });
                  }

                  // Navigate to the ChatScreen with the joined group
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(groupId: groupId),
                    ),
                  );
                } else {
                  // Show error if the group code is invalid
                  Navigator.pop(context);
                  _showErrorDialog('Invalid Group Code');
                }
              },
              child: Text('Join'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groups'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: _joinedGroups.length, // Only show joined groups
        itemBuilder: (context, index) {
          final group = _joinedGroups[index];

          // Display the joined group with the group name
          return ListTile(
            title: Text(group['groupName'] ?? 'No Group Name'),
            subtitle: Text('Joined Group'),
            onTap: () {
              // Navigate to the ChatScreen for the selected group
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(groupId: group['groupId']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup, // Create a new group when the button is pressed
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _joinGroup, // Join an existing group when the button is pressed
          child: Text('Join Existing Group'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
