import 'package:get/route_manager.dart';
import 'package:crackitx/core/constants/app_route_name_constants.dart';
import 'package:crackitx/core/routes/app_bindings.dart';
import 'package:crackitx/core/routes/middle_wares.dart';
import 'package:crackitx/screens/admin_screen/user_edit_page.dart';
import 'package:crackitx/screens/exam_screen.dart';
import 'package:crackitx/screens/home.dart';
import 'package:crackitx/screens/login_page.dart';
import 'package:crackitx/screens/splash_screen.dart';
import 'package:crackitx/screens/admin_screen/user_list_screen.dart';
import 'package:crackitx/screens/admin_screen/admin_exam_dashboard.dart';
import 'package:crackitx/screens/active_exams_screen.dart';
import 'package:crackitx/screens/admin_screen/e_resource_screen.dart';
import 'package:crackitx/screens/register_screen.dart';

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
      middlewares: [AuthMiddleWare()],
    ),
    GetPage(
      name: AppRoutesNames.register,
      page: () => const RegistrationPage(),
      binding: AppBindings(),
    ),
    GetPage(
      name: AppRoutesNames.home,
      page: () => homePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutesNames.userList,
      page: () => const UserListScreen(),
      binding: UserListBinding(),
    ),
    GetPage(
      name: AppRoutesNames.editUserScreen,
      page: () => const EditUserScreen(),
      binding: EditUserBinding(),
    ),
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
      binding: AppBindings(),
    ),
    GetPage(
      name: AppRoutesNames.adminExamDashboard,
      page: () => const AdminExamDashboard(),
      binding: AppBindings(),
    ),
    GetPage(
      name: AppRoutesNames.activeExams,
      page: () => const ActiveExamScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: AppRoutesNames.eResources,
      page: () => const EResourceScreen(),
      binding: AppBindings(),
    ),
  ];
}
