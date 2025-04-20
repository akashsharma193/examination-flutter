import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/controllers/exam_history_controller.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/core/extensions/datetime_extension.dart';
import 'package:crackitx/screens/test_result_screen.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import '../controllers/test_result_detail_controller.dart';

class StudentExamHistory extends StatefulWidget {
  const StudentExamHistory({super.key, this.userId = ''});
  final String userId;
  @override
  State<StudentExamHistory> createState() => _StudentExamHistoryState();
}

class _StudentExamHistoryState extends State<StudentExamHistory> {
  final controller = Get.put(ExamHistoryController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setup(showActiveExam: false, userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamHistoryController>(builder: (examHistoryController) {
      return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: AppColors.appBar,
            title: const Text(
              'Exam History',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: examHistoryController.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : examHistoryController.allAttemptedExamsList.isEmpty
                  ? const Center(
                      child: Text(
                        "User hasn't given any exam yet.",
                        style: AppTextStyles.body,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildMobileLayout(examHistoryController);
                      },
                    ));
    });
  }

  // Mobile Layout
  Widget _buildMobileLayout(
    ExamHistoryController controller,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
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
  Widget _buildWebLayout(
      ExamHistoryController controller, bool isPastExamsScreen) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 cards per row
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2, // Card aspect ratio
      ),
      itemCount: controller.allAttemptedExamsList.length,
      itemBuilder: (context, index) {
        final SingleExamHistoryModel singleItem =
            controller.allAttemptedExamsList[index];
        return _buildExamCard(
          singleItem,
          controller,
        );
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
        onTap: () {
          Get.put(TestResultDetailController());

          Get.to(() => TestResultScreen(
                model: singleItem,
                userId: singleItem.userId ?? '',
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    singleItem.subjectName ?? '-',
                    style: AppTextStyles.subheading.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.fade),
                  ),
                  Text(
                    'Scored: ${singleItem.totalMarks}/${singleItem.totalQuestion}',
                    style: AppTextStyles.subheading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}
