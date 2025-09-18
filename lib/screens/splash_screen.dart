import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    bool isAuthenticated =
        AppLocalStorage.instance.isLoggedIn; // Check login status

    if (isAuthenticated) {
      Get.offNamed('/home'); // Navigate to HomePage
    } else {
      Get.offNamed('/login'); // Navigate to LoginPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white
            // image: DecorationImage(
            //   image: AssetImage('assets/splash_bg.png'),
            //   fit: BoxFit.cover,
            // ),
            ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/examdy_splash_icon.png', // Add your logo in assets folder
                width: 250,
              ),
              const SizedBox(height: 20),
              // Tagline
              Text(
                "Exam without internet, focus without distraction.",
                textAlign: TextAlign.center,
                style: AppTextStyles.subheading.copyWith(
                  color: AppColors.cardBackground,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
