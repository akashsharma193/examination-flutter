import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/repositories/auth_repo.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/services/internet_service_checker.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isCompliencesLoading = false.obs;
  RxBool isChecked = false.obs;

  RxList<ExamModel> allExams = <ExamModel>[].obs;
  RxList<Map<String, dynamic>> compliences = <Map<String, dynamic>>[].obs;
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
      final res = await examRepo.submitExam(questionList, item['questionId']);

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

  Widget _buildReminder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
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
    Get.defaultDialog(
      title: isExamEnded ? 'Exam Ended' : 'Exam not Started yet!',
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(isExamEnded
            ? 'This Exam has Ended, please Attempt Live or Upcoming Exams!'
            : 'Exam will start soon, come back when Exam is Live!'),
      ),
    );
  }

  void showAcknowledgementDialogPopUp() async {
    while (Get.isDialogOpen ?? false) {
      Get.back();
    }

    await getCompliances();
    Get.defaultDialog(
      title: "Test Acknowledgement",
      content: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Column(
              children: List.generate(compliences.length, (index) {
                return _buildReminder(
                    compliences[index]['compliance'] as String? ?? '');
              }).toList(),
            ),
            CheckboxListTile(
              title: const Text("I acknowledge the instructions."),
              value: isChecked.value,
              onChanged: (value) {
                isChecked.value = value!;
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isChecked.value
                  ? () async {
                      if (await InternetServiceChecker().isInternetConnected) {
                        AppSnackbarWidget.showSnackBar(
                            isSuccess: false,
                            subTitle: 'No internet Allowed in the Examination');
                        return;
                      } else {
                        Get.back();
                        Get.toNamed('/exam-screen', arguments: {
                          "questions": selectedExam.questionList ?? [],
                          "testId": selectedExam.questionId ?? '',
                          'name': selectedExam.subjectName,
                          'time': selectedExam.examDuration ?? '0',
                        });
                      }
                    }
                  : null, // Disabled if checkbox is unchecked
              child: const Text("Continue"),
            )
          ],
        );
      }),
    );
  }
}
