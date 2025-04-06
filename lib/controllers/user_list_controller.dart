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

  RxString searchQuery = ''.obs;

  RxString selectedBatch = ''.obs;

  RxString selectedOrganization = ''.obs;
  List<String> get batches =>
      users.map((e) => e.batch).toSet().where((e) => e.isNotEmpty).toList();

  List<String> get organizationCodes =>
      users.map((e) => e.orgCode).toSet().where((e) => e.isNotEmpty).toList();

  @override
  void onInit() {
    fetchUsers(AppLocalStorage.instance.user.orgCode);
    super.onInit();
  }

  List<UserModel> get filteredUsers {
    return users.where((user) {
      final matchesSearch = user.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesBatch =
          selectedBatch.value.isEmpty || user.batch == selectedBatch.value;
      final matchesOrg = selectedOrganization.value.isEmpty ||
          user.orgCode == selectedOrganization.value;
      return matchesSearch && matchesBatch && matchesOrg;
    }).toList();
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
