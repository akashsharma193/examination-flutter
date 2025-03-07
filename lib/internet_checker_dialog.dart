import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class InternetCheckDialog {
  static void show(BuildContext context,VoidCallback callBack) {
    showDialog(
      barrierDismissible: false, // Prevents dismissing by tapping outside
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("No Internet Connection"),
              content: const Text("Please turn on the internet to continue."),
              actions: [
                TextButton(
                  onPressed: () async {
                    var connectivityResult =
                    await Connectivity().checkConnectivity();
                    if (!connectivityResult.contains(ConnectivityResult.none)) {
                      Get.back(); // Close dialog
                      Get.offAllNamed('/home');
                    } else {
                      Fluttertoast.showToast(msg: "Please enable internet to continue...");
                      setState(() {}); // Keep dialog open if no internet
                    }
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
