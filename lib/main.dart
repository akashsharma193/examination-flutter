import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';
import 'package:offline_test_app/core/routes/app_route.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/data/remote/app_dio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalStorage.instance.initAppLocalStorage();
  AppDioService.instance
      .initDioService(baseUrl: 'https://online-examination-xlcp.onrender.com/');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      getPages: AppRoute.routes,
      initialRoute: '/',
      // home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
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
              Text('Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                  controller: authController.emailController,
                  decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 10),
              TextField(
                  controller: authController.passController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: authController.isLoading.value
                    ? () {}
                    : () {
                        authController.login();
                      },
                child: authController.isLoading.value
                    ? Center(
                        child: CircularProgressIndicator.adaptive(),
                      )
                    : Text('Login'),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50)),
              ),
              TextButton(
                onPressed: () {},
                child: Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      );
    });
  }
}
