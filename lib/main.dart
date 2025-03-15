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
