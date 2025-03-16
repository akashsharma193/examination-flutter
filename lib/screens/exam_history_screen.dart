import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/screens/test_result_screen.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import '../controllers/test_result_detail_controller.dart';

class ExamHistoryScreen extends StatelessWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamHistoryController>(builder: (examHistoryController) {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: AppColors.appBar,
            title: Text(
              'History',
              style: AppTextStyles.heading.copyWith(color: Colors.white),
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
                          child: Text(
                            "You haven't given any exam yet..",
                            style: AppTextStyles.body,
                          ),
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
                                    Get.to(() =>
                                        TestResultScreen(model: singleItem));
                                  },
                                  tileColor: AppColors.cardBackground,
                                  title: Text(
                                    singleItem.subjectName ?? '-',
                                    style: AppTextStyles.subheading,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'by ${singleItem.teacherName ?? '-'}',
                                        style: AppTextStyles.body,
                                      ),
                                      Text(
                                        'Started on : ${singleItem.stratTime?.formatTime ?? '-'}',
                                        style: AppTextStyles.body,
                                      ),
                                    ],
                                  ),
                                  trailing: SizedBox(
                                    width: 90,
                                    child: Text(
                                      'End :${singleItem.endTime?.formatTime}',
                                      textAlign: TextAlign.end,
                                      style: AppTextStyles.body,
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
