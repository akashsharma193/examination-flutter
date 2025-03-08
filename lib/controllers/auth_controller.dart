import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';

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

void checkIfAlreadyLoggedIn(){
  if(AppLocalStorage.instance.isLoggedIn){
    isUserAuthenticated.value=true;

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
          break;
        case AppFailure():
          Get.showSnackbar(GetSnackBar(
            title: response.errorMessage,
            message: response.errorMessage,
          ));
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
      }
      );

      debugPrint("Response of register in authController: $response");

      switch (response) {
        case AppSuccess():
          isUserAuthenticated.value = true;
          localStorage.setIsUserLoggedIn(true);
          log(response.value.toString());
          localStorage.setUserData(response.value);
          Get.snackbar("Success", "Registration Successful", snackPosition: SnackPosition.BOTTOM);
          break;
        case AppFailure():
          Get.snackbar("Error", response.errorMessage, snackPosition: SnackPosition.BOTTOM);
          isUserAuthenticated.value = false;
          localStorage.setIsUserLoggedIn(false);
          break;
        default:
      }
    } catch (e) {
      debugPrint("Error in register authController: $e");
      Get.snackbar("Error", "Something went wrong!", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isRegisterLoading.value = false;
      update();
    }
  }
}
