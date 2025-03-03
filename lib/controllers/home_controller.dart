import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/exam_screen.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isChecked = false.obs;
  RxList<GetExamModel> allExams = <GetExamModel>[].obs;
  final ExamRepo examRepo = ExamRepo();

  @override
  void onInit() {
    super.onInit();
    getExams();
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

  void showDialogPopUp() {
    Get.defaultDialog(
      title: "Test Acknowledgement",
      content: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Column(
              children: [
                _buildReminder("📜 Read the instructions carefully."),
                _buildReminder("🌐 Ensure No internet connection Available."),
                _buildReminder("🚫 Do not switch apps or tabs."),
                _buildReminder("🖊️ Keep necessary materials ready."),
                _buildReminder("⏳ Manage your time wisely."),
              ],
            ),
            CheckboxListTile(
              title: Text("I acknowledge the instructions."),
              value: isChecked.value,
              onChanged: (value) {
                isChecked.value = value!;
                setState(() {});
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isChecked.value
                  ? () {
                      Get.to(() => ExamScreen(
                            questions: allExams.firstOrNull?.questionList ?? [],
                          ));
                    }
                  : null, // Disabled if checkbox is unchecked
              child: Text("Continue"),
            )
          ],
        );
      }),
    );
  }
}
