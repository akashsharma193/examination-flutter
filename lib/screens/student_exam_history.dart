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
import 'package:crackitx/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

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
  String? selectedTeacher;
  String? selectedTestName;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  List<String> get teacherNames => controller.allAttemptedExamsList
      .map((e) => e.teacherName ?? '')
      .toSet()
      .where((e) => e.isNotEmpty)
      .toList();
  List<String> get testNames => controller.allAttemptedExamsList
      .map((e) => e.subjectName ?? '')
      .toSet()
      .where((e) => e.isNotEmpty)
      .toList();

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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              padding: const EdgeInsets.only(top: 36, left: 16, right: 16, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Exam History',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.only(right: 8),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) => searchQuery.value = value,
                            style: const TextStyle(color: Colors.black38),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(Icons.search, color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_alt_rounded, color: Colors.black),
                          onPressed: () {
                            _showFilterDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                  : Obx(() {
                      final filteredList = controller.allAttemptedExamsList.where((exam) {
                        final name = (exam.subjectName ?? '').toLowerCase();
                        final teacher = (exam.teacherName ?? '').toLowerCase();
                        final query = searchQuery.value.toLowerCase();
                        final matchesSearch = name.contains(query) || teacher.contains(query);
                        final matchesTeacher = selectedTeacher == null || selectedTeacher == '' || teacher == selectedTeacher!.toLowerCase();
                        final matchesTest = selectedTestName == null || selectedTestName == '' || name == selectedTestName!.toLowerCase();
                        final matchesStart = selectedStartDate == null || (exam.startTime != null && !exam.startTime!.isBefore(selectedStartDate!));
                        final matchesEnd = selectedEndDate == null || (exam.endTime != null && !exam.endTime!.isAfter(selectedEndDate!));
                        return matchesSearch && matchesTeacher && matchesTest && matchesStart && matchesEnd;
                      }).toList();
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
                    }));
    });
  }

  void _showFilterDialog(BuildContext context) async {
    String? tempTeacher = selectedTeacher;
    String? tempTest = selectedTestName;
    DateTime? tempStart = selectedStartDate;
    DateTime? tempEnd = selectedEndDate;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter by', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
               
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempTeacher,
                    hint: const Text('Teacher Name'),
                    items: teacherNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                    onChanged: (val) => setState(() => tempTeacher = val),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempStart ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => tempStart = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(tempStart == null ? '' : DateFormat('dd MMM yyyy').format(tempStart!)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempEnd ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setState(() => tempEnd = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(tempEnd == null ? '' : DateFormat('dd MMM yyyy').format(tempEnd!)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cardBackground,
                          side: BorderSide(color: AppColors.cardBackground),
                        ),
                        onPressed: () {
                          setState(() {
                            tempTeacher = null;
                            tempTest = null;
                            tempStart = null;
                            tempEnd = null;
                            selectedTeacher = null;
                            selectedTestName = null;
                            selectedStartDate = null;
                            selectedEndDate = null;
                          });
                          Navigator.pop(context);
                          setState(() {}); // Refresh the filtered list
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedTeacher = tempTeacher;
                            selectedTestName = tempTest;
                            selectedStartDate = tempStart;
                            selectedEndDate = tempEnd;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    setState(() {}); // Refresh the filtered list
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
    return InkWell(
      onTap: () {
        Get.to(() => TestResultScreen(
              model: singleItem,
              userId: widget.userId,
            
            ));
      },
      child: Card(
        elevation: 5,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top title/score bar
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFD3D3D3), // Light gray
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomRight: Radius.circular(40), // Large curve
              ),
            ),
            child: Text(
              'Test ${singleItem.subjectName ?? ''} Scored: ${singleItem.totalMarks}/${singleItem.totalQuestion}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          // Main content
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'by ${singleItem.teacherName ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Started on: ${singleItem.startTime?.formatTime ?? '-'} End:',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  singleItem.endTime?.formatTime ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

