import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getMessagess(
    DateTime? fromTime, DateTime? toTime, String gpId) async {
  // Initialize an empty list to store messages

  List<String> messages = [];

  try {
    if (fromTime == null || toTime == null) {
      throw ArgumentError("fromTime and toTime cannot be null");
    }
    Timestamp totimestamp = Timestamp.fromDate(toTime);
    Timestamp fromtimestamp = Timestamp.fromDate(fromTime);
    print(fromtimestamp);
    print(totimestamp);
    // Access the top-level collection group
    CollectionReference collectionGroup =
        FirebaseFirestore.instance.collection('groups');
    print("collectio");

    // Iterate through the documents in the collection group
    QuerySnapshot groupSnapshot = await collectionGroup.get();

    for (var groupDoc in groupSnapshot.docs) {
      print("enter first loop");
      // Access the specific document and its tomessages collection
      if (groupDoc.id == gpId) {
        print("entered first if");
        CollectionReference tomessages =
            groupDoc.reference.collection('messages');

        // Query documents in the tomessages collection
        QuerySnapshot messagesSnapshot = await tomessages.get();

        for (var messageDoc in messagesSnapshot.docs) {
          print("entered");
          // Check if sentitime matches the condition
          Timestamp timestamp = messageDoc['sentAt'];
          print(timestamp);

          DateTime messageTime = timestamp.toDate();

          // Check if the timestamp is between fromTime and toTime
          if (messageTime.isAfter(fromTime) && messageTime.isBefore(toTime)) {
            String message = messageDoc["message"];
            messages.add(message); // Assuming the field name is 'message'
          } else {
            // Continue to the next document if the condition is not met
            continue;
          }
        }
      }
    }
    print(messages);
    // Return the list of messages
    return messages;
  } catch (e) {
    print("Error fetching messages: $e");
    return [];
  }
}

Future<String> getDiyaMessagess(
    DateTime? fromTime, DateTime? toTime, String gpId) async {
  // Initialize an empty list to store messages

  String messages = "";

  try {
    if (fromTime == null || toTime == null) {
      throw ArgumentError("fromTime and toTime cannot be null");
    }
    Timestamp totimestamp = Timestamp.fromDate(toTime);
    Timestamp fromtimestamp = Timestamp.fromDate(fromTime);
    print(fromtimestamp);
    print(totimestamp);
    // Access the top-level collection group
    CollectionReference collectionGroup =
        FirebaseFirestore.instance.collection('groups');
    print("collectio");

    // Iterate through the documents in the collection group
    QuerySnapshot groupSnapshot = await collectionGroup.get();

    for (var groupDoc in groupSnapshot.docs) {
      print("enter first loop");
      // Access the specific document and its tomessages collection
      if (groupDoc.id == gpId) {
        print("entered first if");
        CollectionReference tomessages =
            groupDoc.reference.collection('messages');

        // Query documents in the tomessages collection
        QuerySnapshot messagesSnapshot = await tomessages.get();

        for (var messageDoc in messagesSnapshot.docs) {
          print("entered");
          // Check if sentitime matches the condition
          Timestamp timestamp = messageDoc['sentAt'];
          print(timestamp);

          DateTime messageTime = timestamp.toDate();

          // Check if the timestamp is between fromTime and toTime
          if (messageTime.isAfter(fromTime) && messageTime.isBefore(toTime)) {
            String message = messageDoc["message"];
            String userName = messageDoc["sender"];
            messages += "${userName}:${message}\n";
            // Assuming the field name is 'message'
          } else {
            // Continue to the next document if the condition is not met
            continue;
          }
        }
      }
    }
    print(messages);
    // Return the list of messages
    return messages;
  } catch (e) {
    print("Error fetching messages: $e");
    return "";
  }
}
