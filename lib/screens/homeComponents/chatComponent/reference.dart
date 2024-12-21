import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ReferencesScreen extends StatelessWidget {
  final String groupId;

  const ReferencesScreen({super.key, required this.groupId});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      // Clean and validate URL
      String cleanUrl = urlString.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final Uri uri = Uri.parse(cleanUrl);

      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ).catchError((e) => false);

      if (!launched) {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pinReference(BuildContext context, Map<String, dynamic> reference) async {
  try {
    // Extract necessary fields
    final String summary = reference['summary'] as String? ?? '';
    final String url = reference['urls'] as String? ?? '';
    final DateTime sentAt = DateTime.now(); // Current timestamp

    // Build the message structure
    final Map<String, dynamic> messageData = {
      'email': 'orion@orion.com',
      'message': summary.isNotEmpty ? '$summary\n$url' : url,
      'sender': 'Orion',
      'sentAt': sentAt,
    };

    // Add the message to the 'messages' collection
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(messageData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reference pinned successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error pinning reference: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generated References',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 1, 25),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 10, 19, 42),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .doc(groupId)
              .collection('references')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No references yet',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            final references = snapshot.data!.docs;
            return ListView.builder(
              itemCount: references.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final reference = references[index].data() as Map<String, dynamic>;
                final summary = reference['summary'] as String? ?? '';
                final url = reference['urls'] as String? ?? '';
                final timestamp = reference['createdAt'] as Timestamp?;

                return Card(
                  color: const Color.fromARGB(255, 3, 10, 40),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (summary.isNotEmpty) ...[
                          Text(
                            summary,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (url.isNotEmpty)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _launchURL(context, url),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.link,
                                      color: Color.fromARGB(255, 33, 198, 243),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        url,
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 33, 222, 243),
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (timestamp != null)
                              Text(
                                _formatDateTime(timestamp.toDate()),
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 206, 98, 201).withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.push_pin, color: Colors.green),
                              onPressed: () => _pinReference(context, reference),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
