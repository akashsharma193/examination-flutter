import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';
import 'package:offline_test_app/screens/create_exams/date_time_picker_widget.dart';
import 'package:offline_test_app/screens/create_exams/question_list_widget.dart';
import 'package:offline_test_app/screens/create_exams/text_field_widget.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';

class AdminExamDashboard extends StatelessWidget {
  const AdminExamDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Exam",
            style: AppTextStyles.heading.copyWith(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.appBar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const ExamForm(),
          ),
        ),
      ),
      backgroundColor: AppColors.cardBackground,
    );
  }
}

class ExamForm extends StatefulWidget {
  const ExamForm({super.key});

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
  final List<Map<String, dynamic>> _questions = [];
  int examDuration = 5;
  bool isExamSubmitting = false;

  bool _validateQuestions() {
    for (var question in _questions) {
      if (question["question"].trim().isEmpty) return false;
      if (question["options"].any((opt) => (opt as String).trim().isEmpty) ||
          question['options'].length < 4) {
        return false;
      }
      if (question["correctAnswer"].trim().isEmpty) return false;
    }
    return true;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _startTime != null &&
        _endTime != null &&
        _validateQuestions()) {
      if (_questions.isEmpty) {
        AppSnackbarWidget.showSnackBar(
            isSuccess: false,
            subTitle: "At least 1 question should be entered.");
        return;
      }

      Map<String, dynamic> examData = {
        "questionList": _questions,
        "examDuration": examDuration.toString(),
        "subjectName": _subjectController.text,
        "teacherName": _teacherController.text,
        "orgCode": _orgCodeController.text,
        "batch": _batchController.text,
        "startTime": _startTime!.toIso8601String(),
        "endTime": _endTime!.toIso8601String(),
      };

      setState(() => isExamSubmitting = true);
      final result = await ExamRepo().createExam(examData);
      setState(() => isExamSubmitting = false);
      switch (result) {
        case AppSuccess<bool>():
          await AppSnackbarWidget.showSnackBar(
              isSuccess: true, subTitle: "Exam created successfully");
          Get.until((e) => Get.currentRoute == '/home');
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: result.errorMessage);
          break;
      }
    } else {
      AppSnackbarWidget.showSnackBar(
          isSuccess: false,
          subTitle:
              'Exam paper is invalid, kindly cross-check your question and options');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFieldWidget(
                    label: "Subject Name", controller: _subjectController),
                TextFieldWidget(
                    label: "Teacher Name", controller: _teacherController),
                TextFieldWidget(
                    label: "Organization Code", controller: _orgCodeController),
                TextFieldWidget(label: "Batch", controller: _batchController),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                      labelText: "Exam Duration (minutes)"),
                  value: examDuration,
                  items: List.generate(36, (index) => (index + 1) * 5)
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text("$e minutes")))
                      .toList(),
                  onChanged: (value) => setState(() => examDuration = value!),
                ),
                DateTimePickerWidget(
                    label: "Start Time",
                    dateTime:
                        _startTime == null ? '' : _startTime?.formatTime ?? '',
                    onPicked: (date) => setState(() => _startTime = date)),
                DateTimePickerWidget(
                    label: "End Time",
                    dateTime:
                        _endTime == null ? '' : _endTime?.formatTime ?? '',
                    onPicked: (date) => setState(() => _endTime = date)),
                const SizedBox(height: 20),
                QuestionListWidget(questions: _questions),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isExamSubmitting
                        ? const CircularProgressIndicator.adaptive()
                        : const Text("Submit Exam",
                            style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
