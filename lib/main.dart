import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:crackitx/core/routes/app_route.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/data/remote/app_dio_service.dart';
import 'package:crackitx/firebase_options.dart';
import 'package:crackitx/screens/splash_screen.dart';
import 'package:crackitx/services/firebase_services_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AppLocalStorage.instance.initAppLocalStorage();

  // await AppFirebaseService.instance.initialize();
  // await AppNotificationService.instance.initialize();
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
      home: const SplashScreen(),
      initialRoute: '/',
      // home: LoginPage(),
    );
  }
}
