import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/app_user_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/repositories/admin_repo.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';

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

  final AdminRepo repo = AdminRepo();

  @override
  void onInit() {
    super.onInit();
    // Fetch user details when the controller is initialized
    fetchUserDetails();
  }

  // Fetch user details using userId from Get.arguments
  void fetchUserDetails() async {
    try {
      isLoading(true);
      final userId = Get.arguments['userId']; // Get userId from arguments
      if (userId == null) {
        throw 'User ID not provided';
      }

      // Call API to fetch user details
      final response = await repo.fetchUserDetails(userId, orgCode: '');
      switch (response) {
        case AppSuccess():
          user.value = response.value;
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: response.errorMessage);
          break;
      }

      // Populate form fields with fetched data
      nameController.text = user.value.name;
      mobileController.text = user.value.mobile;
      emailController.text = user.value.email;
      batchController.text = user.value.batch;
      passwordController.text = user.value.password;
      orgCodeController.text = user.value.orgCode;
      isActive.value = user.value.isActive;
      isAdmin.value = user.value.isAdmin;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
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
      );

      // Call API to update user details
      await repo.updateUserDetails(updatedUser, userId: user.value.userId);

      Get.snackbar('Success', 'User details updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
