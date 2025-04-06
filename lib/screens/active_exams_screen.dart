import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/screens/admin_screen/admin_exam_dashboard.dart';

class ActiveExamScreen extends StatefulWidget {
  const ActiveExamScreen({super.key});
  @override
  State<ActiveExamScreen> createState() => _ActiveExamScreenState();
}

class _ActiveExamScreenState extends State<ActiveExamScreen> {
  final controller = Get.put(ExamHistoryController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setup(showActiveExam: true, userId: null);
    });
    return GetBuilder<ExamHistoryController>(builder: (examHistoryController) {
      return Scaffold(
        backgroundColor: AppColors.cardBackground,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: const Text('Active Exams')),
        body: examHistoryController.isLoading.value
            ? const Center(child: CircularProgressIndicator.adaptive())
            : examHistoryController.filteredExams.isEmpty
                ? const Center(
                    child: Text(
                      'No Active Exam.',
                      style: AppTextStyles.body,
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return constraints.maxWidth < 600
                          ? _buildMobileLayout(examHistoryController)
                          : _buildWebLayout(examHistoryController);
                    },
                  ),
      );
    });
  }

  Widget _buildMobileLayout(ExamHistoryController controller) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredExams.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final SingleExamHistoryModel singleItem =
            controller.filteredExams[index];
        return _buildExamCard(singleItem, controller);
      },
    );
  }

  Widget _buildWebLayout(ExamHistoryController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemCount: controller.filteredExams.length,
      itemBuilder: (context, index) {
        final SingleExamHistoryModel singleItem =
            controller.filteredExams[index];
        return _buildExamCard(singleItem, controller);
      },
    );
  }

  Widget _buildExamCard(
      SingleExamHistoryModel singleItem, ExamHistoryController controller) {
    return Card(
      elevation: 5,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() =>
            AdminExamDashboard(isEdit: true, examHistoryModel: singleItem)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(singleItem.subjectName ?? '-',
                  style: AppTextStyles.subheading
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('by ${singleItem.teacherName ?? '-'}',
                  style: AppTextStyles.body),
              const SizedBox(height: 8),
              Text('Started on: ${singleItem.startTime?.formatTime ?? '-'}',
                  style: AppTextStyles.body),
              const SizedBox(height: 8),
              Text('End: ${singleItem.endTime?.formatTime ?? '-'}',
                  style: AppTextStyles.body),
              const SizedBox(height: 8),
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: IconButton(
              //       onPressed: () => Get.to(() => AdminExamDashboard(
              //           isEdit: true, examHistoryModel: singleItem)),
              //       icon: const Icon(Icons.edit)),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
