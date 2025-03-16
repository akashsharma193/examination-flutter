import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/widgets/custom_text_field.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  void _submitForm(AppAuthController authController) {
    if (_formKey.currentState!.validate()) {
      authController.register();
    }
  }

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AppAuthController>();
    ever(authController.isUserAuthenticated, (isAuthenticated) {
      if (isAuthenticated) Get.offAllNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AppAuthController>();

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/app_logo.png', height: 100),
            const SizedBox(height: 20),
            Card(
              color: AppColors.dialogBackground,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("Register", style: AppTextStyles.heading),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: authController.nameController,
                        label: "Name",
                        errorMessage: "Enter your name",
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: authController.mobileController,
                        label: "Mobile",
                        isMobile: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: authController.registerEmailController,
                        label: "Email",
                        isEmail: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: authController.batchController,
                        label: "Batch",
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: authController.orgCodeController,
                        label: "Org Code",
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: authController.registerPassController,
                        label: "Password",
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),
                      Obx(() => ElevatedButton(
                            onPressed: authController.isRegisterLoading.value
                                ? null
                                : () => _submitForm(authController),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.button,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: authController.isRegisterLoading.value
                                ? const CircularProgressIndicator.adaptive()
                                : const Text("Submit", style: AppTextStyles.button),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
