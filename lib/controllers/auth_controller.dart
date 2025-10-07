import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/repositories/auth_repo.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';

class AppAuthController extends GetxController {
  RxBool isUserAuthenticated = false.obs;
  RxBool isLoading = false.obs;
  RxBool isRegisterLoading = false.obs;
  RxBool isLoadingOrgs = false.obs;
  RxBool isLoadingBatches = false.obs;
  RxBool showOrgDropdown = false.obs;
  RxBool showBatchDropdown = false.obs;

  final AuthRepo repo = AuthRepo();
  AppLocalStorage localStorage = AppLocalStorage.instance;

  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final registerEmailController = TextEditingController();
  final batchController = TextEditingController();
  final registerPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  final orgCodeController = TextEditingController();
  final orgSearchController = TextEditingController();
  final batchSearchController = TextEditingController();

  RxList<Map<String, dynamic>> organizations = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> batches = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredOrganizations =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredBatches = <Map<String, dynamic>>[].obs;
  RxString selectedOrgCode = ''.obs;
  RxString selectedBatchCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    syncAuthState();
  }

  @override
  void onReady() {
    checkIfAlreadyLoggedIn();
    super.onReady();
  }

  void syncAuthState() {
    isUserAuthenticated.value = AppLocalStorage.instance.isLoggedIn;
    update();
  }

  void checkIfAlreadyLoggedIn() {
    if (AppLocalStorage.instance.isLoggedIn &&
        AppLocalStorage.instance.accessToken != null) {
      String userRole = AppLocalStorage.instance.userRole;
      if (userRole.toLowerCase() == 'admin') {
        _showUnauthorizedDialog();
      } else {
        isUserAuthenticated.value = true;
      }
    }
  }

  Future<void> fetchOrganizations() async {
    isLoadingOrgs.value = true;
    try {
      final response = await repo.getAllOrganizations();
      switch (response) {
        case AppSuccess():
          if (response.value != null && response.value is List) {
            organizations.value =
                List<Map<String, dynamic>>.from(response.value);
            filteredOrganizations.value =
                List<Map<String, dynamic>>.from(response.value);
          }
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
            isSuccess: false,
            subTitle: 'Failed to load organizations',
          );
          break;
      }
    } finally {
      isLoadingOrgs.value = false;
    }
  }

  Future<void> fetchBatches(String organizationName) async {
    isLoadingBatches.value = true;
    batches.clear();
    filteredBatches.clear();
    batchSearchController.clear();
    selectedBatchCode.value = '';

    try {
      final response = await repo.getAllBatchesByOrganization(organizationName);
      switch (response) {
        case AppSuccess():
          if (response.value != null && response.value is List) {
            batches.value = List<Map<String, dynamic>>.from(response.value);
            filteredBatches.value =
                List<Map<String, dynamic>>.from(response.value);
          }
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
            isSuccess: false,
            subTitle: 'Failed to load batches',
          );
          break;
      }
    } finally {
      isLoadingBatches.value = false;
    }
  }

  void filterOrganizations(String query) {
    if (query.isEmpty) {
      filteredOrganizations.value =
          List<Map<String, dynamic>>.from(organizations);
    } else {
      filteredOrganizations.value = organizations.where((org) {
        final name = org['name']?.toString().toLowerCase() ?? '';
        final description = org['description']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    }
  }

  void filterBatches(String query) {
    if (query.isEmpty) {
      filteredBatches.value = List<Map<String, dynamic>>.from(batches);
    } else {
      filteredBatches.value = batches.where((batch) {
        final name = batch['name']?.toString().toLowerCase() ?? '';
        final description =
            batch['description']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    }
  }

  void selectOrganization(Map<String, dynamic> org) {
    selectedOrgCode.value = org['name'] ?? '';
    orgCodeController.text = org['name'] ?? '';
    orgSearchController.text = org['name'] ?? '';
    fetchBatches(org['name'] ?? '');
  }

  void selectBatch(Map<String, dynamic> batch) {
    selectedBatchCode.value = batch['name'] ?? '';
    batchController.text = batch['name'] ?? '';
    batchSearchController.text = batch['name'] ?? '';
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  void _showUnauthorizedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('You are not authorized to use this application.'),
        actions: [
          TextButton(
            onPressed: () {
              logout();
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void login() async {
    isLoading.value = true;
    update();
    try {
      if (!emailController.text.isEmail) {
        AppSnackbarWidget.showSnackBar(
            isSuccess: false, subTitle: 'Email is not valid');
        return;
      }

      String? passwordError = validatePassword(passController.text);
      if (passwordError != null) {
        AppSnackbarWidget.showSnackBar(
            isSuccess: false, subTitle: passwordError);
        return;
      }

      final response = await repo.login(
          user: emailController.text, pass: passController.text);

      switch (response) {
        case AppSuccess():
          String userRole = AppLocalStorage.instance.userRole;

          if (userRole.toLowerCase() == 'admin') {
            _showUnauthorizedDialog();
          } else {
            isUserAuthenticated.value = true;
            localStorage.setIsUserLoggedIn(true);
            localStorage.setUserData(response.value);
            repo.saveFCMToken(userId: AppLocalStorage.instance.userId);
            emailController.clear();
            passController.clear();
          }
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: response.errorMessage);
          isUserAuthenticated.value = false;
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void register() async {
    isRegisterLoading.value = true;
    update();
    try {
      String? passwordError = validatePassword(registerPassController.text);
      if (passwordError != null) {
        AppSnackbarWidget.showSnackBar(
            isSuccess: false, subTitle: passwordError);
        return;
      }

      if (registerPassController.text != confirmPassController.text) {
        AppSnackbarWidget.showSnackBar(
            isSuccess: false, subTitle: 'Passwords do not match');
        return;
      }

      final response = await repo.register({
        "name": nameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "email": registerEmailController.text.trim(),
        "batch": batchController.text.trim(),
        "password": registerPassController.text.trim(),
        "orgCode": orgCodeController.text.trim()
      });

      switch (response) {
        case AppSuccess():
          AppSnackbarWidget.showSnackBar(
            isSuccess: true,
            subTitle: "Registration Successful",
          );
          Get.toNamed('/login');
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: response.errorMessage);
          isUserAuthenticated.value = false;
          localStorage.setIsUserLoggedIn(false);
          break;
      }
    } catch (e) {
      AppSnackbarWidget.showSnackBar(
          isSuccess: false,
          subTitle: 'Error occured in registeration, try again');
    } finally {
      isRegisterLoading.value = false;
      update();
    }
  }

  void logout() {
    localStorage.clearTokens();
    localStorage.setIsUserLoggedIn(false);
    isUserAuthenticated.value = false;
    update();
  }

  void forgotPassword() {
    ExamRepo repo = ExamRepo();
    repo.forgotPassword(emailController.text);
  }

  @override
  void onClose() {
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    mobileController.dispose();
    registerEmailController.dispose();
    batchController.dispose();
    registerPassController.dispose();
    confirmPassController.dispose();
    orgCodeController.dispose();
    orgSearchController.dispose();
    batchSearchController.dispose();
    super.onClose();
  }
}
