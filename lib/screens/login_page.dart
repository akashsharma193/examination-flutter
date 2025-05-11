// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:crackitx/controllers/auth_controller.dart';
// import 'package:crackitx/core/constants/textstyles_constants.dart';
// import 'package:crackitx/screens/register_screen.dart';
// import 'package:crackitx/widgets/custom_text_field.dart';
// import 'package:crackitx/core/constants/color_constants.dart';

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
import 'package:crackitx/controllers/auth_controller.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/screens/forgot_password.dart';
import 'package:crackitx/screens/register_screen.dart';
import 'package:crackitx/widgets/curvy_left_clipper.dart';
import 'package:crackitx/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:crackitx/widgets/wavy_gradient_background.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

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
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
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
                  children: [
                    // Left side: WavyGradientBackground with image and text
                    Expanded(
                      child:ClipPath(
                        clipper: CurvyLeftClipper(),
                        child:  WavyGradientBackground(
                        width: double.infinity,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Overlay with more transparency
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Very good works are\nwaiting for you Login Now!!!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      height: 220,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: SvgPicture.asset(
                                          'assets/login_vector.svg',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                   
                 ), ),
                    // Right side: Login Form

                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: _buildLoginForm(authController),
                    ),
                  ],
                );
              }
            },
          ),
        
      );
    });
  }

  // Reusable Login Form Widget
  Widget _buildLoginForm(AppAuthController authController) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textFieldWidth = kIsWeb
        ? screenWidth * 0.25
        : double
            .infinity; // 0.5 for half of the whole screen, 0.25 for half of a split

    return SizedBox(
        width: textFieldWidth + 50,
        child: Card(
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
                SizedBox(
                  width: textFieldWidth,
                  child: CustomTextField(
                    controller: authController.emailController,
                    label: 'Email',
                    isEmail: true,
                    isRequired: true,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: textFieldWidth,
                  child: CustomTextField(
                    controller: authController.passController,
                    label: 'Password',
                    isPassword: true,
                    isRequired: true,
                  ),
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
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Register",
                          style: AppTextStyles.body.copyWith(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
