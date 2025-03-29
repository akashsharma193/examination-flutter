import 'package:flutter/material.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/helper.dart';
import 'package:offline_test_app/screens/admin_screen/create_exams/question_card_widget.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';

class QuestionListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final bool isEditable;
  const QuestionListWidget(
      {super.key, required this.questions, this.isEditable = true});

  @override
  QuestionListWidgetState createState() => QuestionListWidgetState();
}

class QuestionListWidgetState extends State<QuestionListWidget> {
  void _addQuestion() {
    setState(() {
      widget.questions
          .add({"question": "", "options": [], "correctAnswer": ""});
    });
  }

  void importQuestion() async {
    List<Map<String, dynamic>> data =
        (await importQuestionsFromExcel()).map((e) => e.toJson()).toList();
    for (var e in data) {
      e['correctAnswerIndex'] =
          (e['options'] as List).indexWhere((x) => e['correctAnswer'] == x);
    }
    setState(() {
      widget.questions.addAll(data);
    });
  }

  void _removeQuestion(int index) {
    if (!widget.isEditable) {
      AppSnackbarWidget.showSnackBar(
          isSuccess: false, subTitle: 'Unable to delete in View Mode');
      return;
    }
    setState(() {
      widget.questions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...widget.questions.asMap().entries.map((entry) {
            return QuestionCardWidget(
              index: entry.key,
              questionData: entry.value,
              onDelete: () => _removeQuestion(entry.key),
            );
          }),
          const SizedBox(height: 10),
          if (widget.isEditable)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _addQuestion,
                    child: const Text("Add Question"),
                  ),
                  ElevatedButton(
                    onPressed: importQuestion,
                    child: const Text("import from excel"),
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
