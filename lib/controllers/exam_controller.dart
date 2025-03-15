import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';
import 'package:offline_test_app/services/internet_service_checker.dart';
import 'package:offline_test_app/widgets/test_completed_screen.dart';

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
      log("Internet connection: $isConnected");
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
          title: Text("Warning!"),
          content: Text(
              "This app is not accessible in split-screen or floating window mode."),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("OK")),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      isAppInSplitScreen.value = false;
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        submitExam();
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
    ExamRepo().submitExam(
      questionList.map((e) => QuestionModel.fromJson(e)).toList(),
      testId,
    );
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

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questionList.length - 1) {
      currentQuestionIndex.value++;
    } else {
      Get.dialog(
        AlertDialog(
          title: Text("Test Completed"),
          content: Text(
              'Turn on Internet\nDo you want to submit TEST?\nAttempted ${questionList.where((e) => e['userAnswer'] != null && e['userAnswer'].isNotEmpty).length}/${questionList.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Get.offAll(() => TestCompletedScreen(
                      list: questionList
                          .map((e) => QuestionModel.fromJson(
                              Map<String, dynamic>.from(e)))
                          .toList(),
                      testID: testId,
                    ));
              },
              child: Text("OK"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  void showBackgroundWarning() {
    closeOpenDialogs();
    Get.dialog(
      AlertDialog(
        title: Text("Warning!"),
        content: Text(
            "You switched apps or minimized the exam.\nWarning: ${warningCount.value}/3"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("OK")),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showInternetWarning() {
    closeOpenDialogs();
    Get.dialog(
      AlertDialog(
        title: Text("Warning!"),
        content: Text("You cannot use the internet while attempting the exam."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("OK")),
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
