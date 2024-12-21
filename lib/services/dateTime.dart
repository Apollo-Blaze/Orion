import 'package:flutter/material.dart';

Future<DateTime?> showDateTimePicker(
    BuildContext context, bool? toDate, bool? fromDate) async {
  // Show a date picker first
  final DateTime? date = await showDatePicker(
    fieldLabelText: "Hi",
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (date == null) return null; // Return if no date selected

  // Show a time picker next
  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time == null) return null; // Return if no time selected

  // Combine date and time into a single DateTime object
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
