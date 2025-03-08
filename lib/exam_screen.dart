import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/internet_checker_dialog.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';
import 'package:offline_test_app/test_completed_screen.dart';

class ExamScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int examDurationMinutes; // Set exam duration in minutes
  final String testId;
  final String examName;
  const ExamScreen({
    super.key,
    required this.testId,
    required this.examName,
    required this.questions,
    this.examDurationMinutes = 30, // Default: 30 minutes
  });
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> questionList = [];
  int currentQuestionIndex = 0;

  late Timer _timer;
  int remainingSeconds = 0;

  int warningCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    questionList = widget.questions.map((e) => e.toJson()).toList();

    // Initialize Timer
    remainingSeconds = widget.examDurationMinutes * 60;
    startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("appLife scycle changes  : ${state.name}");
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // User switched apps or minimized the app
      warningCount++;

      if (warningCount >= 4) {
        Get.to(() => TestCompletedScreen(
            list: questionList
                .map(
                    (e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
            testID: widget.testId));
        // autoSubmitExam();

        // Auto-submit on 4th warning
      }
    }

    if (state == AppLifecycleState.resumed) {
      log("sate resume  : $warningCount");
      // Show warning when user comes back
      if (warningCount > 0 && warningCount < 4) {
        log("showing dialog...");
        _showWarningDialog();
      }
    }
  }

  void _showWarningDialog() {
    Get.closeAllSnackbars();

    Get.dialog(
      AlertDialog(
        title: Text("Warning!"),
        content: Text(
            "You switched apps or minimized the exam.\nWarning: $warningCount/3"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// **⏳ Start Countdown Timer**
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        ExamRepo repo = ExamRepo();
        repo.submitExam(
            questionList.map((e) => QuestionModel.fromJson(e)).toList(),
            widget.testId);
        Get.offAllNamed('/home');
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return "$minutes:${sec.toString().padLeft(2, '0')}";
  }

  void selectAnswer(String answer) {
    setState(() {
      questionList[currentQuestionIndex]["userAnswer"] = answer;
    });
  }

  void pvsQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void nextQuestion(BuildContext myContext) {
    if (currentQuestionIndex < questionList.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      ExamRepo repo = ExamRepo();

      Get.dialog(
          AlertDialog(
            title: Text("Test Completed"),
            content: Text(
                'Turn on Internet \nDo you want to submit TEST , Attempted ${questionList.map((e) => e['userAnswer'] != null && e['userAnswer'].isNotEmpty).toList().length}/${questionList.length} '),
            actions: [
              TextButton(
                onPressed: () {
                  Get.offAll(() => TestCompletedScreen(
                      list: questionList
                          .map((e) => QuestionModel.fromJson(
                              Map<String, dynamic>.from(e)))
                          .toList(),
                      testID: widget.testId));
                },
                child: Text("OK"),
              )
            ],
          ),
          barrierDismissible: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion = questionList[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examName),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "⏳ ${formatTime(remainingSeconds)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(top: BorderSide(color: Colors.black26)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(questionList.length, (index) {
                    bool isSelected = index == currentQuestionIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentQuestionIndex = index;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Q ${currentQuestionIndex + 1}/${questionList.length}: ${currentQuestion["question"]}",
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
            Row(
              mainAxisAlignment: currentQuestionIndex == 0
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex != 0)
                  ElevatedButton(
                    onPressed: pvsQuestion,
                    child: Text("Previous"),
                  ),
                ElevatedButton(
                  onPressed: () => nextQuestion(context),
                  child: Text(currentQuestionIndex == questionList.length - 1
                      ? "Submit"
                      : "Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
