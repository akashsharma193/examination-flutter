import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';

class ExamScreen extends StatefulWidget {
  final List<QuestionModel> questions;

  const ExamScreen({super.key, required this.questions});
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<Map<String, dynamic>> questionList = [];

  int currentQuestionIndex = 0;

  void selectAnswer(String answer) {
    setState(() {
      questionList[currentQuestionIndex]["userAnswer"] = answer;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questionList.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Show result or submit
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Test Completed"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: questionList.map((e) => Text(e['userAnswer'])).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.until((s) => Get.currentRoute == '/home');
              },
              child: Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    questionList = widget.questions.map((e) => e.toJson()).toList();
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion = questionList[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("सामान्य ज्ञान परीक्षा")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "प्रश्न ${currentQuestionIndex + 1}/${questionList.length}: ${currentQuestion["question"]}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Column(
              children:
                  List<String>.from(currentQuestion["option"]).map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: currentQuestion["userAnswer"],
                  onChanged: (value) {
                    selectAnswer(value!);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextQuestion,
              child: Text(currentQuestionIndex == questionList.length - 1
                  ? "Submit"
                  : "Next"),
            ),
          ],
        ),
      ),
    );
  }
}
