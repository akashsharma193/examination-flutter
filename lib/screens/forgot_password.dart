import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/forgot_password_controller.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());

  Widget _buildTextField(String label, TextEditingController textController,
      {bool obscure = false, bool enabled = true, bool isPassword = false}) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: textController,
        obscureText: isPassword ? obscure : false,
        enabled: enabled,
        decoration: InputDecoration(
            filled: true,
            fillColor:
                enabled ? AppColors.inputBackground : Colors.grey.shade100,
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textPrimary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabled: isPassword,
            suffix: !isPassword
                ? null
                : IconButton(
                    onPressed: controller.isObscure.toggle,
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: AppColors.appBar,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => ListView(
            children: [
              const SizedBox(
                height: 30,
              ),
              _buildTextField("Email", controller.emailController),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.sendTempPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Send Temporary Password"),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                "Temporary Password",
                controller.tempPasswordController,
                enabled: controller.tempSent.value,
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildTextField(
                  "New Password",
                  isPassword: true,
                  controller.newPasswordController,
                  obscure: controller.isObscure.value,
                  enabled: controller.tempSent.value,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.tempSent.value &&
                        !controller.isResetLoading.value
                    ? controller.resetPassword
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: controller.isResetLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
