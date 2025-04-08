// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:offline_test_app/controllers/auth_controller.dart';
// import 'package:offline_test_app/core/constants/textstyles_constants.dart';
// import 'package:offline_test_app/screens/register_screen.dart';
// import 'package:offline_test_app/widgets/custom_text_field.dart';
// import 'package:offline_test_app/core/constants/color_constants.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AppAuthController>(builder: (authController) {
//       if (authController.isUserAuthenticated.value) {
//         Future.delayed(Durations.medium3, () {
//           Get.offAllNamed('/home');
//         });
//       }
//       return Scaffold(
//         backgroundColor: AppColors.button,
//         body: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // App Logo
//                   SizedBox(
//                     height: 100,
//                     child:
//                         Image.asset('assets/app_logo.png', fit: BoxFit.contain),
//                   ),
//                   const SizedBox(height: 20),
//                   // Login Form
//                   Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     elevation: 5,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           const Text('Login', style: AppTextStyles.heading),
//                           const SizedBox(height: 20),
//                           CustomTextField(
//                             controller: authController.emailController,
//                             label: 'Email',
//                             isEmail: true,
//                             isRequired: true,
//                           ),
//                           const SizedBox(height: 10),
//                           CustomTextField(
//                             controller: authController.passController,
//                             label: 'Password',
//                             isPassword: true,
//                             isRequired: true,
//                           ),
//                           const SizedBox(height: 10),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: TextButton(
//                                 onPressed: () {
//                                   authController.forgotPassword();
//                                 },
//                                 child: const Text('Forgot Password?')),
//                           ),
//                           const SizedBox(height: 20),
//                           ElevatedButton(
//                             onPressed: authController.isLoading.value
//                                 ? null
//                                 : () {
//                                     authController.login();
//                                   },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.button,
//                               minimumSize: const Size(double.infinity, 50),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8)),
//                             ),
//                             child: authController.isLoading.value
//                                 ? const Center(
//                                     child: CircularProgressIndicator.adaptive(),
//                                   )
//                                 : const Text('Login',
//                                     style: AppTextStyles.button),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Get.to(() => const RegistrationPage());
//                             },
//                             child: const Text(
//                               "Don't have an account? Register",
//                               style: AppTextStyles.body,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/screens/forgot_password.dart';
import 'package:offline_test_app/screens/register_screen.dart';
import 'package:offline_test_app/widgets/custom_text_field.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppAuthController>(builder: (authController) {
      if (authController.isUserAuthenticated.value) {
        Future.delayed(Durations.medium3, () {
          Get.offAllNamed('/home');
        });
      }
      return Scaffold(
        backgroundColor: AppColors.button,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Check screen width to determine layout
                if (constraints.maxWidth < 600) {
                  // Mobile layout
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // App Logo (optional for mobile)
                          SizedBox(
                            height: 100,
                            child: Image.asset(
                              'assets/app_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Login Form
                          _buildLoginForm(authController),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Web layout
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left side: Image/GIF/SVG
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: SvgPicture.asset(
                            'assets/login_vector.svg', // Replace with your GIF/SVG
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Right side: Login Form
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: _buildLoginForm(authController),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      );
    });
  }

  // Reusable Login Form Widget
  Widget _buildLoginForm(AppAuthController authController) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Login', style: AppTextStyles.heading),
            const SizedBox(height: 20),
            CustomTextField(
              controller: authController.emailController,
              label: 'Email',
              isEmail: true,
              isRequired: true,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: authController.passController,
              label: 'Password',
              isPassword: true,
              isRequired: true,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Get.to(() => ForgotPasswordScreen());
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authController.isLoading.value
                  ? null
                  : () {
                      authController.login();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: authController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : const Text('Login', style: AppTextStyles.button),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Get.to(() => const RegistrationPage());
              },
              child: const Text(
                "Don't have an account? Register",
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
