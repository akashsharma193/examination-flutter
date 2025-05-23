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
      Get.offAllNamed('/home', arguments: {'from': 'splash'}); // Navigate to HomePage with arguments
    } else {
      Get.offAllNamed('/login', arguments: {'from': 'splash'}); // Navigate to LoginPage with arguments
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        decoration:const  BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: 
       Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/app_logo.png', // Add your logo in assets folder
              width: 150,
            ),
            const SizedBox(height: 40),
            // Tagline
            Text(
              "Exam without internet, focus without distraction.",
              textAlign: TextAlign.center,
              style: AppTextStyles.subheading.copyWith(
                color: Colors.white,
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
