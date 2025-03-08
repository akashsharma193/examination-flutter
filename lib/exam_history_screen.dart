import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
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
                            final SingleExamHistoryModel singleItem =
                                examHistoryController
                                    .allAttemptedExamsList[index];
                            return Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onTap: () {
                                    Get.put(TestResultDetailController());
                                    Get.to(() => TestResultScreen(
                                        qId: singleItem.questionId ?? ''));
                                  },
                                  tileColor: Colors.black26,
                                  title: Text(singleItem.subjectName ?? '-'),
                                  subtitle: Text(
                                      'by ${singleItem.teacherName ?? '-'}'),
                                  trailing: SizedBox(
                                    width: 90,
                                    child: Text(
                                      '${singleItem.stratTime?.formatTime} \n ${singleItem.endTime?.formatTime}',
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ));
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
