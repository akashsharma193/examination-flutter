import 'package:flutter/material.dart';
import 'package:offline_test_app/screens/create_exams/question_card_widget.dart';

class QuestionListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuestionListWidget({super.key, required this.questions});

  @override
  _QuestionListWidgetState createState() => _QuestionListWidgetState();
}

class _QuestionListWidgetState extends State<QuestionListWidget> {
  void _addQuestion() {
    setState(() {
      widget.questions
          .add({"question": "", "options": [], "correctAnswer": ""});
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      widget.questions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.questions.asMap().entries.map((entry) {
          return QuestionCardWidget(
            index: entry.key,
            questionData: entry.value,
            onDelete: () => _removeQuestion(entry.key),
          );
        }).toList(),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addQuestion,
          child: const Text("Add Question"),
        ),
      ],
    );
  }
}
