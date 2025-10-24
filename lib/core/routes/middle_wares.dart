import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/widgets/app_dialog.dart';

class HomeAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isLoggedIn = AppLocalStorage.instance.isLoggedIn;

    if (!isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class InternetCheckMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final results =
        connectivityResult.where((e) => ConnectivityResult.none != e);

    if (results.isNotEmpty) {
      _showAlertDialog();
      return null;
    }

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
