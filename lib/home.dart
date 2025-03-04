import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:offline_test_app/controllers/home_controller.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/drawer_widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('Home'),
          actions: [
            IconButton(
                onPressed: () {
                  controller.initialized ? controller.logOut() : null;
                },
                icon: Icon(Icons.logout_outlined))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Hello, ${AppLocalStorage.instance.user.name}',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 20,
              ),
              if (controller.isLoading.value) Text('Fetching exam details...'),
              Expanded(
                child: controller.allExams.isEmpty
                    ? Center(
                        child: const Text(
                            'No Exams Scheduled for you as of now..'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.allExams.length,
                        itemBuilder: (context, index) {
                          final singleItem = controller.allExams[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                controller.showDialogPopUp();
                              },
                              child: ListTile(
                                tileColor: Colors.black26,
                                title: Text(singleItem.subjectName ?? '-'),
                                subtitle: Text(singleItem.teacherName ?? '-'),
                                trailing: Text(
                                    '${singleItem.stratTime} - ${singleItem.endTime}'),
                              ),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      );
    });
  }
}
