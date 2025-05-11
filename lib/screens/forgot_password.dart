import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:crackitx/controllers/forgot_password_controller.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

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
          fillColor: enabled ? AppColors.inputBackground : Colors.grey.shade100,
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textPrimary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          suffix: !isPassword
              ? null
              : IconButton(
                  onPressed: controller.isObscure.toggle,
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          _buildTextField("Email", controller.emailController),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                controller.isLoading.value ? null : controller.sendTempPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
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
              controller.newPasswordController,
              isPassword: true,
              obscure: controller.isObscure.value,
              enabled: controller.tempSent.value,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                controller.tempSent.value && !controller.isResetLoading.value
                    ? controller.resetPassword
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: controller.isResetLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Reset Password"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: GradientAppBar(
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isWide
              ? Row(
                  children: [
                    Expanded(
                      child: Lottie.asset(
                        'assets/forgot_password.json',
                        height: 400,
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: AppColors.dialogBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildForm(context),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    Lottie.asset(
                      'assets/forgot_password.json',
                      height: Get.height * 0.15,
                      repeat: true,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: AppColors.dialogBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _buildForm(context),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
