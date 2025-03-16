import 'package:get/route_manager.dart';
import 'package:offline_test_app/core/routes/app_bindings.dart';
import 'package:offline_test_app/core/routes/middle_wares.dart';
import 'package:offline_test_app/screens/exam_history_screen.dart';
import 'package:offline_test_app/screens/exam_screen.dart';
import 'package:offline_test_app/screens/home.dart';

import 'package:offline_test_app/screens/login_page.dart';
import 'package:offline_test_app/screens/splash_screen.dart';

class AppRoute {
  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashScreen(),
    ),
    GetPage(
        name: '/login',
        page: () => const LoginPage(),
        binding: AppBindings(),
        middlewares: [AuthMiddleWare()]),
    GetPage(
        name: '/home', page: () => const HomePage(), binding: HomeBinding()),
    GetPage(
        name: '/exam-history',
        page: () => const ExamHistoryScreen(),
        binding: ExamHistoryBinding()),
    GetPage(
        name: '/exam-screen',
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

//
// import 'package:go_router/go_router.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:offline_test_app/exam_history_screen.dart';
// import 'package:offline_test_app/exam_screen.dart';
// import 'package:offline_test_app/home.dart';
// import 'package:offline_test_app/main.dart';
//
// import 'middle_wares.dart';
//
// final GoRouter router = GoRouter(
//   routes: [
//     /// Login Route (With Auth Middleware)
//     GoRoute(
//       path: '/',
//       builder: (context, state) => LoginPage(),
//       redirect: (context, state) => AuthMiddleWare().redirect(context, state),
//     ),
//
//     /// Home Route
//     GoRoute(
//       path: '/home',
//       builder: (context, state) => HomePage(),
//     ),
//
//     /// Exam History Route
//     GoRoute(
//       path: '/exam-history',
//       builder: (context, state) => ExamHistoryScreen(),
//     ),
//
//     /// Exam Screen Route (With Internet Middleware)
//     GoRoute(
//       path: '/exam-screen',
//       builder: (context, state) {
//         final args = state.extra as Map<String, dynamic>? ?? {};
//         return ExamScreen(
//           questions: args['questions'],
//           testId: args['testId'],
//           examName: args['name'] ?? 'Untitled Exam',
//         );
//       },
//       redirect: (context, state) => InternetCheckMiddleware().redirect(context, state),
//     ),
//   ],
// );
