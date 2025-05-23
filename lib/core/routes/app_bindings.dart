import 'package:get/instance_manager.dart';
import 'package:crackitx/controllers/auth_controller.dart';
import 'package:crackitx/controllers/edit_user_detail_controller.dart';
import 'package:crackitx/controllers/exam_history_controller.dart';
import 'package:crackitx/controllers/home_controller.dart';
import 'package:crackitx/controllers/user_list_controller.dart';

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
