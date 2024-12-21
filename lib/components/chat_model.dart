import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String text;
  final Timestamp timestamp;

  Message({required this.senderId, required this.senderName, required this.text, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      senderName: map['senderName'],
      text: map['text'],
      timestamp: map['timestamp'],
    );
  }
}
