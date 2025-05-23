import 'package:get/get.dart';
import 'package:crackitx/app_models/test_result_detail_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';

class TestResultDetailController extends GetxController {
  bool isLoading = false;
  TestResultDetailModel testResultDetailModel = TestResultDetailModel.toEmpty();
  ExamRepo repo = ExamRepo();
  void fetchData(String qId, String userId) async {
    repo.getTestResultDetails(userId: userId, qID: qId).then((v) {
      switch (v) {
        case AppSuccess():
          testResultDetailModel = v.value;
          update();
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
            isSuccess: false,
            subTitle: v.errorMessage,
          );
          update();
          break;
      }
    });

    update();
  }

  void refreshData(String qId, String userId) {
    fetchData(qId, userId);
  }
}
