import 'package:get/route_manager.dart';
import 'package:offline_test_app/core/constants/app_route_name_constants.dart';
import 'package:offline_test_app/core/routes/app_bindings.dart';
import 'package:offline_test_app/core/routes/middle_wares.dart';
import 'package:offline_test_app/screens/admin_screen/user_edit_page.dart';
import 'package:offline_test_app/screens/exam_history_screen.dart';
import 'package:offline_test_app/screens/exam_screen.dart';
import 'package:offline_test_app/screens/home.dart';
import 'package:offline_test_app/screens/login_page.dart';
import 'package:offline_test_app/screens/splash_screen.dart';
import 'package:offline_test_app/screens/admin_screen/user_list_screen.dart';

class AppRoute {
  static final routes = [
    GetPage(
      name: AppRoutesNames.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
        name: AppRoutesNames.login,
        page: () => const LoginPage(),
        binding: AppBindings(),
        middlewares: [AuthMiddleWare()]),
    GetPage(
        name: AppRoutesNames.home,
        page: () => homePage(),
        binding: HomeBinding()),
    GetPage(
        name: AppRoutesNames.examHistory,
        page: () => const ExamHistoryScreen(),
        binding: ExamHistoryBinding()),
    GetPage(
        name: AppRoutesNames.userList,
        page: () => const UserListScreen(),
        binding: UserListBinding()),
    GetPage(
        name: AppRoutesNames.userList,
        page: () => const UserListScreen(),
        binding: UserListBinding()),
    GetPage(
        name: AppRoutesNames.editUserScreen,
        page: () => EditUserScreen(),
        binding: EditUserBinding()),
    GetPage(
        name: AppRoutesNames.examScreen,
        page: () {
          final args = Get.arguments;
          return ExamScreen(
            questions: args['questions'],
            testId: args['testId'],
            examName: args['name'] ?? 'Untitled Exam',
            examDurationMinutes: args['time'],
          );
        },
        binding: AppBindings()),
  ];
}
