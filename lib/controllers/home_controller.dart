import 'dart:async';

import 'package:crackitx/app_models/configuration_model.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/theme/app_theme.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/repositories/auth_repo.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/services/internet_service_checker.dart';
import 'package:crackitx/widgets/app_dialog.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isCompliencesLoading = false.obs;
  RxBool isConfigurationLoading = false.obs;
  RxBool isChecked = false.obs;

  RxList<ExamModel> allExams = <ExamModel>[].obs;
  RxList<Map<String, dynamic>> compliences = <Map<String, dynamic>>[].obs;
  ConfigurationModel configuration = ConfigurationModel.toEmpty();
  ExamModel selectedExam = ExamModel.toEmpty();

  // Stores remaining time for each exam (key: examId, value: remaining time)
  RxMap<String, String> examTimers = <String, String>{}.obs;

  final ExamRepo examRepo = ExamRepo();

  @override
  void onInit() {
    super.onInit();
    refreshPage();
  }

  void refreshPage() {
    getAndSubmitOfflinePendingExams();
    isLoading(false);
    isCompliencesLoading(false);
    isChecked(false);
    allExams.clear();
    compliences.clear();
    Future.delayed(Durations.medium3, getExams);
    update();
  }

  getAndSubmitOfflinePendingExams() async {
    final unSubmitedExams =
        AppLocalStorage.instance.getOfflineUnSubmittedExams();

    for (Map<String, dynamic> item in unSubmitedExams) {
      List<QuestionModel> questionList = List<QuestionModel>.from(
          item['answerPaper'].map(
              (e) => QuestionModel.fromJson(Map<String, dynamic>.from(e))));
      final res = await examRepo.submitExam(questionList, item['questionId'],
          timestamp: item["timestamp"]);

      switch (res) {
        case AppSuccess():
          break;
        case AppFailure():
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void getExams() async {
    try {
      isLoading.value = true;
      update();
      final resp = await examRepo.getAllExams(
          orgCode: AppLocalStorage.instance.user.orgCode,
          batchId: AppLocalStorage.instance.user.batch);

      switch (resp) {
        case AppSuccess():
          if (resp.value.isEmpty) {
            return;
          }
          allExams.value = resp.value;
          _initializeTimers();
          break;
        case AppFailure():
          Fluttertoast.showToast(
              msg: 'Failed to fetch exam : ${resp.errorMessage}');
          allExams.value = [];
          break;
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void _initializeTimers() {
    for (var exam in allExams) {
      _startCountdown(exam.questionId ?? 'uniqExam', exam.startTime);
    }
  }

  void _startCountdown(String examId, DateTime startTime) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = startTime.difference(now);

      if (remaining.isNegative) {
        examTimers[examId] = "Exam Started!";
        timer.cancel();
      } else {
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;
        examTimers[examId] =
            "$hours h : $minutes m : $seconds s"; // Format as HH:MM:SS
      }

      examTimers.refresh(); // Update the UI
    });
  }

  void logOut() async {
    try {
      final AuthRepo repo = AuthRepo();
      repo.logOut(userId: AppLocalStorage.instance.user.userId);
      AppLocalStorage.instance.clearStorage();
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  getConfiguration() async {
    try {
      isConfigurationLoading.value = true;
      update();
      final resp = await examRepo.getConfiguration();

      switch (resp) {
        case AppSuccess():
          configuration = resp.value;
          break;
        case AppFailure():
          configuration = ConfigurationModel.toEmpty();
          Fluttertoast.showToast(
              msg: 'Failed to fetch configuration: ${resp.errorMessage}');
      }
    } finally {
      isConfigurationLoading.value = false;
      update();
    }
  }

  getCompliances() async {
    try {
      isCompliencesLoading.value = true;
      update();
      final resp = await examRepo.getCompliance();

      switch (resp) {
        case AppSuccess():
          compliences.value =
              resp.value.map((e) => e as Map<String, dynamic>).toList();
          break;
        case AppFailure():
          compliences.value = [];
      }
    } finally {
      isCompliencesLoading.value = false;
      update();
    }
  }

  void showExamNotLiveDialog({bool isExamEnded = false}) {
    AppDialog().show(
      title: isExamEnded ? 'Exam Ended' : 'Exam not Started yet!',
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(isExamEnded
            ? 'This Exam has Ended, please Attempt Live or Upcoming Exams!'
            : 'Exam will start soon, come back when Exam is Live!'),
      ),
      buttonText: 'Ok',
      onPressed: () => Get.back(),
      restrictBack: false,
      isDismissible: true,
    );
  }

  void showConfigBasedAcknowledgementDialog() async {
    await getCompliances();

    isChecked.value = false; // Reset checkbox state

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Test Acknowledgement",
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Loading state for configuration
                    Obx(() {
                      if (isConfigurationLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Internet requirement notice
                          if (configuration.isInternetDisabled == true)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border:
                                    Border.all(color: Colors.orange.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.wifi_off,
                                      color: Colors.orange.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Internet must be disabled to start this exam. Please turn off your internet connection before proceeding.",
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Compliance instructions
                          if (compliences.isNotEmpty) ...[
                            Text(
                              "Instructions:",
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...compliences.map((compliance) => _buildReminder(
                                compliance['compliance'] as String? ?? '')),
                            const SizedBox(height: 16),
                          ],

                          // Acknowledgement checkbox
                          CheckboxListTile(
                            title: Text(
                              "I acknowledge the instructions and requirements.",
                              style: AppTheme.bodyMedium
                                  .copyWith(color: Colors.black),
                            ),
                            value: isChecked.value,
                            onChanged: (value) {
                              isChecked.value = value!;
                              setState(() {});
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),

                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  "Cancel",
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: isChecked.value
                                    ? () => _handleExamStart()
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cardBackground,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text("Start Exam"),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _handleExamStart() async {
    // Check internet connectivity requirement
    bool isInternetConnected =
        await InternetServiceChecker().isInternetConnected;

    if (configuration.isInternetDisabled == true) {
      // Internet should be disabled for this exam
      if (isInternetConnected) {
        AppSnackbarWidget.showSnackBar(
          isSuccess: false,
          subTitle:
              'Please disable your internet connection to start this exam.',
        );
        return;
      }
    } else {
      // Internet is allowed for this exam - no restriction
      // User can proceed regardless of internet status
    }

    Get.back(); // Close the dialog
    Get.toNamed('/exam-screen', arguments: {
      "questions": selectedExam.questionList ?? [],
      "testId": selectedExam.questionId ?? '',
      'name': selectedExam.subjectName,
      'time': selectedExam.examDuration ?? '0',
    });
  }

  Widget _buildReminder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
