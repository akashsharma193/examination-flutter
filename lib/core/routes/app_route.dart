import 'package:get/route_manager.dart';
import 'package:offline_test_app/core/routes/app_bindings.dart';
import 'package:offline_test_app/main.dart';

class AppRoute {
  static final routes = [
    GetPage(name: '/', page: () => LoginPage(), binding: AppAuthBinding()),
    GetPage(name: '/login', page: () => LoginPage(), binding: AppAuthBinding()),
    GetPage(name: '/home', page: () => HomePage(), binding: AppAuthBinding()),
    // GetPage(name: '/', page: () => LoginPage(), binding: AppAuthBinding()),
  ];
}
