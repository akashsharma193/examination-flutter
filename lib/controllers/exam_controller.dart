import 'dart:async';
import 'dart:io';

import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/controllers/home_controller.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/services/internet_service_checker.dart';
import 'package:crackitx/widgets/app_dialog.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';
import 'package:crackitx/widgets/test_completed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Timer? _internetCheckTimer;
  Timer? _lifecycleCheckTimer;
  StreamSubscription<bool>? _internetSubscription;
  late HomeController homeController;

  Map<int, int> questionTimeSpent = {};
  DateTime? currentQuestionStartTime;
  bool isTimerPaused = false;
  bool isExamActive = true;
  AppLifecycleState? _lastKnownState;
  bool _dialogShown = false;
  DateTime? _lastResumeTime;
  DateTime? _lastPauseTime;
  bool _appIsInBackground = false;
  Timer? _backgroundCheckTimer;

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
    _initializeMonitoring();

    ever(currentQuestionIndex, (int newIndex) {
      _onQuestionChanged(newIndex);
    });
  }

  void _initializeMonitoring() {
    _initializeInternetMonitoring();
    _initializeLifecycleMonitoring();
  }

  void _initializeLifecycleMonitoring() {
    _lifecycleCheckTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _checkAppState();
    });

    if (Platform.isAndroid) {
      SystemChannels.lifecycle.setMessageHandler((message) async {
        debugPrint('Lifecycle message: $message');
        if (message == 'AppLifecycleState.paused' ||
            message == 'AppLifecycleState.detached' ||
            message == 'AppLifecycleState.hidden') {
          _handleAppBackgroundDirect();
        } else if (message == 'AppLifecycleState.resumed') {
          _handleAppForegroundDirect();
        }
        return null;
      });
    }
  }

  void _checkAppState() {
    if (!isExamActive) return;

    final currentTime = DateTime.now();

    if (_lastResumeTime != null &&
        currentTime.difference(_lastResumeTime!).inSeconds > 2 &&
        !_appIsInBackground) {
      _appIsInBackground = true;
      _lastPauseTime = currentTime;
      _handleAppBackgroundDirect();
    }
  }

  void _handleAppBackgroundDirect() {
    if (_dialogShown || !isExamActive || _appIsInBackground) return;

    _appIsInBackground = true;
    pauseQuestionTimer();
    warningCount.value++;

    debugPrint(
        'App backgrounded directly. Warning count: ${warningCount.value}');

    if (warningCount.value >= 3) {
      isExamActive = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        goToCompletedScreen();
      });
      return;
    }

    _backgroundCheckTimer = Timer(const Duration(seconds: 2), () {
      if (_appIsInBackground && isExamActive) {
        _triggerBackgroundWarning();
      }
    });
  }

  void _handleAppForegroundDirect() {
    if (!isExamActive) return;

    _lastResumeTime = DateTime.now();
    _backgroundCheckTimer?.cancel();

    if (_appIsInBackground) {
      _appIsInBackground = false;
      resumeQuestionTimer();

      if (warningCount.value > 0 && warningCount.value < 3 && !_dialogShown) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_dialogShown && isExamActive) {
            _triggerBackgroundWarning();
          }
        });
      }
    }
  }

  void _triggerBackgroundWarning() {
    if (_dialogShown || !isExamActive) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_dialogShown && isExamActive) {
        showBackgroundWarning();
      }
    });
  }

  void _initializeInternetMonitoring() {
    if (Platform.isAndroid) {
      _internetCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _checkInternetConnection();
      });
    } else {
      _internetSubscription = InternetServiceChecker()
          .checkIfInternetIsConnected()
          .listen((isConnected) {
        if (isConnected &&
            homeController.configuration.isInternetDisabled &&
            isExamActive) {
          showInternetWarning();
        }
      });
    }
  }

  Future<void> _checkInternetConnection() async {
    if (!isExamActive) return;

    try {
      final isConnected = await InternetServiceChecker().isInternetConnected;
      if (isConnected &&
          homeController.configuration.isInternetDisabled &&
          !_dialogShown) {
        showInternetWarning();
      }
    } catch (e) {
      debugPrint('Internet check error: $e');
    }
  }

  void startQuestionTimeTracking() {
    currentQuestionStartTime = DateTime.now();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isTimerPaused && currentQuestionStartTime != null && isExamActive) {
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
    isExamActive = false;
    _timer?.cancel();
    _questionTimer?.cancel();
    _internetCheckTimer?.cancel();
    _lifecycleCheckTimer?.cancel();
    _backgroundCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _internetSubscription?.cancel();
    SystemChannels.lifecycle.setMessageHandler(null);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isExamActive) return;

    debugPrint('Lifecycle state changed: $state, Last known: $_lastKnownState');

    if (_lastKnownState == state) return;
    _lastKnownState = state;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _handleAppBackgroundDirect();
        break;
      case AppLifecycleState.resumed:
        _handleAppForegroundDirect();
        break;
      case AppLifecycleState.inactive:
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (_lastKnownState == AppLifecycleState.inactive && isExamActive) {
              _handleAppBackgroundDirect();
            }
          });
        }
        break;
    }
  }

  @override
  void didChangeMetrics() {
    if (!isExamActive) return;

    final screenWidth = View.of(Get.context!).physicalSize.width /
        View.of(Get.context!).devicePixelRatio;

    if (screenWidth < 350) {
      isAppInSplitScreen.value = true;
      pauseQuestionTimer();

      if (!_dialogShown) {
        _dialogShown = true;
        AppDialog().show(
          title: "Warning!",
          content: const Text(
              "This app is not accessible in split-screen or floating window mode."),
          buttonText: "OK",
          onPressed: () {
            Get.back();
            _dialogShown = false;
            resumeQuestionTimer();
          },
          restrictBack: true,
          isDismissible: false,
        );
      }
    } else {
      isAppInSplitScreen.value = false;
      if (isTimerPaused && !_dialogShown) {
        resumeQuestionTimer();
      }
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isExamActive) {
        timer.cancel();
        return;
      }

      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        double minuteRemaining = (remainingSeconds.value / 60);
        if (minuteRemaining == 1 ||
            (minuteRemaining < 11 && minuteRemaining % 5 == 0)) {
          showTimerWarning(minute: minuteRemaining.toInt());
        }
      } else {
        timer.cancel();
        _questionTimer?.cancel();
        isExamActive = false;

        showExamSubumitConfirmationDialog(
            isDismissable: false,
            message: 'Time Up,\n click OK to continue...\n');
      }
    });
  }

  void submitExam() {
    if (!isExamActive) return;

    isExamActive = false;
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
          goToCompletedScreen();
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
    if (!isExamActive) return;
    isExamActive = false;
    List<QuestionModel> questionsWithTime = _prepareQuestionsWithTimeData();

    Get.offAll(() => TestCompletedScreen(
          list: questionsWithTime,
          testID: testId,
        ));
  }

  void selectAnswer(String answer) {
    if (!isExamActive) return;
    questionList[currentQuestionIndex.value]["userAnswer"] = answer;
    questionList.refresh();
  }

  void clearAnswer() {
    if (!isExamActive) return;
    questionList[currentQuestionIndex.value]["userAnswer"] = '';
    questionList.refresh();
  }

  void previousQuestion() {
    if (!isExamActive) return;
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void nextQuestion() {
    if (!isExamActive) return;
    if (currentQuestionIndex.value < questionList.length - 1) {
      currentQuestionIndex.value++;
    } else {
      showExamSubumitConfirmationDialog();
    }
  }

  void showExamSubumitConfirmationDialog(
      {String? message, bool isDismissable = true}) {
    if (_dialogShown || !isExamActive) return;

    _dialogShown = true;
    pauseQuestionTimer();

    AppDialog().show(
      showCancel: isDismissable,
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
        Get.back();
        _dialogShown = false;
        goToCompletedScreen();
      },
      showButton: true,
      restrictBack: !isDismissable,
      isDismissible: isDismissable,
    );

    if (isDismissable) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isDialogOpen != true && isExamActive) {
          _dialogShown = false;
          resumeQuestionTimer();
        }
      });
    }
  }

  void showTimerWarning({required int minute}) {
    if (_dialogShown || !isExamActive) return;

    _dialogShown = true;
    pauseQuestionTimer();

    AppDialog().show(
      title: "Alert !",
      content: Text('$minute Minute Remaining...'),
      buttonText: "OK",
      onPressed: () {
        Get.back();
        _dialogShown = false;
        if (isExamActive) {
          resumeQuestionTimer();
        }
      },
    );
  }

  void showBackgroundWarning() {
    if (_dialogShown || !isExamActive) return;

    _dialogShown = true;
    pauseQuestionTimer();

    AppDialog().show(
      title: "Warning!",
      content: Text(
          "You switched apps or minimized the exam.\nWarning: ${warningCount.value}/3"),
      buttonText: "OK",
      onPressed: () {
        Get.back();
        _dialogShown = false;
        if (isExamActive) {
          resumeQuestionTimer();
        }
      },
      restrictBack: true,
      isDismissible: false,
    );
  }

  void showInternetWarning() {
    if (_dialogShown || !isExamActive) return;

    _dialogShown = true;
    pauseQuestionTimer();

    AppDialog().show(
      title: "Warning!",
      content:
          const Text("You cannot use the internet while attempting the exam."),
      buttonText: "OK",
      onPressed: () {
        Get.back();
        _dialogShown = false;
        if (isExamActive) {
          resumeQuestionTimer();
        }
      },
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final sec = seconds % 60;
    return "$minutes:${sec.toString().padLeft(2, '0')}";
  }
}
