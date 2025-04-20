import 'package:get/instance_manager.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';
import 'package:offline_test_app/controllers/edit_user_detail_controller.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/controllers/home_controller.dart';
import 'package:offline_test_app/controllers/user_list_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppAuthController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}

class ExamHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExamHistoryController());
  }
}

class UserListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserListController());
  }
}

class EditUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditUserDetailController());
  }
}
