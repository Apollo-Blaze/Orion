import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;

  ChatScreen({required this.groupId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  ScrollController _scrollController = ScrollController();
  String _userName = 'User'; // Default name
  String? _groupName;

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Load username when the screen is initialized
    _loadGroupName(); // Load group name from Firestore
  }

  void _loadUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User'; // Retrieve stored name
    });
  }

  void _loadGroupName() async {
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
    final doc = await groupRef.get();
    if (doc.exists) {
      setState(() {
        _groupName = doc['groupName']; // Assuming groupCode is used as the name
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) async {
    if (widget.groupId.isEmpty || message.isEmpty) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('name') ?? 'User'; // Retrieve stored name

    final chatRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages');

    await chatRef.add({
      'message': message,
      'sentAt': Timestamp.now(),
      'sender': userName, // Use the stored user name here
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 19, 42),
      appBar: AppBar(
        title: Text(_groupName ?? 'Group Chat'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('sentAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text(
                      'No messages yet. Join or create a group.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index]['message'];
                    final sender = messages[index]['sender'];
                    final sentAt = (messages[index]['sentAt'] as Timestamp).toDate();
                    final isCurrentUser = sender == _userName;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: isCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isCurrentUser)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blueAccent,
                                  child: Text(
                                    sender[0].toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? const Color.fromARGB(255, 220, 220, 220)
                                      : const Color.fromARGB(255, 35, 6, 82),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(18)
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sender,
                                      style: TextStyle(
                                        color: isCurrentUser
                                            ? const Color.fromARGB(255, 23, 2, 57)
                                            : const Color.fromARGB(255, 220, 220, 220),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      message,
                                      style: TextStyle(
                                        color: isCurrentUser
                                            ? const Color.fromARGB(255, 23, 2, 57)
                                            : const Color.fromARGB(255, 220, 220, 220),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${sentAt.hour}:${sentAt.minute < 10 ? '0${sentAt.minute}' : sentAt.minute}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color.fromARGB(113, 63, 63, 63),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
