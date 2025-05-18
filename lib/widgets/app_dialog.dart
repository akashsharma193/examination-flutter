// lib/widgets/app_dialog.dart
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDialog {
  static final AppDialog _instance = AppDialog._internal();
  factory AppDialog() => _instance;

  AppDialog._internal();

  void show(
      {required String title,
      required Widget content,
      VoidCallback? onPressed,
      String? buttonText,
      bool showButton = true,
      bool restrictBack = false,
      bool isDismissible = true}) {
    Get.until((route) => !Get.isDialogOpen!);

    Get.dialog(
      PopScope(
        canPop: !restrictBack,
        child: AlertDialog(
          title: Center(child: Text(title,textAlign: TextAlign.center)),
          content: content,
          actions: [
            if (showButton)
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: ElevatedButton(
                        onPressed: onPressed,
                        // Disabled if checkbox is unchecked
                        style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardBackground,
                        foregroundColor: Colors.white),
                    child: Text(buttonText ?? "Continue"),
                      )
                  ),
                  ),
                ],
              ),
          ],
        ),
      ),
      barrierDismissible: isDismissible,
    );
  }
}
