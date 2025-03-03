import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';

class AppAuthController extends GetxController {
  RxBool isUserAuthenticated = false.obs;
  RxBool isLoading = false.obs;

  //Repos
  final AuthRepo repo = AuthRepo();
  AppLocalStorage localStorage = AppLocalStorage.instance;
  // text controllers
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // api calls
  void login() async {
    isLoading.value = true;
    update();
    try {
      final response = await repo.login(
          user: emailController.text, pass: passController.text);
      debugPrint("repsonse of login in authController : ${response}");
      switch (response) {
        case AppSuccess():
          if (response.value.isEmpty()) {
            return;
          }
          isUserAuthenticated.value = true;
          localStorage.setIsUserLoggedIn(true);
          log(response.value.toString());
          localStorage.setUserData(response.value);
          break;
        case AppFailure():
          isUserAuthenticated.value = false;
          localStorage.setIsUserLoggedIn(false);
        default:
      }
    } catch (e) {
      debugPrint("error in login authcontroller : $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
