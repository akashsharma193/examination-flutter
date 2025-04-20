import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/controllers/exam_history_controller.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/core/extensions/datetime_extension.dart';
import 'package:crackitx/screens/admin_screen/admin_exam_dashboard.dart';
import 'package:crackitx/widgets/custom_dropdown_widget.dart';

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
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                _buildSearchAndFilterBar(examHistoryController),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                              child: constraints.maxWidth < 600
                                  ? _buildMobileLayout(examHistoryController)
                                  : _buildWebLayout(examHistoryController)),
                        ],
                      );
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
    return Obx(
      () => GridView.builder(
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
      ),
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
