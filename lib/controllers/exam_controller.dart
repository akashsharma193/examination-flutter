import 'dart:async';

import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/services/internet_service_checker.dart';
import 'package:crackitx/widgets/test_completed_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExamController extends GetxController with WidgetsBindingObserver {
  final List<QuestionModel> questions;
  final String examDurationMinutes;
  final String testId;

  ExamController({
    required this.questions,
    required this.examDurationMinutes,
    required this.testId,
  });

  var questionList = <Map<String, dynamic>>[].obs;
  var currentQuestionIndex = 0.obs;
  var remainingSeconds = 0.obs;
  var warningCount = 0.obs;
  var isAppInSplitScreen = false.obs;

  Timer? _timer;
  StreamSubscription<bool>? _internetSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    questionList.value = questions.map((e) => e.toJson()).toList();
    questionList.shuffle();

    remainingSeconds.value = (int.tryParse(examDurationMinutes) ?? 0) * 60;
    startTimer();

    _internetSubscription = InternetServiceChecker()
        .checkIfInternetIsConnected()
        .listen((isConnected) {
      if (isConnected) showInternetWarning();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _internetSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      warningCount.value++;
      if (warningCount.value >= 4) autoSubmitExam();
    } else if (state == AppLifecycleState.resumed &&
        warningCount.value > 0 &&
        warningCount.value < 4) {
      showBackgroundWarning();
    }
  }

  @override
  void didChangeMetrics() {
    final screenWidth = View.of(Get.context!).physicalSize.width /
        View.of(Get.context!).devicePixelRatio;

    if (screenWidth < 350) {
      isAppInSplitScreen.value = true;
      closeOpenDialogs();
      Get.dialog(
        AlertDialog(
          title: const Text("Warning!"),
          content: const Text(
              "This app is not accessible in split-screen or floating window mode."),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text("OK")),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      isAppInSplitScreen.value = false;
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        double minuteRemaining = (remainingSeconds.value / 60);
        if (minuteRemaining == 1 ||
            (minuteRemaining < 11 && minuteRemaining % 5 == 0)) {
          showTimerWarning(minute: minuteRemaining.toInt());
        }
      } else {
        timer.cancel();
        showExamSubumitConfirmationDialog(
            isDismissable: false,
            message: 'Time Up,\n click OK to continue Submitting...\n');
      }
    });
  }

  void submitExam() {
    ExamRepo().submitExam(
      questionList.map((e) => QuestionModel.fromJson(e)).toList(),
      testId,
    );
    Get.offAllNamed('/home');
  }

  void autoSubmitExam() {
    Get.offAll(() => TestCompletedScreen(
          list: questionList
              .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
          testID: testId,
        ));
  }

  void selectAnswer(String answer) {
    questionList[currentQuestionIndex.value]["userAnswer"] = answer;
    questionList.refresh();
  }

  void clearAnswer() {
    questionList[currentQuestionIndex.value]["userAnswer"] = '';
    questionList.refresh();
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questionList.length - 1) {
      currentQuestionIndex.value++;
    } else {
      showExamSubumitConfirmationDialog();
    }
  }

  void showExamSubumitConfirmationDialog(
      {String? message, bool isDismissable = true}) {
    Get.dialog(
        AlertDialog(
          title: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.amber,
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  "Alert !",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  style: TextStyle(fontWeight: FontWeight.w400),
                  text: message ?? 'Do you want to submit the TEST?\n\n',
                ),
                const TextSpan(
                  text: 'Attempted Questions: ',
                ),
                TextSpan(
                  text:
                      '${questionList.where((e) => e['userAnswer'] != null && e['userAnswer'].isNotEmpty).length}/${questionList.length}\n\n',
                  // style: const TextStyle(color: Colors.blue),
                ),
                const TextSpan(
                  text: 'Instruction: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const TextSpan(
                  text: 'Kindly enable your internet in your next step.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    autoSubmitExam();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9181F4), Color(0xFF5038ED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: isDismissable);
  }

  void showTimerWarning({required int minute}) {
    Get.dialog(
      AlertDialog(
        title: const Text("Alert !"),
        content: Text('$minute Minute Remaining...'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showBackgroundWarning() {
    closeOpenDialogs();
    Get.dialog(
      AlertDialog(
        title: const Text("Warning!"),
        content: Text(
            "You switched apps or minimized the exam.\nWarning: ${warningCount.value}/3"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("OK")),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showInternetWarning() {
    closeOpenDialogs();
    Get.dialog(
      AlertDialog(
        title: const Text("Warning!"),
        content: const Text(
            "You cannot use the internet while attempting the exam."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("OK")),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void closeOpenDialogs() {
    while (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return "$minutes:${sec.toString().padLeft(2, '0')}";
  }
}
