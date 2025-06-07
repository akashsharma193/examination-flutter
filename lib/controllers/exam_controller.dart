import 'dart:async';

import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/controllers/home_controller.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/services/internet_service_checker.dart';
import 'package:crackitx/widgets/app_dialog.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';
import 'package:crackitx/widgets/test_completed_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExamController extends GetxController with WidgetsBindingObserver {
  final List<QuestionModel> questions;
  final String examDurationMinutes;
  final String testId;

  final ScrollController scrollController = ScrollController();

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
  late HomeController homeController;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    homeController = Get.put(HomeController());

    questionList.value = questions.map((e) => e.toJson()).toList();
    questionList.shuffle();

    remainingSeconds.value = (int.tryParse(examDurationMinutes) ?? 0) * 60;
    startTimer();

    _internetSubscription = InternetServiceChecker()
        .checkIfInternetIsConnected()
        .listen((isConnected) {
      if (isConnected && homeController.configuration.isInternetDisabled) {
        showInternetWarning();
      }
    });
  }

  void scrollToCurrentIndex() {
    const itemWidth = 48.0;
    const spacing = 8.0;

    final screenWidth = View.of(Get.context!).physicalSize.width /
        View.of(Get.context!).devicePixelRatio;

    final numberOfItemsDisplayed = screenWidth ~/ (itemWidth + spacing);
    const fullItemWidth = itemWidth + spacing;

    final section = currentQuestionIndex.value ~/ numberOfItemsDisplayed;

    final position = section * numberOfItemsDisplayed * fullItemWidth;

    scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
      if (warningCount.value >= 4) goToCompletedScreen();
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
      AppDialog().show(
        title: "Warning!",
        content: const Text(
            "This app is not accessible in split-screen or floating window mode."),
        buttonText: "OK",
        onPressed: () {
          Get.back();
        },
        restrictBack: true,
        isDismissible: false,
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
    ExamRepo()
        .submitExam(
      questionList.map((e) => QuestionModel.fromJson(e)).toList(),
      testId,
    )
        .then((v) {
      switch (v) {
        case AppSuccess(value: bool v):
          AppSnackbarWidget.showSnackBar(
              isSuccess: v,
              subTitle: 'Exam submitted status : ${v ? 'Success' : 'Failed'}');

          Get.offAllNamed('/home');
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: v.errorMessage);
      }
    });
  }

  void goToCompletedScreen() {
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
      scrollToCurrentIndex();
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questionList.length - 1) {
      currentQuestionIndex.value++;
      scrollToCurrentIndex();
    } else {
      showExamSubumitConfirmationDialog();
    }
  }

  void showExamSubumitConfirmationDialog(
      {String? message, bool isDismissable = true}) {
    AppDialog().show(
      title: "Alert !",
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              style: const TextStyle(fontWeight: FontWeight.w400),
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
      buttonText: "Submit",
      onPressed: () {
        homeController.configuration.isInternetDisabled
            ? goToCompletedScreen()
            : submitExam();
      },
      showButton: true,
      restrictBack: !isDismissable,
      isDismissible: isDismissable,
    );
  }

  void showTimerWarning({required int minute}) {
    AppDialog().show(
      title: "Alert !",
      content: Text('$minute Minute Remaining...'),
      buttonText: "OK",
      onPressed: () {
        Get.back();
      },
    );
  }

  void showBackgroundWarning() {
    AppDialog().show(
      title: "Warning!",
      content: Text(
          "You switched apps or minimized the exam.\nWarning: ${warningCount.value}/3"),
      buttonText: "OK",
      onPressed: () {
        Get.back();
      },
      restrictBack: true,
      isDismissible: false,
    );
  }

  void showInternetWarning() {
    AppDialog().show(
      title: "Warning!",
      content:
          const Text("You cannot use the internet while attempting the exam."),
      buttonText: "OK",
      onPressed: () {
        Get.back();
      },
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return "$minutes:${sec.toString().padLeft(2, '0')}";
  }
}
