import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/internet_checker_dialog.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class ExamScreen extends StatefulWidget {
  final List<QuestionModel> questions;
  final int examDurationMinutes; // Set exam duration in minutes
  final String testId;
  const ExamScreen({
    super.key,
    required this.testId,
    required this.questions,
    this.examDurationMinutes = 30, // Default: 30 minutes
  });
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> questionList = [];
  int currentQuestionIndex = 0;
  bool isInternetActive = false;
  late Stream<ConnectivityResult> _connectivityStream;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

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

    // Correctly handling the updated stream type
    _connectivityStream = Connectivity().onConnectivityChanged.map((results) {
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    });
    _connectivitySubscription = _connectivityStream.listen(_checkConnectivity);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached && warningCount <= 4) {
      // User switched apps or minimized the app
      warningCount++;

      if (warningCount >= 4) {
        _connectivityStream.listen((v) {
          if (v == ConnectivityResult.mobile || v == ConnectivityResult.wifi) {
            autoSubmitExam();
          } else {
            InternetCheckDialog.show(context, autoSubmitExam);
          }
        });
        // Auto-submit on 4th warning
      }
    }

    if (state == AppLifecycleState.resumed) {
      // Show warning when user comes back
      if (warningCount > 0 && warningCount < 4) {
        _showWarningDialog();
      }
    }
  }

  void _showWarningDialog() {
    if (Get.isDialogOpen ?? false) {
      return;
    }
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

  void autoSubmitExam() {
    ExamRepo examRepo = ExamRepo();
    examRepo.submitExam(widget.questions, widget.testId);
    Get.dialog(
      AlertDialog(
        title: Text("Test Auto-Submitted"),
        content: Text("Your test has been submitted automatically."),
        actions: [
          TextButton(
            onPressed: () {
              Get.offAllNamed('/home');
            },
            child: Text("OK"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _connectivityStream.drain();
    _connectivitySubscription.cancel();
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

  void _checkConnectivity(ConnectivityResult result) {
    bool hasInternet = result != ConnectivityResult.none;
    if (hasInternet) {
      if (!isInternetActive) {
        isInternetActive = true;
        if (Get.currentRoute == '/exam-screen') {
          _showInternetNotAllowedDialog();
        }
      }
    } else {
      isInternetActive = false;
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close dialog when internet is disconnected
      }
    }
  }

  void _showInternetNotAllowedDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
        child: AlertDialog(
          title: Text("Internet Not Allowed"),
          content: Text(
              "Please disconnect from the internet to continue to the Exam."),
          actions: [
            TextButton(
              onPressed: () {
                if (!isInternetActive) {
                  Get.back(); // Close only if internet is off
                }
              },
              child: Text("OK"),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Prevent tap outside dismissal
    );
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
                'Do you want to submit TEST , Attempted ${questionList.map((e) => e['userAnswer'] != null && e['userAnswer'].isNotEmpty).toList().length}/${questionList.length} '),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  _connectivityStream.listen((v) {
                    log("connection : $v");
                    if (v == ConnectivityResult.mobile ||
                        v == ConnectivityResult.wifi) {
                      print("submitting exam");
                      repo.submitExam(
                          questionList
                              .map((e) => QuestionModel.fromJson(e))
                              .toList(),
                          widget.testId);
                      Get.offAllNamed('/home');
                    } else {
                      debugPrint("no inernet..");

                      InternetCheckDialog.show(myContext, () {
                        repo.submitExam(
                            questionList
                                .map((e) => QuestionModel.fromJson(e))
                                .toList(),
                            widget.testId);
                      });
                    }
                  });
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
        title: Text("सामान्य ज्ञान परीक्षा"),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
