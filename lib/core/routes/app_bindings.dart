import 'package:get/instance_manager.dart';
import 'package:offline_test_app/controllers/auth_controller.dart';

class AppAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppAuthController());
  }
}
