import 'package:get/get.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/repositories/exam_repo.dart';

class PastExamDetailController extends GetxController {
  List<Map<String, dynamic>> studentList = [];
  ExamRepo examRepo = ExamRepo();

  void fetchStudentDetails(String questionId) async {
    final result = await examRepo.getStudentListByQuestionId(questionId);

    switch (result) {
      case AppSuccess(value: List<Map<String, dynamic>> v):
        studentList = v;
        break;
      case AppFailure():
        studentList = [];
        break;
    }
    update();
  }
}
