import 'package:flutter/material.dart';
import 'package:offline_test_app/core/extensions/app_string_extensions.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/services/app_package_service.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({
    super.key,
  });
  final Map<String, Widget> drawerItems = {
    'Exam History': Icon(Icons.history_toggle_off_rounded),
    'Log Out': Icon(Icons.logout_outlined),
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
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Batch : ' + AppLocalStorage.instance.user.batch),
                SizedBox(
                  width: 20,
                ),
                Text('Org Code : ' + AppLocalStorage.instance.user.orgCode),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 20,
            ),
            ...drawerItems.entries.map((e) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [Text(e.key), e.value],
                      ),
                      const Divider()
                    ],
                  ),
                )),
            Spacer(),
            Divider(),
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
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
