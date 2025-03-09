import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:offline_test_app/controllers/home_controller.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/widgets/drawer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Scaffold(
        drawer: AppDrawer(),
        floatingActionButton: FloatingActionButton.small(
            child: const Icon(Icons.refresh),
            onPressed: () {
              controller.refreshPage();
            }),
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
                onPressed: () {
                  controller.initialized ? controller.logOut() : null;
                },
                icon: const Icon(Icons.logout_outlined))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Hello, ${AppLocalStorage.instance.user.name}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(
                height: 20,
              ),
              if (controller.isLoading.value)
                const Text('Fetching exam details...'),
              Expanded(
                child: controller.allExams.isEmpty
                    ? const Center(
                        child: Text('No Exams Scheduled for you as of now..'),
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
                                controller.selectedExam =
                                    controller.allExams[index];
                                controller.showDialogPopUp();
                              },
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  tileColor: Colors.black26,
                                  title: Text(singleItem.subjectName ?? '-'),
                                  subtitle: Text(
                                      'by ${singleItem.teacherName ?? '-'}'),
                                  trailing: SizedBox(
                                    width: 140,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Start Time : ${singleItem.stratTime?.formatTime}',
                                          textAlign: TextAlign.end,
                                        ),
                                        Obx(
                                          () => Text(
                                            'Exam  starts in : ${controller.examTimers[singleItem.questionId] ?? 'Calculating...'}',
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
