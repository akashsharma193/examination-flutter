import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';
import 'package:offline_test_app/screens/admin_screen/create_exams/date_time_picker_widget.dart';
import 'package:offline_test_app/screens/admin_screen/create_exams/question_list_widget.dart';
import 'package:offline_test_app/screens/admin_screen/create_exams/text_field_widget.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';

class ViewExamDetails extends StatelessWidget {
  const ViewExamDetails({super.key, this.examHistoryModel});
  final SingleExamHistoryModel? examHistoryModel;
  @override
  Widget build(BuildContext context) {
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
        child: ExamForm(
          examHistoryModel: examHistoryModel,
        ),
      ),
      backgroundColor: AppColors.cardBackground,
    );
  }
}

class ExamForm extends StatefulWidget {
  const ExamForm({super.key, this.examHistoryModel});

  final SingleExamHistoryModel? examHistoryModel;

  @override
  ExamFormState createState() => ExamFormState();
}

class ExamFormState extends State<ExamForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _orgCodeController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  List<Map<String, dynamic>> _questions = [];
  int examDuration = 5;

  @override
  void initState() {
    super.initState();
    _subjectController.value =
        TextEditingValue(text: widget.examHistoryModel?.subjectName ?? '');
    _teacherController.value =
        TextEditingValue(text: widget.examHistoryModel?.teacherName ?? '');
    _orgCodeController.value =
        TextEditingValue(text: widget.examHistoryModel?.orgCode ?? '');
    _batchController.value =
        TextEditingValue(text: widget.examHistoryModel?.batch ?? '');

    _startTime = widget.examHistoryModel?.startTime;
    _endTime = widget.examHistoryModel?.endTime;
    examDuration = widget.examHistoryModel?.examDuration ?? 5;
    _questions =
        widget.examHistoryModel?.questionList.map((e) => e.toJson()).toList() ??
            [];

    for (var e in _questions) {
      e['correctAnswerIndex'] =
          (e['options'] as List).indexWhere((x) => e['correctAnswer'] == x);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: Get.width / 2 - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldWidget(
                      label: "Subject Name", controller: _subjectController),
                  TextFieldWidget(
                      label: "Teacher Name", controller: _teacherController),
                  TextFieldWidget(
                      label: "Organization Code",
                      controller: _orgCodeController),
                  TextFieldWidget(label: "Batch", controller: _batchController),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                        labelText: "Exam Duration (minutes)"),
                    value: examDuration,
                    items: List.generate(36, (index) => (index + 1) * 5)
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text("$e minutes")))
                        .toList(),
                    onChanged: (value) => setState(() => examDuration = value!),
                  ),
                  DateTimePickerWidget(
                      label: "Start Time",
                      dateTime: _startTime == null
                          ? ''
                          : _startTime?.formatTime ?? '',
                      onPicked: (date) => setState(() => _startTime = date)),
                  DateTimePickerWidget(
                      label: "End Time",
                      dateTime:
                          _endTime == null ? '' : _endTime?.formatTime ?? '',
                      onPicked: (date) => setState(() => _endTime = date)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(
                width: Get.width / 2 - 100,
                child: QuestionListWidget(
                  questions: _questions,
                  isEditable: false,
                )),
          ],
        ),
      ),
    );
  }
}
