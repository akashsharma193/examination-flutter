import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/admin_repo.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class ExamHistoryController extends GetxController {
  List allAttemptedExamsList = [];
  RxBool isLoading = false.obs;
  bool isFromGetAllExamTab = false;
  final ExamRepo examRepo = ExamRepo();
  final AdminRepo adminRepo = AdminRepo();
  bool showOnlyActiveExams = false;

  void setup({required String? userId, bool showActiveExam = false}) {
    isFromGetAllExamTab = userId == null;
    showOnlyActiveExams = showActiveExam;
    print("is active exam : $showOnlyActiveExams");
    getHistory(userId);
  }

  _filterActiveExam() {
    debugPrint(
        "filtering exams, cureent exam : ${allAttemptedExamsList.length}");
    allAttemptedExamsList =
        List<SingleExamHistoryModel>.from(allAttemptedExamsList)
            .where((e) => e.endTime?.isAfter(DateTime.now()) ?? false)
            .toList();
  }

  void getHistory(String? userId) async {
    try {
      isLoading.value = true;

      update();
      AppResult<List<SingleExamHistoryModel>>? resp;

      if (isFromGetAllExamTab) {
        resp = await adminRepo
            .getAllExamsList(AppLocalStorage.instance.user.orgCode);
      } else {
        resp = await examRepo.getExamHistory(
            userId: userId ?? AppLocalStorage.instance.user.userId);
      }

      switch (resp) {
        case AppSuccess(value: List<SingleExamHistoryModel> v):
          allAttemptedExamsList = v;

          if (showOnlyActiveExams) {
            print("filter active exam:");
            _filterActiveExam();
          }
          update();
          break;
        case AppFailure():
          allAttemptedExamsList = [];
      }
    } catch (e) {
      debugPrint(
          "error caught in examhistory  controller in getHistory func : $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
