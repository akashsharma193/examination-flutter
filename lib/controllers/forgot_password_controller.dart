import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/repositories/auth_repo.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final tempPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final AuthRepo _repo = AuthRepo();

  var isLoading = false.obs;
  var isResetLoading = false.obs;
  var tempSent = false.obs;
  RxBool isObscure = false.obs;

  void _showSnackbar(String message, {bool error = false}) {
    Get.snackbar(
      error ? 'Error' : 'Success',
      message,
      backgroundColor: error ? AppColors.error : AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> sendTempPassword() async {
    isLoading.value = true;
    final response = await _repo.sendTempPassword(emailController.text.trim());
    isLoading.value = false;

    switch (response) {
      case AppSuccess():
        tempSent.value = true;
        _showSnackbar("Temporary password sent. Check your email.");
      case AppFailure():
        _showSnackbar(response.errorMessage ?? "Failed to send temp password.",
            error: true);
    }
  }

  Future<void> resetPassword() async {
    isResetLoading.value = true;
    final response = await _repo.resetPassword(
      email: emailController.text.trim(),
      tempPassword: tempPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
    );
    isResetLoading.value = false;

    switch (response) {
      case AppSuccess():
        _showSnackbar("Password reset successfully.");
        tempSent.value = false;
        emailController.clear();
        tempPasswordController.clear();
        newPasswordController.clear();
        Get.toNamed('/login');
      case AppFailure():
        _showSnackbar(response.errorMessage ?? "Failed to reset password.",
            error: true);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    tempPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
