import 'package:get/get.dart';
import 'package:offline_test_app/app_models/test_result_detail_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class TestResultDetailController extends GetxController {
  bool isLoading = false;
  TestResultDetailModel testResultDetailModel = TestResultDetailModel.toEmpty();
  ExamRepo repo = ExamRepo();
  void fetchData(String qId) async {
    repo
        .getTestResultDetails(
            userId: AppLocalStorage.instance.user.userId, qID: qId)
        .then((v) {
      switch (v) {
        case AppSuccess():
          testResultDetailModel = v.value;
          update();
          break;
        case AppFailure():
          Get.showSnackbar(GetSnackBar(
            message: v.errorMessage,
            title: v.code,
          ));
          update();
          break;
      }
    });

    update();
  }

  void refreshData(String qId) {
    fetchData(qId);
  }
}
