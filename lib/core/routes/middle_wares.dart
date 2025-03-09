import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';

class AuthMiddleWare extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AppLocalStorage.instance.isLoggedIn
        ? const RouteSettings(name: '/home')
        : super.redirect(route);
  }
}

class InternetCheckMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    log("redirecting to null??");
    return null; // No automatic redirection, handling manually
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    log("redirect deigate called: ");
    var connectivityResult = await Connectivity().checkConnectivity();
    final results =
        connectivityResult.where((e) => ConnectivityResult.none != e);

    log("internet middle ware   : $results");
    if (results.isNotEmpty) {
      _showAlertDialog();
      return null; // Prevent navigation
    }

    // No internet, allow navigation to exam screen
    return route;
  }

  void _showAlertDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Internet Detected"),
        content: const Text("You can't attempt the exam while online."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
      barrierDismissible:
          false, // Prevents user from dismissing the dialog accidentally
    );
  }
}
