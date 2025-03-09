import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  void _submitForm(AppAuthController authController) {
    if (_formKey.currentState!.validate()) {
      // Get.snackbar("Success", "Form Submitted Successfully",
      //     snackPosition: SnackPosition.BOTTOM);
      authController.register();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppAuthController>(builder: (authController) {
      if (authController.isUserAuthenticated.value) {
        Future.delayed(Durations.medium3, () {
          Get.offAllNamed('/home');
        });
      }
      return Scaffold(
        appBar: AppBar(title: const Text("Register")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  _buildTextField(
                      authController.nameController, "Name", "Enter your name"),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildTextField(
                      authController.mobileController, "Mobile ", null,
                      isMobile: true, isRequired: true),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildTextField(authController.registerEmailController,
                      "Email", "Enter a valid email",
                      isEmail: true),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildTextField(
                      authController.batchController, "Batch", "Enter batch"),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildTextField(authController.orgCodeController, "Org Code",
                      "Enter org code"),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildTextField(authController.registerPassController,
                      "Password", "Enter a password",
                      isPassword: true),
                  const SizedBox(height: 59),
                  ElevatedButton(
                    onPressed: () => _submitForm(authController),
                    child: authController.isRegisterLoading.value
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String? errorMessage,
      {bool isRequired = true,
      bool isEmail = false,
      bool isPassword = false,
      bool isMobile = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      inputFormatters: isMobile
          ? [
              FilteringTextInputFormatter.digitsOnly, // Only allow numbers
              LengthLimitingTextInputFormatter(10), // Enforce max length
            ]
          : [],
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return errorMessage;
        }
        if (isEmail && !GetUtils.isEmail(value ?? "")) {
          return "Enter a valid email";
        }
        return null;
      },
    );
  }
}
