import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/repositories/auth_repo.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final tempPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  Future<void> sendTempPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackbar("Please enter your email address", error: true);
      return;
    }

    if (!_validateEmail(email)) {
      _showSnackbar("Please enter a valid email address", error: true);
      return;
    }

    isLoading.value = true;
    final response = await _repo.sendTempPassword(email);
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
    final email = emailController.text.trim();
    final tempPassword = tempPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty ||
        tempPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackbar("Please fill in all fields", error: true);
      return;
    }

    String? passwordError = validatePassword(newPassword);
    if (passwordError != null) {
      _showSnackbar(passwordError, error: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackbar("New password and confirm password do not match",
          error: true);
      return;
    }

    isResetLoading.value = true;
    final response = await _repo.resetPassword(
      email: email,
      tempPassword: tempPassword,
      newPassword: newPassword,
    );
    isResetLoading.value = false;

    switch (response) {
      case AppSuccess():
        _showSnackbar("Password reset successfully.");
        tempSent.value = false;
        emailController.clear();
        tempPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        Get.offAllNamed('/login');
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
    confirmPasswordController.dispose();
    super.onClose();
  }
}
