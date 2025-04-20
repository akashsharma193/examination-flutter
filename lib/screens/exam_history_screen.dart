import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/screens/admin_screen/view_exam_details.dart';
import 'package:offline_test_app/screens/test_result_screen.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/widgets/custom_dropdown_widget.dart';
import '../controllers/test_result_detail_controller.dart';

class PastExamScreen extends StatefulWidget {
  const PastExamScreen({super.key, this.userId = ''});
  final String userId;
  @override
  State<PastExamScreen> createState() => _PastExamScreenState();
}

class _PastExamScreenState extends State<PastExamScreen> {
  final controller = Get.put(ExamHistoryController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setup(
          showActiveExam: false,
          userId: widget.userId.isEmpty ? null : widget.userId);
    });
    return GetBuilder<ExamHistoryController>(builder: (examHistoryController) {
      return Scaffold(
        backgroundColor: AppColors.cardBackground,
        appBar: widget.userId.isEmpty
            ? null
            : AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  'Past Exams',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.appBar,
              ),
        body: examHistoryController.isLoading.value
            ? const Center(child: CircularProgressIndicator.adaptive())
            : examHistoryController.filteredExams.isEmpty
                ? Center(
                    child: Text(
                      widget.userId.isEmpty
                          ? 'No exams'
                          : "User hasn't given any exam yet.",
                      style: AppTextStyles.body,
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              _buildSearchAndFilterBar(examHistoryController),
                        ),
                        Expanded(
                            child: constraints.maxWidth < 600
                                ? Obx(() =>
                                    _buildMobileLayout(examHistoryController))
                                : Obx(() =>
                                    _buildWebLayout(examHistoryController)))
                      ]);
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
        return _buildExamCard(singleItem, controller, false);
      },
    );
  }

  Widget _buildWebLayout(ExamHistoryController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.9,
      ),
      itemCount: controller.filteredExams.length,
      itemBuilder: (context, index) {
        final SingleExamHistoryModel singleItem =
            controller.filteredExams[index];
        return _buildExamCard(singleItem, controller, false);
      },
    );
  }

  Widget _buildExamCard(SingleExamHistoryModel singleItem,
      ExamHistoryController controller, bool isPastExamsScreen) {
    return Card(
      color: AppColors.cardBackground,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: controller.isFromGetAllExamTab
            ? () => Get.to(() => ViewExamDetails(examHistoryModel: singleItem))
            : () {
                Get.put(TestResultDetailController());
                Get.to(() => TestResultScreen(
                    model: singleItem, userId: singleItem.userId ?? ''));
              },
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
              Text(
                  widget.userId.isEmpty
                      ? ""
                      : 'Total Marks: ${singleItem.totalMarks}/${singleItem.totalQuestion}',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(ExamHistoryController controller) {
    final textController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 🔍 Search bar
            Expanded(
              flex: 3,
              child: TextField(
                controller: textController,
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 🔎 Batch Filter
            Expanded(
              flex: 2,
              child: MyDropdownMenuStateful(
                  batches: controller.batches,
                  onSelect: (s) => controller.selectedBatch.value = s ?? ''),
            ),
            const SizedBox(width: 10),

            // ❌ Clear Filters
            ElevatedButton.icon(
              onPressed: () {
                controller.searchQuery.value = '';
                controller.selectedBatch.value = '';
                controller.selectedOrganization.value = '';
                textController.clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
