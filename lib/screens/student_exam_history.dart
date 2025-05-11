import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/controllers/exam_history_controller.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/core/extensions/datetime_extension.dart';
import 'package:crackitx/screens/test_result_screen.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import '../controllers/test_result_detail_controller.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';

class StudentExamHistory extends StatefulWidget {
  const StudentExamHistory({super.key, this.userId = ''});
  final String userId;
  @override
  State<StudentExamHistory> createState() => _StudentExamHistoryState();
}

class _StudentExamHistoryState extends State<StudentExamHistory> {
  final controller = Get.put(ExamHistoryController());
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

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
          appBar: GradientAppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exam History',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) => searchQuery.value = value,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.15),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
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
                  : Column(
                      children: [
                        Expanded(
                          child: Obx(() {
                            final filteredList = controller.allAttemptedExamsList.where((exam) {
                              final name = (exam.subjectName ?? '').toLowerCase();
                              final query = searchQuery.value.toLowerCase();
                              return name.contains(query);
                            }).toList();
                            return _buildMobileLayoutFiltered(controller, filteredList);
                          }),
                        ),
                      ],
                    ));
    });
  }

  Widget _buildMobileLayoutFiltered(ExamHistoryController controller, List<SingleExamHistoryModel> filteredList) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final singleItem = filteredList[index];
        return _buildExamCard(singleItem, controller);
      },
    );
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

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              // Add filter options here (date, start date, end date, teacher name)
              // For now, just show placeholders
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Date'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Start Date'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.stop),
                title: const Text('End Date'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Teacher Name'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
