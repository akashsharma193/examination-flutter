import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';
import 'package:offline_test_app/core/routes/app_route.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/data/remote/app_dio_service.dart';
import 'package:offline_test_app/firebase_options.dart';
import 'package:offline_test_app/screens/register_screen.dart';
import 'package:offline_test_app/services/app_notification_services.dart';
import 'package:offline_test_app/services/firebase_services_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AppLocalStorage.instance.initAppLocalStorage();

  // AppLocalStorage.instance.clearStorage();

  NotificationService notificationService = NotificationService();

  await FirebaseService.instance.initialize();
  await notificationService.initialize();
  await AppDioService.instance
      .initDioService(baseUrl: 'https://online-examination-xlcp.onrender.com/');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      getPages: AppRoute.routes,

      initialRoute: '/',
      // home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppAuthController>(builder: (authController) {
      if (authController.isUserAuthenticated.value) {
        Future.delayed(Durations.medium3, () {
          Get.offAllNamed('/home');
        });
      }
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                  controller: authController.emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 10),
              TextField(
                  controller: authController.passController,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                          icon: Icon(isObscure
                              ? Icons.visibility_off
                              : Icons.visibility))),
                  obscureText: isObscure),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      authController.forgotPassword();
                    },
                    child: const Text('Forgot Password?')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authController.isLoading.value
                    ? () {}
                    : () {
                        authController.login();
                      },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                child: authController.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator.adaptive(),
                      )
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => const RegistrationPage());
                },
                child: const Text(
                  "Don't have an account? Register",
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
