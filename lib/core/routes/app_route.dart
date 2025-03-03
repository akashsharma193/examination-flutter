import 'package:get/route_manager.dart';
import 'package:offline_test_app/core/routes/app_bindings.dart';
import 'package:offline_test_app/core/routes/middle_wares.dart';
import 'package:offline_test_app/home.dart';
import 'package:offline_test_app/main.dart';

class AppRoute {
  static final routes = [
    GetPage(
        name: '/',
        page: () => LoginPage(),
        binding: AppAuthBinding(),
        middlewares: [AuthMiddleWare()]),
    GetPage(
        name: '/login',
        page: () => LoginPage(),
        binding: AppAuthBinding(),
        middlewares: [AuthMiddleWare()]),
    GetPage(name: '/home', page: () => HomePage(), binding: HomeBinding()),
    // GetPage(name: '/', page: () => LoginPage(), binding: AppAuthBinding()),
  ];
}
