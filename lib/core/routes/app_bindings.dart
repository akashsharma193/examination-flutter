import 'package:get/instance_manager.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/controllers/home_controller.dart';

class AppAuthBinding extends Bindings {
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
