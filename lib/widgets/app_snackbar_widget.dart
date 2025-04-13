import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbarWidget {
  static Future<void> showSnackBar(
      {bool isSuccess = false, String subTitle = ''}) async {
    log("showing snackbar from widget...");
    Get.snackbar(
      isSuccess ? 'Success' : 'Failed',
      subTitle,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
    await Future.delayed(const Duration(seconds: 3), () {
      Get.closeAllSnackbars();
    });
  }
}
