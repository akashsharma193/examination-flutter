import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/app_user_model.dart';
import 'package:crackitx/repositories/admin_repo.dart';

class EditUserDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<UserModel> user = UserModel.toEmpty().obs;

  // Form controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final batchController = TextEditingController();
  final passwordController = TextEditingController();
  final orgCodeController = TextEditingController();
  final isActive = false.obs;
  final isAdmin = false.obs;
  bool isObscureText = false;
  final AdminRepo repo = AdminRepo();

  @override
  void onInit() {
    super.onInit();
    // Fetch user details when the controller is initialized
    initData();
  }

  void initData() {
    user.value = Get.arguments['user'] as UserModel;
    nameController.value = TextEditingValue(text: user.value.name);
    mobileController.value = TextEditingValue(text: user.value.mobile);
    emailController.value = TextEditingValue(text: user.value.email);
    batchController.value = TextEditingValue(text: user.value.batch);
    passwordController.value = TextEditingValue(text: user.value.password);
    orgCodeController.value = TextEditingValue(text: user.value.orgCode);

    isActive.value = user.value.isActive;
    isAdmin.value = user.value.isAdmin;
  }

  void togglePasswordVisibilityy() {
    isObscureText = !isObscureText;
    update();
  }

  // Update user details
  void updateUserDetails() async {
    try {
      isLoading(true);

      // Validate form fields
      if (nameController.text.isEmpty ||
          mobileController.text.isEmpty ||
          emailController.text.isEmpty ||
          batchController.text.isEmpty ||
          passwordController.text.isEmpty ||
          orgCodeController.text.isEmpty) {
        throw 'All fields are required';
      }

      // Prepare updated user data
      final updatedUser = UserModel(
          id: user.value.id,
          userId: user.value.userId,
          name: nameController.text,
          mobile: mobileController.text,
          email: emailController.text,
          batch: batchController.text,
          password: passwordController.text,
          orgCode: orgCodeController.text,
          isActive: isActive.value,
          isAdmin: isAdmin.value,
          fcmToken: user.value.fcmToken);

      // Call API to update user details
      await repo.updateUserDetails(updatedUser.toJson());

      Get.snackbar('Success', 'User details updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
