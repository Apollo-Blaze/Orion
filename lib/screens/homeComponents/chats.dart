import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart'; // Import the chat screen to navigate to the specific group
import 'package:firebase_auth/firebase_auth.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _joinedGroups = []; // List to store group info (id and name)
  List<Map<String, dynamic>> _filteredGroups = []; // List to store filtered groups based on search query

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();

    // Fetch the current groups and initialize the filtered list
    _loadJoinedGroups();

    // Add listener for search input changes
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
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

        if (snapshot.exists && snapshot.data()?['joined_groups'] != null) {
          final joinedGroupIds =
              List<String>.from(snapshot.data()!['joined_groups']);

          List<Map<String, dynamic>> groups = [];
          for (var groupId in joinedGroupIds) {
            final groupDoc = await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId)
                .get();

            if (groupDoc.exists) {
              final groupName = groupDoc['groupName'];
              groups.add({
                'groupId': groupId,
                'groupName': groupName,
              });
            } else {
              print("Group not found for id: $groupId");
            }
          }

          setState(() {
            _joinedGroups = groups;
            _filteredGroups = groups; // Initially show all groups
          });
        } else {
          setState(() {
            _joinedGroups = [];
            _filteredGroups = [];
          });
        }
      } else {
        print('No user ID available');
      }
    } catch (e) {
      print("Error loading groups: $e");
    }
  }

  // Filter groups based on the search query
  void _filterGroups() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGroups = _joinedGroups
          .where((group) =>
              group['groupName']?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  // Create a new group with a dialog to enter a group name and generate a 6-digit code
  void _createGroup() async {
    String groupName = '';
    String groupCode = DateTime.now()
        .millisecondsSinceEpoch
        .toString()
        .substring(0, 6); // Create a 6-digit code

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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (groupName.isNotEmpty) {
                  final groupRef =
                      FirebaseFirestore.instance.collection('groups').doc();
                  await groupRef.set({
                    'groupId': groupRef.id,
                    'groupName': groupName,
                    'groupCode': groupCode,
                    'createdAt': Timestamp.now(),
                  });

                  final userId = await _getCurrentUserId();
                  if (userId != null) {
                    final userRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId);
                    await userRef.update({
                      'joined_groups': FieldValue.arrayUnion([groupRef.id]),
                    });
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(groupId: groupRef.id),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  _showErrorDialog('Please enter a valid group name');
                }
              },
              child: Text('Create'),
            ),

          ],
        );
      },
    );
  }

  // Join an existing group by entering a group code
  void _joinGroup() async {
    String groupCode = ''; // Prompt the user to enter a group code

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Join Existing Group'),
          content: TextField(
            onChanged: (value) {
              groupCode = value;
            },
            decoration: InputDecoration(hintText: 'Enter Group Code'),
          ),
          actions: <Widget>[
                        TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (groupCode.isNotEmpty) {
                  // Check if the group with the entered code exists
                  final groupQuery = await FirebaseFirestore.instance
                      .collection('groups')
                      .where('groupCode', isEqualTo: groupCode)
                      .limit(1)
                      .get();

                  if (groupQuery.docs.isNotEmpty) {
                    final groupId = groupQuery.docs.first.id;
                    final groupName = groupQuery.docs.first['groupName'];

                    // Add the user to the group
                    final userId = await _getCurrentUserId();
                    if (userId != null) {
                      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
                      await userRef.update({
                        'joined_groups': FieldValue.arrayUnion([groupId]),
                      });

                      // Navigate to the chat screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(groupId: groupId),
                        ),
                      );
                    }
                  } else {
                    _showErrorDialog('Group not found or invalid code');
                  }
                } else {
                  Navigator.pop(context);
                  _showErrorDialog('Please enter a valid group code');
                }
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog
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
                Navigator.pop(context);
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
      backgroundColor: Color.fromARGB(255, 10, 19, 42),
      body: Stack(
        children: [
          // Main content (search bar, group list)
          Column(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search groups',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Color.fromARGB(113, 63, 63, 63),
                      prefixIcon: _focusNode.hasFocus
                          ? IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                _focusNode.unfocus();
                                _searchController.clear();
                              },
                            )
                          : Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onTap: () {
                      _focusNode.requestFocus();
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = _filteredGroups[index];
                    return ListTile(
                      title: Text(
                        group['groupName'] ?? 'No Group Name',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      subtitle: Text(
                        'Joined Group',
                        style: TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(groupId: group['groupId']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Positioned buttons (Create and Join)
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: const Color.fromARGB(255, 46, 232, 245),
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: _createGroup,
                  ),
                ),
                SizedBox(height: 8.0),
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: const Color.fromARGB(255, 120, 220, 62),
                  child: IconButton(
                    icon: Icon(Icons.group_add, color: Colors.white),
                    onPressed: _joinGroup,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
