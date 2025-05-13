import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:crackitx/controllers/forgot_password_controller.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';
import 'package:crackitx/widgets/app_text_field.dart';
import 'package:crackitx/widgets/app_back_button.dart';
import 'package:crackitx/core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());

  Widget _buildForm(BuildContext context) {
    final purple = const Color(0xFF7460F1);
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: controller.emailController,
            hintText: 'Email',
            prefixIcon: Icon(Icons.email, color: purple),
            type: TextFieldType.email,
          ),
          const SizedBox(height: 18),
          // Send Temporary Password Button
          SizedBox(
            width: double.infinity,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: controller.isLoading.value
                    ? null
                    : controller.sendTempPassword,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text(
                            'Send Temporary Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          if (controller.tempSent.value) ...[
            const SizedBox(height: 28),
            AppTextField(
              controller: controller.tempPasswordController,
              hintText: 'Temporary Password',
              prefixIcon: Icon(Icons.lock_open, color: purple),
              type: TextFieldType.text,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.newPasswordController,
              hintText: 'New Password',
              prefixIcon: Icon(Icons.lock, color: purple),
              type: TextFieldType.password,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.confirmPasswordController,
              hintText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline, color: purple),
              type: TextFieldType.password,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: controller.tempSent.value &&
                          !controller.isResetLoading.value
                      ? controller.resetPassword
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: controller.isResetLoading.value
                          ? const CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF7460F1);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Forgot Password',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Obx(() {
        final double illustrationHeight = controller.tempSent.value ? 110 : 140;
        return Padding(
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Illustration
                Image.asset(
                  'assets/forgot_pass_bg.png',
                  height: illustrationHeight,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                    child: _buildForm(context),
                  ),

                ),
            const SizedBox(height: 24),

              ],
            ),
          ),
        );
      }),
    );
  }
}
