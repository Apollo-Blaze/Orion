import 'package:flutter/material.dart';
import 'task.dart'; // Import Task model

class DeleteTaskDialog extends StatelessWidget {
  final Task task;
  final Function onDelete; // Function to delete task from the list and Shared Preferences

  DeleteTaskDialog({required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A), // Dark background
      title: const Text(
        "Delete Task",
        style: TextStyle(color: Colors.white), // White text for title
      ),
      content: const Text(
        "Are you sure you want to delete this task?",
        style: TextStyle(color: Colors.white70), // Grey text for content
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white), // White text for cancel button
          ),
        ),
        TextButton(
          onPressed: () {
            onDelete(); // Call the delete function
            Navigator.pop(context); // Close the dialog
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red), // Red text for delete button
          ),
        ),
      ],
    );
  }
}