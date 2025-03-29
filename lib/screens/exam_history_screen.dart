import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/helper.dart';
import 'package:offline_test_app/screens/admin_screen/admin_exam_dashboard.dart';
import 'package:offline_test_app/screens/admin_screen/view_exam_details.dart';
import 'package:offline_test_app/screens/test_result_screen.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';
import '../controllers/test_result_detail_controller.dart';

class ExamHistoryScreen extends StatefulWidget {
  ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamHistoryController>(builder: (examHistoryController) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: AppColors.appBar,
          title: Text(
            Get.arguments?['title'] ?? 'Exam History',
            style: AppTextStyles.heading.copyWith(color: Colors.white),
          ),
        ),
        body: examHistoryController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : examHistoryController.allAttemptedExamsList.isEmpty
                ? Center(
                    child: Text(
                      Get.arguments?['title'] == 'Active Exams'
                          ? 'No Active Exam '
                          : "User hasn't given any exam yet.",
                      style: AppTextStyles.body,
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Check screen width to determine layout
                      if (constraints.maxWidth < 600) {
                        // Mobile layout
                        return _buildMobileLayout(examHistoryController);
                      } else {
                        // Web layout
                        return _buildWebLayout(examHistoryController);
                      }
                    },
                  ),
      );
    });
  }

  // Mobile Layout
  Widget _buildMobileLayout(ExamHistoryController controller) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.allAttemptedExamsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final SingleExamHistoryModel singleItem =
            controller.allAttemptedExamsList[index];
        return _buildExamCard(singleItem, controller);
      },
    );
  }

  // Web Layout
  Widget _buildWebLayout(ExamHistoryController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 cards per row
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2, // Card aspect ratio
      ),
      itemCount: controller.allAttemptedExamsList.length,
      itemBuilder: (context, index) {
        final SingleExamHistoryModel singleItem =
            controller.allAttemptedExamsList[index];
        return _buildExamCard(singleItem, controller);
      },
    );
  }

  // Reusable Exam Card Widget
  Widget _buildExamCard(
      SingleExamHistoryModel singleItem, ExamHistoryController controller) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: controller.isFromGetAllExamTab
            ? () {
                Get.to(() => ViewExamDetails(
                      examHistoryModel: singleItem,
                    ));
              }
            : () {
                Get.put(TestResultDetailController());
                Get.to(() => TestResultScreen(model: singleItem));
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                singleItem.subjectName ?? '-',
                style: AppTextStyles.subheading.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${singleItem.teacherName ?? '-'}',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              Text(
                'Started on: ${singleItem.startTime?.formatTime ?? '-'}',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              Text(
                'End: ${singleItem.endTime?.formatTime ?? '-'}',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 8),
              controller.isFromGetAllExamTab
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          onPressed: () {
                            Get.to(() => AdminExamDashboard(
                                  isEdit: true,
                                  examHistoryModel: singleItem,
                                ));
                          },
                          icon: const Icon(Icons.edit)))
                  : Text(
                      'Total Marks: ${singleItem.batch ?? '-'}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
