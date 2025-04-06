import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/controllers/past_exam_detail_controller.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';
import 'package:offline_test_app/screens/admin_screen/create_exams/date_time_picker_widget.dart';
import 'package:offline_test_app/screens/admin_screen/create_exams/question_list_widget.dart';
import 'package:offline_test_app/screens/admin_screen/create_exams/text_field_widget.dart';
import 'package:offline_test_app/screens/test_result_screen.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';

class ViewExamDetails extends StatefulWidget {
  ViewExamDetails({super.key, required this.examHistoryModel});
  final SingleExamHistoryModel examHistoryModel;

  @override
  State<ViewExamDetails> createState() => _ViewExamDetailsState();
}

class _ViewExamDetailsState extends State<ViewExamDetails> {
  List<Widget> _children = [];
  @override
  void initState() {
    super.initState();
    _children = [
      examBasicDetails(examHistoryModel: widget.examHistoryModel),
      AttemptedStudentList(
        qId: widget.examHistoryModel.questionId ?? '-',
        model: widget.examHistoryModel,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Get.width > 400;
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Details',
            style: AppTextStyles.heading.copyWith(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.appBar,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isTablet
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _children,
                )
              : Column(
                  children: _children,
                )),
      backgroundColor: AppColors.cardBackground,
    );
  }
}

class AttemptedStudentList extends StatefulWidget {
  final String qId;
  final SingleExamHistoryModel model;
  const AttemptedStudentList(
      {super.key, required this.qId, required this.model});

  @override
  State<AttemptedStudentList> createState() => _AttemptedStudentListState();
}

class _AttemptedStudentListState extends State<AttemptedStudentList> {
  final PastExamDetailController pastExamDetailController =
      Get.put(PastExamDetailController());
  @override
  void initState() {
    super.initState();
    pastExamDetailController.fetchStudentDetails(widget.qId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width / 3,
      child: GetBuilder<PastExamDetailController>(builder: (controller) {
        return controller.studentList.isEmpty
            ? const Center(
                child: Text('No Student Given Exam yet!'),
              )
            : ListView.builder(
                itemCount: controller.studentList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final student = controller.studentList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {
                        Get.to(TestResultScreen(
                            model: widget.model,
                            userId: student['userId'] ?? '-'));
                      },
                      tileColor: AppColors.secondary,
                      title: Text(student['name'] ?? '-'),
                      subtitle:
                          Text('Total Marks : ${student['marks'] ?? '0'}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  );
                },
              );
      }),
    );
  }
}

class examBasicDetails extends StatelessWidget {
  const examBasicDetails({
    super.key,
    required this.examHistoryModel,
  });

  final SingleExamHistoryModel examHistoryModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width / 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFieldWidget(
            label: "Subject Name",
            text: examHistoryModel.subjectName ?? '-',
            readOnly: true,
          ),
          TextFieldWidget(
            label: "Teacher Name",
            text: examHistoryModel.teacherName ?? '-',
            readOnly: true,
          ),
          TextFieldWidget(
            label: "Organization Code",
            text: examHistoryModel.orgCode ?? '-',
            readOnly: true,
          ),
          TextFieldWidget(
            label: "Batch",
            text: examHistoryModel.batch ?? '-',
            readOnly: true,
          ),
          TextFieldWidget(
            label: "Exam Duration",
            text: '${examHistoryModel.examDuration ?? '-'}',
            readOnly: true,
          ),
          TextFieldWidget(
            label: "Start Time",
            text: examHistoryModel.startTime?.formatTime ?? '-',
            readOnly: true,
          ),
          TextFieldWidget(
            label: "End Time",
            text: examHistoryModel.endTime?.formatTime ?? '-',
            readOnly: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
