import 'package:crackitx/controllers/auth_controller.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/screens/forgot_password.dart';
import 'package:crackitx/screens/register_screen.dart';
import 'package:crackitx/widgets/curvy_left_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:crackitx/widgets/wavy_gradient_background.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:crackitx/core/theme/app_theme.dart';
import 'package:crackitx/widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileLoginPage();
        } else {
          return const WebLoginPage();
        }
      },
    );
  }
}

class MobileLoginPage extends StatefulWidget {
  const MobileLoginPage({super.key});

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppAuthController>(builder: (authController) {
      if (authController.isUserAuthenticated.value) {
        Future.delayed(Durations.medium3, () {
          Get.offAllNamed('/home');
        });
      }
      return GestureDetector(
        onTap: () {
          // Unfocus when tapping anywhere on the screen
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              // Wavy gradient background
              const Positioned.fill(
                child: WavyGradientBackground(),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Avatar
                      Center(
                          child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset('assets/app_logo.png',
                            width: 100, height: 100),
                      )),
                      const SizedBox(height: 32),
                      // Login Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Username
                              AppTextField(
                                controller: authController.emailController,
                                hintText: 'Email',
                                type: TextFieldType.email,
                                prefixIcon: const Icon(Icons.person_outline,
                                    color: Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              // Password
                              AppTextField(
                                controller: authController.passController,
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Colors.black54),
                                type: TextFieldType.password,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(() => ForgotPasswordScreen());
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF5E48EF),
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: const Text('Forgot Password ?'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Gradient Login Button
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: authController.isLoading.value
                                      ? null
                                      : () {
                                          authController.login();
                                        },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: authController.isLoading.value
                                          ? const CircularProgressIndicator
                                              .adaptive(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white))
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(() => const RegistrationPage());
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF5E48EF),
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  child: const Text.rich(
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                      children: [
                                        TextSpan(
                                          text: 'Register',
                                          style: TextStyle(
                                            color: Color(0xFF5E48EF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      );
    });
  }
}

class WebLoginPage extends StatefulWidget {
  const WebLoginPage({super.key});

  @override
  State<WebLoginPage> createState() => _WebLoginPageState();
}

class _WebLoginPageState extends State<WebLoginPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppAuthController>(builder: (authController) {
      if (authController.isUserAuthenticated.value) {
        Future.delayed(Durations.medium3, () {
          Get.offAllNamed('/home');
        });
      }
      return GestureDetector(
        onTap: () {
          // Unfocus when tapping anywhere on the screen
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              Expanded(
                child: ClipPath(
                  clipper: CurvyLeftClipper(),
                  child: WavyGradientBackground(
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: _buildLoginForm(authController, context),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// Reusable Login Form Widget
Widget _buildLoginForm(AppAuthController authController, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final textFieldWidth = kIsWeb ? screenWidth * 0.25 : double.infinity;

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
                child: AppTextField(
                  controller: authController.emailController,
                  hintText: 'Email',
                  type: TextFieldType.email,
                  prefixIcon:
                      const Icon(Icons.person_outline, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: textFieldWidth,
                child: AppTextField(
                  controller: authController.passController,
                  hintText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.black54),
                  type: TextFieldType.password,
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
              GestureDetector(
                onTap: authController.isLoading.value
                    ? null
                    : () {
                        authController.login();
                      },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: authController.isLoading.value
                        ? null
                        : AppTheme.primaryGradient,
                    color: authController.isLoading.value
                        ? Colors.grey.shade300
                        : null, // Disabled state color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Login', style: AppTextStyles.button),
                  ),
                ),
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
