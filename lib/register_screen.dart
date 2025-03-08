import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';

class RegistrationPage extends StatefulWidget {
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
    return GetBuilder<AppAuthController>(
      builder: (authController) {
        if (authController.isUserAuthenticated.value) {
          Future.delayed(Durations.medium3, () {
            Get.offAllNamed('/home');
          });
        }
        return Scaffold(
          appBar: AppBar(title: Text("Register")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    _buildTextField(authController.nameController, "Name", "Enter your name"),
                    SizedBox(height: 16,),

                    _buildTextField(authController.mobileController, "Mobile ", null, isRequired: true),
                    SizedBox(height: 16,),

                    _buildTextField(authController.registerEmailController, "Email", "Enter a valid email", isEmail: true),
                    SizedBox(height: 16,),

                    _buildTextField(authController.batchController, "Batch", "Enter batch"),
                    SizedBox(height: 16,),

                    _buildTextField(authController.registerPassController, "Password", "Enter a password", isPassword: true),
                    SizedBox(height: 16,),

                    _buildTextField(authController.orgCodeController, "Org Code", "Enter org code"),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:()=> _submitForm(authController),
                      child:authController.isRegisterLoading.value? Center(child: CircularProgressIndicator.adaptive(),): Text("Submit"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? errorMessage,
      {bool isRequired = true, bool isEmail = false, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
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
