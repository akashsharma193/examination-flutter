import 'package:get/get.dart';
import 'package:offline_test_app/app_models/app_user_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/admin_repo.dart';

class UserListController extends GetxController {
  final AdminRepo adminRepo = AdminRepo();
  UserListController();

  var users = <UserModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchUsers(AppLocalStorage.instance.user.orgCode);
    super.onInit();
  }

  void fetchUsers(String orgCode) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await adminRepo.getAllUserList(orgCode: orgCode);

      switch (result) {
        case AppSuccess():
          users.value = result.value;
          break;
        case AppFailure():
          errorMessage.value = 'Failed to load users';
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
