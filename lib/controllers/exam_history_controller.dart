import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class ExamHistoryController extends GetxController {
  List allAttemptedExamsList = [];
  RxBool isLoading = false.obs;

  final ExamRepo examRepo = ExamRepo();

  @override
  void onInit() {
    super.onInit();

    getHistory();
  }

  void getHistory() async {
    try {
      isLoading.value = true;
      update();
      final resp = await examRepo.getExamHistory(
          userId: AppLocalStorage.instance.user.userId);

      switch (resp) {
        case AppSuccess():
          allAttemptedExamsList = resp.value;
          update();
          break;
        case AppFailure():
          allAttemptedExamsList = [];
        default:
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
