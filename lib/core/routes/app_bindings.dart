import 'package:get/instance_manager.dart';
import 'package:crackitx/controllers/auth_controller.dart';
import 'package:crackitx/controllers/edit_user_detail_controller.dart';
import 'package:crackitx/controllers/exam_history_controller.dart';
import 'package:crackitx/controllers/home_controller.dart';
import 'package:crackitx/controllers/user_list_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AppAuthController(), permanent: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => ExamHistoryController());
    Get.lazyPut(() => UserListController());
    Get.lazyPut(() => EditUserDetailController());
  }
}
