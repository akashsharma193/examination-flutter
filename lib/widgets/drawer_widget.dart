import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/core/extensions/app_string_extensions.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/screens/admin_screen/admin_exam_dashboard.dart';
import 'package:crackitx/repositories/auth_repo.dart';
import 'package:crackitx/screens/student_exam_history.dart';
import 'package:crackitx/services/app_package_service.dart';
import 'package:crackitx/widgets/wavy_gradient_background.dart';
import 'package:crackitx/widgets/curvy_left_clipper.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:crackitx/widgets/wavy_gradient_container.dart';

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
      drawerItems['Exam History'] = FeatherIcons.clock;
    }
    if (AppLocalStorage.instance.user.isAdmin) {
      drawerItems['Create Exam'] = FeatherIcons.plus;
    }
    drawerItems.addAll({
      // 'Network Logs': FeatherIcons.activity,
      'Log Out': FeatherIcons.logOut,
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AppLocalStorage.instance.user;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top wavy gradient section with avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(160),
                ),
                child: WavyGradientContainer(
                  height: 240,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.name.getInitials,
                      style: AppTextStyles.heading.copyWith(
                        color: Colors.deepPurple,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email : ${user.email}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Name : ${user.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                if (user.batch.trim().isNotEmpty)
                  Text('Batch : ${user.batch}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Organization : ${user.orgCode}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          // Drawer items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: drawerItems.entries.map((entry) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(entry.key, style: AppTextStyles.body),
                      trailing: Icon(entry.value, color: Colors.black87),
                      onTap: () {
                        switch (entry.key) {
                          case 'Exam History':
                            Get.to(() => StudentExamHistory(
                                  userId: user.userId,
                                ));
                            break;
                          case 'Log Out':
                            final AuthRepo repo = AuthRepo();
                            repo.logOut(userId: user.userId);
                            AppLocalStorage.instance.clearStorage();
                            Get.offAllNamed('/login');
                            break;
                          case 'Create Exam':
                            Get.to(() => const AdminExamDashboard());
                            break;
                        }
                      },
                    ),
                    const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
