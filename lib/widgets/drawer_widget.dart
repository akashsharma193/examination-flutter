import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/core/extensions/app_string_extensions.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/screens/network_log_screen.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';
import 'package:offline_test_app/services/app_package_service.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({
    super.key,
  });
  final Map<String, Widget> drawerItems = {
    'Exam History': const Icon(Icons.history_toggle_off_rounded),
    'Network Logs': const Icon(Icons.bug_report),
    'Log Out': const Icon(Icons.logout_outlined),
  };

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueGrey[200],
              child: Text(AppLocalStorage.instance.user.name.getInitials),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Batch : ${AppLocalStorage.instance.user.batch}'),
                const SizedBox(
                  width: 20,
                ),
                Text('Org Code : ${AppLocalStorage.instance.user.orgCode}'),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(AppLocalStorage.instance.user.userId),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            const SizedBox(
              height: 20,
            ),
            ...drawerItems.entries.map((e) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      if (e.key == 'Exam History') {
                        Get.toNamed('/exam-history');
                      } else if (e.key == 'Network Logs') {
                        Get.to(() => NetworkLogScreen());
                      } else if (e.key == 'Log Out') {
                        final AuthRepo repo = AuthRepo();
                        repo.logOut(
                            userId: AppLocalStorage.instance.user.userId);
                        AppLocalStorage.instance.clearStorage();
                        Get.offAllNamed('/login');
                      }
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [Text(e.key), e.value],
                        ),
                        const Divider()
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
                  return Column(
                    children: [
                      Text(AppPackageService.instance.appName),
                      Text(AppPackageService.instance.appVersion),
                    ],
                  );
                }),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
