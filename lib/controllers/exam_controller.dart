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
  Timer? _questionTimer;
  StreamSubscription<bool>? _internetSubscription;
  late HomeController homeController;

  Map<int, int> questionTimeSpent = {};
  DateTime? currentQuestionStartTime;
  bool isTimerPaused = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    homeController = Get.put(HomeController());

    questionList.value = questions.map((e) => e.toJson()).toList();
    questionList.shuffle();

    for (int i = 0; i < questionList.length; i++) {
      questionTimeSpent[i] = 0;
    }

    remainingSeconds.value = (int.tryParse(examDurationMinutes) ?? 0) * 60;
    startTimer();
    startQuestionTimeTracking();

    _internetSubscription = InternetServiceChecker()
        .checkIfInternetIsConnected()
        .listen((isConnected) {
      if (isConnected && homeController.configuration.isInternetDisabled) {
        showInternetWarning();
      }
    });

    ever(currentQuestionIndex, (int newIndex) {
      _onQuestionChanged(newIndex);
    });
  }

  void startQuestionTimeTracking() {
    currentQuestionStartTime = DateTime.now();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isTimerPaused && currentQuestionStartTime != null) {
        int currentIndex = currentQuestionIndex.value;
        questionTimeSpent[currentIndex] =
            (questionTimeSpent[currentIndex] ?? 0) + 1;
      }
    });
  }

  void _onQuestionChanged(int newIndex) {
    scrollToCurrentIndex();
  }

  void pauseQuestionTimer() {
    isTimerPaused = true;
  }

  void resumeQuestionTimer() {
    isTimerPaused = false;
    currentQuestionStartTime = DateTime.now();
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
    _questionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _internetSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      pauseQuestionTimer();

      warningCount.value++;
      if (warningCount.value >= 4) goToCompletedScreen();
    } else if (state == AppLifecycleState.resumed) {
      resumeQuestionTimer();

      if (warningCount.value > 0 && warningCount.value < 4) {
        showBackgroundWarning();
      }
    }
  }

  @override
  void didChangeMetrics() {
    final screenWidth = View.of(Get.context!).physicalSize.width /
        View.of(Get.context!).devicePixelRatio;

    if (screenWidth < 350) {
      isAppInSplitScreen.value = true;
      pauseQuestionTimer();

      AppDialog().show(
        title: "Warning!",
        content: const Text(
            "This app is not accessible in split-screen or floating window mode."),
        buttonText: "OK",
        onPressed: () {
          Get.back();
          resumeQuestionTimer();
        },
        restrictBack: true,
        isDismissible: false,
      );
    } else {
      isAppInSplitScreen.value = false;
      if (isTimerPaused) {
        resumeQuestionTimer(); // Resume if it was paused due to split screen
      }
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
        _questionTimer?.cancel(); // Stop question timer when exam time is up

        showExamSubumitConfirmationDialog(
            isDismissable: false,
            message: 'Time Up,\n click OK to continue Submitting...\n');
      }
    });
  }

  void submitExam() {
    List<QuestionModel> questionsWithTime = _prepareQuestionsWithTimeData();

    ExamRepo().submitExam(questionsWithTime, testId).then((v) {
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

  List<QuestionModel> _prepareQuestionsWithTimeData() {
    List<QuestionModel> questionsWithTime = [];

    for (int i = 0; i < questionList.length; i++) {
      Map<String, dynamic> questionData =
          Map<String, dynamic>.from(questionList[i]);

      questionData['timeTaken'] = questionTimeSpent[i] ?? 0;

      QuestionModel question = QuestionModel.fromJson(questionData);
      questionsWithTime.add(question);
    }

    return questionsWithTime;
  }

  void goToCompletedScreen() {
    List<QuestionModel> questionsWithTime = _prepareQuestionsWithTimeData();

    Get.offAll(() => TestCompletedScreen(
          list: questionsWithTime,
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
      // The _onQuestionChanged method will be automatically called due to the 'ever' listener
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
    pauseQuestionTimer();

    AppDialog().show(
      showCancel: true,
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

    if (isDismissable) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isDialogOpen != true) {
          resumeQuestionTimer();
        }
      });
    }
  }

  void showTimerWarning({required int minute}) {
    pauseQuestionTimer();

    AppDialog().show(
      title: "Alert !",
      content: Text('$minute Minute Remaining...'),
      buttonText: "OK",
      onPressed: () {
        Get.back();
        resumeQuestionTimer();
      },
    );
  }

  void showBackgroundWarning() {
    pauseQuestionTimer();

    AppDialog().show(
      title: "Warning!",
      content: Text(
          "You switched apps or minimized the exam.\nWarning: ${warningCount.value}/3"),
      buttonText: "OK",
      onPressed: () {
        Get.back();
        resumeQuestionTimer();
      },
      restrictBack: true,
      isDismissible: false,
    );
  }

  void showInternetWarning() {
    pauseQuestionTimer();

    AppDialog().show(
      title: "Warning!",
      content:
          const Text("You cannot use the internet while attempting the exam."),
      buttonText: "OK",
      onPressed: () {
        Get.back();
        resumeQuestionTimer();
      },
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return "$minutes:${sec.toString().padLeft(2, '0')}";
  }
}
