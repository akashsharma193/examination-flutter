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
  Timer? _focusCheckTimer;
  Timer? _activityTimer;
  StreamSubscription<bool>? _internetSubscription;
  late HomeController homeController;

  Map<int, int> questionTimeSpent = {};
  DateTime? currentQuestionStartTime;
  bool isTimerPaused = false;
  bool isExamActive = true;
  AppLifecycleState? _lastKnownState;
  bool _dialogShown = false;

  bool _isAppVisible = true;
  DateTime? _lastActivityTime;
  DateTime? _lastVisibilityChange;
  int _backgroundDetectionCount = 0;
  bool _hasShownWarningForCurrentBackground = false;

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
    _initializeFocusMonitoring();
    _lastActivityTime = DateTime.now();
    _lastVisibilityChange = DateTime.now();
  }

  void _initializeFocusMonitoring() {
    _focusCheckTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _checkAppFocus();
    });

    _activityTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _trackUserActivity();
    });

    if (Platform.isAndroid) {
      SystemChannels.lifecycle.setMessageHandler((message) async {
        debugPrint('Lifecycle channel message: $message');
        _handleLifecycleMessage(message);
        return null;
      });
    }
  }

  void _handleLifecycleMessage(String? message) {
    if (!isExamActive) return;

    switch (message) {
      case 'AppLifecycleState.paused':
      case 'AppLifecycleState.detached':
      case 'AppLifecycleState.hidden':
      case 'AppLifecycleState.inactive':
        _handleAppLostFocus();
        break;
      case 'AppLifecycleState.resumed':
        _handleAppGainedFocus();
        break;
    }
  }

  void _checkAppFocus() {
    if (!isExamActive) return;

    final now = DateTime.now();

    if (_lastActivityTime != null &&
        now.difference(_lastActivityTime!).inMilliseconds > 1000 &&
        _isAppVisible) {
      _isAppVisible = false;
      _lastVisibilityChange = now;
      _handleAppLostFocus();
    }
  }

  void _trackUserActivity() {
    if (!isExamActive) return;

    final now = DateTime.now();

    if (!_isAppVisible &&
        _lastVisibilityChange != null &&
        now.difference(_lastVisibilityChange!).inMilliseconds > 300) {
      _lastActivityTime = now;
      _isAppVisible = true;
      _handleAppGainedFocus();
    }
  }

  void _handleAppLostFocus() {
    if (!isExamActive || _dialogShown) return;

    debugPrint('App lost focus detected');
    _backgroundDetectionCount++;

    if (!_hasShownWarningForCurrentBackground) {
      _hasShownWarningForCurrentBackground = true;
      pauseQuestionTimer();
      warningCount.value++;

      debugPrint('Tab switch detected. Warning count: ${warningCount.value}');

      if (warningCount.value >= 3) {
        _dialogShown = true;
        isExamActive = false;

        AppDialog().show(
          title: "Warning!",
          content: Text(
              "You have exceeded the maximum number of app switches.\nYour exam will now be submitted automatically."),
          buttonText: "OK",
          onPressed: () {
            Get.back();
            _dialogShown = false;
            goToCompletedScreen();
          },
          restrictBack: true,
          isDismissible: false,
        );
        return;
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_dialogShown &&
            isExamActive &&
            _hasShownWarningForCurrentBackground) {
          showBackgroundWarning();
        }
      });
    }
  }

  void _handleAppGainedFocus() {
    if (!isExamActive) return;

    debugPrint('App gained focus');
    _hasShownWarningForCurrentBackground = false;

    if (isTimerPaused && !_dialogShown) {
      resumeQuestionTimer();
    }
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

        _lastActivityTime = DateTime.now();
      }
    });
  }

  void _onQuestionChanged(int newIndex) {
    scrollToCurrentIndex();
    _lastActivityTime = DateTime.now();
  }

  void pauseQuestionTimer() {
    isTimerPaused = true;
  }

  void resumeQuestionTimer() {
    isTimerPaused = false;
    currentQuestionStartTime = DateTime.now();
    _lastActivityTime = DateTime.now();
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
    _focusCheckTimer?.cancel();
    _activityTimer?.cancel();
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
        _handleAppLostFocus();
        break;
      case AppLifecycleState.resumed:
        _handleAppGainedFocus();
        break;
      case AppLifecycleState.inactive:
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_lastKnownState == AppLifecycleState.inactive && isExamActive) {
              _handleAppLostFocus();
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
    _lastActivityTime = DateTime.now();
  }

  void clearAnswer() {
    if (!isExamActive) return;
    questionList[currentQuestionIndex.value]["userAnswer"] = '';
    questionList.refresh();
    _lastActivityTime = DateTime.now();
  }

  void previousQuestion() {
    if (!isExamActive) return;
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
    _lastActivityTime = DateTime.now();
  }

  void nextQuestion() {
    if (!isExamActive) return;
    if (currentQuestionIndex.value < questionList.length - 1) {
      currentQuestionIndex.value++;
    } else {
      showExamSubumitConfirmationDialog();
    }
    _lastActivityTime = DateTime.now();
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
