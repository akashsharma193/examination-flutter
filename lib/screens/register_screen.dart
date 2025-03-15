import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';
import 'package:offline_test_app/widgets/custom_text_field.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
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
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 50),
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
              const SizedBox(height: 40),
              Obx(() => SubmitButton(
                    isLoading: authController.isRegisterLoading.value,
                    onPressed: () => _submitForm(authController),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SubmitButton(
      {super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator.adaptive()
          : const Text("Submit"),
    );
  }
}
