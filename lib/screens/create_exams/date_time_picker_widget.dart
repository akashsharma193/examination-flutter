import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerWidget extends StatelessWidget {
  final String label;
  final String dateTime;
  final Function(DateTime) onPicked;

  const DateTimePickerWidget(
      {super.key,
      required this.label,
      required this.dateTime,
      required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          dateTime.isEmpty ? const Text("Select Date & Time") : Text(dateTime),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          TimeOfDay? time = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          if (time != null) {
            onPicked(DateTime(
                picked.year, picked.month, picked.day, time.hour, time.minute));
          }
        }
      },
    );
  }
}
