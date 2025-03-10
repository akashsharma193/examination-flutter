import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';

class AppAuthController extends GetxController {
  RxBool isUserAuthenticated = false.obs;
  RxBool isLoading = false.obs;
  RxBool isRegisterLoading = false.obs;

  //Repos
  final AuthRepo repo = AuthRepo();
  AppLocalStorage localStorage = AppLocalStorage.instance;
  // text controllers
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void onReady() {
    checkIfAlreadyLoggedIn();
    super.onReady();
  }

  // register
  // Text controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final registerEmailController = TextEditingController();
  final batchController = TextEditingController();
  final registerPassController = TextEditingController();
  final orgCodeController = TextEditingController();

  void checkIfAlreadyLoggedIn() {
    if (AppLocalStorage.instance.isLoggedIn) {
      isUserAuthenticated.value = true;
    }
  }

  // api calls
  void login() async {
    isLoading.value = true;
    update();
    try {
      final response = await repo.login(
          user: emailController.text, pass: passController.text);
      debugPrint("repsonse of login in authController : $response");
      switch (response) {
        case AppSuccess():
          isUserAuthenticated.value = true;
          localStorage.setIsUserLoggedIn(true);
          log(response.value.toString());
          localStorage.setUserData(response.value);
          repo.saveFCMToken(userId: AppLocalStorage.instance.user.userId);
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: response.errorMessage);
          isUserAuthenticated.value = false;
      }
    } catch (e) {
      debugPrint("error in login authcontroller : $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Register API Call
  void register() async {
    isRegisterLoading.value = true;
    update();
    try {
      final response = await repo.register({
        "name": nameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "email": registerEmailController.text.trim(),
        "batch": batchController.text.trim(),
        "password": registerPassController.text.trim(),
        "orgCode": orgCodeController.text.trim()
      });

      debugPrint("Response of register in authController: $response");

      switch (response) {
        case AppSuccess():
          log(response.value.toString());
          AppSnackbarWidget.showSnackBar(
            isSuccess: true,
            subTitle: "Registration Successful",
          );
          Get.toNamed('/login');
          break;
        case AppFailure():
          log("error occured in register : ");
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: response.errorMessage);
          isUserAuthenticated.value = false;
          localStorage.setIsUserLoggedIn(false);
          break;
      }
    } catch (e) {
      debugPrint("Error in register authController: $e");
      AppSnackbarWidget.showSnackBar(
          isSuccess: false,
          subTitle: 'Error occured in registeration, try again');
    } finally {
      isRegisterLoading.value = false;
      update();
    }
  }

  void forgotPassword() {
    ExamRepo repo = ExamRepo();
    repo.forgotPassword(emailController.text);
  }
}
