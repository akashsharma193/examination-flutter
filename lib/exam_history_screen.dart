import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/test_result_screen.dart';

import 'controllers/test_result_detail_controller.dart';

class ExamHistoryScreen extends StatelessWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamHistoryController>(builder: (examHistoryController) {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'History',
            ),
          ),
          body: examHistoryController.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: examHistoryController.allAttemptedExamsList.isEmpty
                      ? const Center(
                          child: Text("You haven't given any exam yet.."),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            final singleItem = examHistoryController
                                .allAttemptedExamsList[index];
                            return ListTile(
                              onTap: (){
                                Get.put(TestResultDetailController());
                                Get.to(()=>TestResultScreen(qId: singleItem.questionId));
                              },
                              tileColor: Colors.black26,
                              title: Text(singleItem.subjectName ?? '-'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(singleItem.teacherName ?? '-'),
                                  Text(singleItem.questionId ?? '-'),
                                ],
                              ),
                              trailing: Text(
                                  '${singleItem.stratTime} - ${singleItem.endTime}'),
                            );
                          },
                          separatorBuilder: (context, ind) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Divider(),
                            );
                          },
                          itemCount: examHistoryController
                              .allAttemptedExamsList.length),
                ));
    });
  }
}
