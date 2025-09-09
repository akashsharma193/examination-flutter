import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/controllers/auth_controller.dart';
import 'package:crackitx/widgets/app_text_field.dart';
import 'package:crackitx/widgets/app_back_button.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AppAuthController>();
    final purple = const Color(0xFF7460F1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.topLeft,
                        child: AppBackButton(onTap: () {
                          Get.back();
                        }),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Card(
                              color: Colors.white,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "REGISTER",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      AppTextField(
                                        controller:
                                            authController.nameController,
                                        hintText: 'Name',
                                        prefixIcon:
                                            Icon(Icons.person, color: purple),
                                        type: TextFieldType.text,
                                      ),
                                      const SizedBox(height: 16),
                                      AppTextField(
                                        controller:
                                            authController.mobileController,
                                        hintText: 'Number',
                                        prefixIcon:
                                            Icon(Icons.phone, color: purple),
                                        type: TextFieldType.number,
                                      ),
                                      const SizedBox(height: 16),
                                      AppTextField(
                                        controller: authController
                                            .registerEmailController,
                                        hintText: 'Email',
                                        prefixIcon:
                                            Icon(Icons.email, color: purple),
                                        type: TextFieldType.email,
                                      ),
                                      const SizedBox(height: 16),
                                      AppTextField(
                                        controller:
                                            authController.batchController,
                                        hintText: 'Batch',
                                        prefixIcon:
                                            Icon(Icons.people, color: purple),
                                        type: TextFieldType.text,
                                      ),
                                      const SizedBox(height: 16),
                                      AppTextField(
                                        controller:
                                            authController.orgCodeController,
                                        hintText: 'Org Code',
                                        prefixIcon: Icon(
                                            Icons.apartment_outlined,
                                            color: purple),
                                        type: TextFieldType.text,
                                      ),
                                      const SizedBox(height: 16),
                                      AppTextField(
                                        controller: authController
                                            .registerPassController,
                                        hintText: 'Password',
                                        prefixIcon:
                                            Icon(Icons.lock, color: purple),
                                        type: TextFieldType.password,
                                      ),
                                      const SizedBox(height: 16),
                                      AppTextField(
                                        controller: authController
                                            .confirmPassController,
                                        hintText: 'Confirm Password',
                                        prefixIcon:
                                            Icon(Icons.lock, color: purple),
                                        type: TextFieldType.password,
                                        validator: (value) => authController
                                                    .registerPassController
                                                    .text ==
                                                authController
                                                    .confirmPassController.text
                                            ? null
                                            : 'Passwords do not match',
                                      ),
                                      const SizedBox(height: 28),
                                      Obx(() => Material(
                                            elevation: 2,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: authController
                                                      .isRegisterLoading.value
                                                  ? null
                                                  : () => _submitForm(
                                                      authController),
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      purple,
                                                      purple.withOpacity(0.7)
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Center(
                                                  child: authController
                                                          .isRegisterLoading
                                                          .value
                                                      ? const CircularProgressIndicator
                                                          .adaptive(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white))
                                                      : const Text(
                                                          'Submit',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
