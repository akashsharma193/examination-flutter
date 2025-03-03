import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';

class AuthMiddleWare extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AppLocalStorage.instance.isLoggedIn
        ? const RouteSettings(name: '/home')
        : super.redirect(route);
  }
}
