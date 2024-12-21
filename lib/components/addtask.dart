import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task.dart'; // For the Task class and formatting the date.

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onAddTask;

  AddTaskDialog({required this.onAddTask});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController eventController = TextEditingController();
  String? selectedDate;
  String? selectedTime;
  bool isAddButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    selectedTime = '11:59 PM';

    taskController.addListener(_validateFields);
    eventController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      isAddButtonEnabled = taskController.text.trim().isNotEmpty && eventController.text.trim().isNotEmpty;
    });
  }
Future<void> _selectDate() async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (context, child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          primaryColor: Colors.green, // Primary color for the date picker
          colorScheme: ColorScheme.dark().copyWith(
            primary: const Color.fromARGB(255, 179, 14, 14), // Primary color for selected date
            secondary: const Color.fromARGB(255, 223, 13, 13), // Secondary color for other UI elements
          ),
          dialogBackgroundColor: Color.fromARGB(255, 36, 36, 36), // Background color
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.green), // Button text color
          ),
        ),
        child: child!,
      );
    },
  );
  if (pickedDate != null) {
    setState(() {
      selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }
}

Future<void> _selectTime() async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          primaryColor: const Color.fromARGB(255, 211, 79, 8), // Primary color for the time picker
          
          colorScheme: ColorScheme.dark().copyWith(
            primary: const Color.fromARGB(255, 179, 14, 14), // Primary color for selected time
            secondary: const Color.fromARGB(255, 185, 34, 34), // Secondary color for other UI elements
            tertiary: const Color.fromARGB(255, 185, 34, 34),
          ),
          dialogBackgroundColor: Color.fromARGB(255, 36, 36, 36), // Background color
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.green), // Button text color
          ),
        ),
        child: child!,
      );
    },
  );
  if (pickedTime != null) {
    setState(() {
      selectedTime = pickedTime.format(context);
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 36, 36, 36),
      title: Text(
        "Add New Task",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400, // Increased width of the dialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Task',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color.fromARGB(255, 20, 20, 20),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70), // Disable outline focus color
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: eventController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color.fromARGB(255, 21, 21, 21),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70), // Disable outline focus color
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Increased height of the date button
                TextButton(
                  onPressed: _selectDate,
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18), // Increased padding for button height
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Date: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        selectedDate ?? '',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Increased height of the time button
                TextButton(
                  onPressed: _selectTime,
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18), // Increased padding for button height
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Time: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        selectedTime ?? '',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: isAddButtonEnabled
              ? () {
                  final task = Task(
                    taskController.text,
                    eventController.text,
                    '$selectedDate $selectedTime',
                  );
                  widget.onAddTask(task);
                  Navigator.pop(context);
                }
              : null,
          child: Text(
            "Add",
            style: TextStyle(color: isAddButtonEnabled ? Colors.green : Colors.grey),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    taskController.dispose();
    eventController.dispose();
    super.dispose();
  }
}