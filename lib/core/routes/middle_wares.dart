import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/widgets/app_dialog.dart';

class AuthMiddleWare extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AppLocalStorage.instance.isLoggedIn
        ? const RouteSettings(name: '/home')
        : super.redirect(route);
  }
}

class InternetCheckMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return null; // No automatic redirection, handling manually
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final results =
        connectivityResult.where((e) => ConnectivityResult.none != e);

    if (results.isNotEmpty) {
      _showAlertDialog();
      return null; // Prevent navigation
    }

    // No internet, allow navigation to exam screen
    return route;
  }

  void _showAlertDialog() {
    AppDialog().show(
      title: "Internet Detected",
      content: const Text("You can't attempt the exam while online."),
      buttonText: "OK",
      onPressed: () => Get.back(),
    );
  }
}

