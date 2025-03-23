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

  @override
  void onInit() {
    super.onInit();
    final String? userId =
        Get.arguments == null ? null : Get.arguments['userId'];
    isFromGetAllExamTab = userId == null;
    getHistory(userId);
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

      switch (resp!) {
        case AppSuccess(value: List<SingleExamHistoryModel> v):
          allAttemptedExamsList = v;
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
