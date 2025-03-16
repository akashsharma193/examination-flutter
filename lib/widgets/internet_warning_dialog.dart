import 'package:flutter/material.dart';

void showInternetWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissing by tapping outside
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text("Internet Connected",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "You cannot attempt the exam while the internet is on.\nPlease disconnect and try again.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              // Perform any action needed, like redirecting or closing the app
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
            label: const Text("OK"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    },
  );
}
