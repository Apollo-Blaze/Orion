import 'dart:async';
import 'dart:convert'; // Import to handle JSON parsing
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orion/components/loader.dart';
import 'package:orion/screens/homeComponents/chatComponent/GeminiHandler.dart';
import 'package:orion/screens/homeComponents/chatComponent/reference.dart';
import 'package:orion/screens/homeComponents/minutes.dart';
import 'package:orion/services/dateTime.dart';
import 'package:orion/services/firebase_utils.dart';
import 'package:orion/services/gem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Import to handle URL launching

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
  String? _email;
  String? _groupName;
  String? _groupCode; // Store the groupCode here
  bool _hasGeneratedResponse = false;
  String? _geminiResponse;

  Future<void> showDateTimeSelectionDialog(
      BuildContext context, String groupId) async {
    DateTime? fromDateTime;
    DateTime? toDateTime;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        title: Text(
          "Select Date and Time",
          style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // From Date and Time Picker
            Row(children: [
              Text(
                "From:",
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  fromDateTime = await showDateTimePicker(context, null, null);
                },
                child: Text(
                  "Select Start Date & Time",
                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ]),
            // To Date and Time Picker
            Row(children: [
              Text(
                "To:",
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  toDateTime = await showDateTimePicker(context, null, null);
                },
                child: Text(
                  "Select End Date & Time",
                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ]),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        backgroundColor:
            Color.fromARGB(255, 20, 6, 43), // Dark purple background
        actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actions: [
          TextButton(
            onPressed: () async {
              if (fromDateTime != null && toDateTime != null) {
                String messages =
                    await getDiyaMessagess(fromDateTime, toDateTime, groupId);
                print("just after messages");
                String data = await generateDiyaChatSummary(messages);
                print("just after getting data form gemini");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MinutesScreen(data: data),
                  ),
                );
              }
              // Navigator.of(context).pop();
            },
            child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(color: const Color.fromARGB(224, 231, 45, 45)),
            ),
          ),
          ),
            Text(
              "Next",
              style:
                  TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
            ),
          
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Load username when the screen is initialized
    _loadGroupName(); // Load group name and code from Firestore
  }

  void _loadUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User'; // Retrieve stored name
      _email = prefs.getString('email'); // Store email
    });
  }

  void _loadGroupName() async {
    final groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
    final doc = await groupRef.get();
    if (doc.exists) {
      setState(() {
        _groupName = doc['groupName']; // Assuming groupCode is used as the name
        _groupCode = doc['groupCode']; // Load groupCode from Firestore
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

  Future<void> _sendMessage(String message) async {
    if (widget.groupId.isEmpty || message.isEmpty) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('name') ?? 'User';

    final chatRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages');

    // Add message to Firestore
    await chatRef.add({
      'message': message,
      'sentAt': Timestamp.now(),
      'sender': userName,
      'email': _email
    });

    // Clear the text field
    _messageController.clear();
    String? geminiResponse;

    // Send message to Gemini and handle response
    try {
      geminiResponse = await GeminiHandler.getResponse(message);
    } catch (e) {
      print("Error fetching response: $e");
      geminiResponse = null;
    }
    print("This is the response: $geminiResponse");

    if (geminiResponse != null) {
      setState(() {
        _hasGeneratedResponse = true;
        _geminiResponse = geminiResponse;
      });

      // Parse response as JSON if it's a valid JSON string
      try {
        Map<String, dynamic> jsonResponse = jsonDecode(geminiResponse);
        String summary = jsonResponse['summary'] ?? '';
        String urls = jsonResponse['url'] ?? '';

        // Save response to Firestore in `references` collection
        final referencesRef = FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('references');

        await referencesRef.add({
          'summary': summary,
          'urls': urls,
          'createdAt': Timestamp.now(),
        });

        // Set a timer to hide the notification icon after 10 seconds
        Timer(Duration(seconds: 10), () {
          setState(() {
            _hasGeneratedResponse = false;
          });
        });
      } catch (e) {
        print("Error parsing response to JSON: $e");
      }
    } else {
      setState(() {
        _hasGeneratedResponse = false;
      });
      print("No response received");
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _email == "orion@gmail.com"
        ? Colors.red
        : const Color.fromARGB(255, 3, 11, 30); // Default background color

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      _groupName != null ? _groupName![0].toUpperCase() : '',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  children: [
                    Text(
                      _groupName ?? 'Group Chat',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_groupCode != null)
                      Text(
                        _groupCode!,
                        style: TextStyle(
                          color: const Color.fromARGB(250, 124, 47, 191),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(250, 124, 47, 191)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.article,
                color: const Color.fromARGB(250, 124, 47, 191)),
            onPressed: () {
              showDateTimeSelectionDialog(context, widget.groupId);
            },
          ),
          IconButton(
            icon: Icon(Icons.auto_fix_high,
                color: const Color.fromARGB(250, 124, 47, 191)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ReferencesScreen(groupId: widget.groupId)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_hasGeneratedResponse)
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Center(
                child: SpinKitPulsingGrid(
          color: const Color.fromARGB(255, 225, 185, 84), // Change to your desired color
          size: 25,        // Adjust the size of the grid
        ),
              ),
            ),
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
                    final email = messages[index]['email'];
                    final sentAt =
                        (messages[index]['sentAt'] as Timestamp).toDate();

                    final isCurrentUser = email == _email;
                    final isOrion = email == 'orion@orion.com';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
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
                              if (!isCurrentUser && !isOrion)
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blueAccent,
                                  child: Text(
                                    sender[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isOrion
                                        ? const Color.fromARGB(
                                            255, 12, 162, 147)
                                        : isCurrentUser
                                            ? const Color.fromARGB(
                                                255, 220, 220, 220)
                                            : const Color.fromARGB(
                                                255, 35, 6, 82),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  constraints: BoxConstraints(
                                    maxWidth: isOrion
                                        ? (MediaQuery.of(context).size.width *
                                            0.9)
                                        : (MediaQuery.of(context).size.width *
                                            0.6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!isOrion)
                                        Text(
                                          sender,
                                          style: TextStyle(
                                            color: isCurrentUser
                                                ? const Color.fromARGB(
                                                    255, 35, 6, 82)
                                                : const Color.fromARGB(
                                                    255, 220, 220, 220),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      isOrion && message.contains("http")
                                          ? Align(
                                              alignment: Alignment
                                                  .center, // Center align the RichText widget
                                              child: RichText(
                                                textAlign: TextAlign
                                                    .left, // Center-align the text content
                                                text: TextSpan(
                                                  children: [
                                                    // Non-link part of the message
                                                    TextSpan(
                                                      text: message
                                                              .split('http')[
                                                          0], // Text before the link
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 221, 221, 221),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    // Link part of the message
                                                    TextSpan(
                                                      text: "http" +
                                                          message.split('http')[
                                                              1], // The link part
                                                      style: TextStyle(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 110, 33, 243),
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = () =>
                                                            _launchURL("http" +
                                                                message.split(
                                                                    'http')[1]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Text(
                                              message,
                                              style: TextStyle(
                                                color: isCurrentUser
                                                    ? const Color.fromARGB(
                                                        255, 35, 6, 82)
                                                    : const Color.fromARGB(
                                                        255, 220, 220, 220),
                                                fontSize: 16,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${sentAt.hour}:${sentAt.minute < 10 ? '0${sentAt.minute}' : sentAt.minute}',
                            style: const TextStyle(
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
                  icon: Icon(
                    Icons.send,
                    color: const Color.fromARGB(255, 81, 18, 123),
                  ),
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
