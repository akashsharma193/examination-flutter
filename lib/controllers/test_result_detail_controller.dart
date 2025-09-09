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
    isLoading = true;
    update();

    try {
      final result = await repo.getTestResultDetails(userId: userId, qID: qId);

      switch (result) {
        case AppSuccess():
          testResultDetailModel = result.value;
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
            isSuccess: false,
            subTitle: result.errorMessage ?? 'Failed to fetch test results',
          );
          break;
      }
    } catch (e) {
      AppSnackbarWidget.showSnackBar(
        isSuccess: false,
        subTitle: 'An error occurred while fetching test results',
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  void refreshData(String qId, String userId) {
    fetchData(qId, userId);
  }
}
