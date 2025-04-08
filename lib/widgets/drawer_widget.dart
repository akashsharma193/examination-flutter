import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/app_string_extensions.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/screens/admin_screen/admin_exam_dashboard.dart';
import 'package:offline_test_app/screens/network_log_screen.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';
import 'package:offline_test_app/screens/student_exam_history.dart';
import 'package:offline_test_app/services/app_package_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Map<String, IconData> drawerItems = {};

  @override
  void initState() {
    super.initState();

    if (!AppLocalStorage.instance.user.isAdmin) {
      drawerItems['Exam History'] = Icons.history_toggle_off_rounded;
    }
    if (AppLocalStorage.instance.user.isAdmin) {
      drawerItems['Create Exam'] = Icons.add;
    }
    drawerItems.addAll({
      'Network Logs': Icons.bug_report,
      'Log Out': Icons.logout_outlined,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.dialogBackground,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  AppLocalStorage.instance.user.name.getInitials,
                  style: AppTextStyles.heading.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Batch: ${AppLocalStorage.instance.user.batch}',
                style: AppTextStyles.body),
            Text('Org Code: ${AppLocalStorage.instance.user.orgCode}',
                style: AppTextStyles.body),
            Text('User ID: ${AppLocalStorage.instance.user.userId}',
                style: AppTextStyles.body),
            Text('Email: ${AppLocalStorage.instance.user.email}',
                style: AppTextStyles.body),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            ...drawerItems.entries.map((entry) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: () {
                      switch (entry.key) {
                        case 'Exam History':
                          Get.to(() => StudentExamHistory(
                                userId: AppLocalStorage.instance.user.userId,
                              ));
                          break;
                        case 'Network Logs':
                          Get.to(() => const NetworkLogScreen());
                          break;
                        case 'Log Out':
                          final AuthRepo repo = AuthRepo();
                          repo.logOut(
                              userId: AppLocalStorage.instance.user.userId);
                          AppLocalStorage.instance.clearStorage();
                          Get.offAllNamed('/login');
                          break;
                        case 'Create Exam':
                          Get.to(() => const AdminExamDashboard());
                          break;
                      }
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: AppTextStyles.subheading),
                            Icon(entry.value, color: AppColors.primary),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                )),
            const Spacer(),
            const Divider(),
            FutureBuilder(
                future: AppPackageService.instance.initialize(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: Column(
                      children: [
                        Text(AppPackageService.instance.appName,
                            style: AppTextStyles.body),
                        Text(AppPackageService.instance.appVersion,
                            style: AppTextStyles.body),
                      ],
                    ),
                  );
                }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
