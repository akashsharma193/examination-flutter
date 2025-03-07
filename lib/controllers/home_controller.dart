import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/exam_screen.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isCompliencesLoading = false.obs;
  RxBool isChecked = false.obs;

  RxList<GetExamModel> allExams = <GetExamModel>[].obs;
  RxList<Map<String, dynamic>> compliences = <Map<String, dynamic>>[].obs;
  GetExamModel selectedExam = GetExamModel.toEmpty();
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

  getAndSubmitOfflinePendingExams() async{
    final unSubmitedExams =
        AppLocalStorage.instance.getOfflineUnSubmittedExams();

    for (Map<String, dynamic> item in unSubmitedExams) {
      debugPrint("item  = $item");
      List<QuestionModel> questionList = List<QuestionModel>.from(
          item['answerPaper'].map(
                  (e) => QuestionModel.fromJson(Map<String, dynamic>.from(e))));
      final res = await examRepo.submitExam(questionList, item['questionId']);

      switch (res) {
        case AppSuccess():
          print("success isolate exam sub ");
          break;
        case AppFailure():
          print("failed to submit exam in isolate : ${res.errorMessage}");
        default:
      }
      await Future.delayed(Duration(seconds:1));
    }
  }

  Future<void> submitExamInIsolate(Map<String, dynamic> data) async {
    try {
      print("calling isolate func : ${DateTime.now()}");
      Dio dio = Dio(BaseOptions(
        connectTimeout: Duration(seconds: 120),
        receiveTimeout: Duration(seconds: 120),
      ));

      // Convert JSON back to List<QuestionModel>
      List<QuestionModel> questionList = List<QuestionModel>.from(
          data['answerPaper'].map(
              (e) => QuestionModel.fromJson(Map<String, dynamic>.from(e))));
      final res = await examRepo.submitExam(questionList, data['questionId']);

      switch (res) {
        case AppSuccess():
          print("success isolate exam sub ");
          break;
        case AppFailure():
          print("failed to submit exam in isolate : ${res.errorMessage}");
        default:
      }
      // Make API request
      // final response = await dio.post(
      //   'https://online-examination-xlcp.onrender.com/answerPaper/saveAnswePaper',
      //   data: data,
      // );

      print("✅ Exam Submitted: ${res.runtimeType}");
    } catch (e) {
      print("❌ Error Submitting Exam: $e");
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
          break;
        case AppFailure():
          allExams.value = [];
        default:
      }
    } catch (e) {
      debugPrint("error caught in home controller in getexams func : $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void logOut() async {
    try {
      final AuthRepo repo = AuthRepo();
      repo.logOut(userId: AppLocalStorage.instance.user.userId);
      AppLocalStorage.instance.clearStorage();
      Get.offAllNamed('/');
    } catch (e) {
      debugPrint("error in logout authcontroller : $e");
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
        default:
      }
    } catch (e) {
      debugPrint("error caught in home controller in getCompliances func : $e");
    } finally {
      isCompliencesLoading.value = false;
      update();
    }
  }

  void showDialogPopUp() async {
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
                  ? () {
                      Get.toNamed('/exam-screen', arguments: {
                        "questions": selectedExam.questionList ?? [],
                        "testId": selectedExam.questionId ?? '',
                      });
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
