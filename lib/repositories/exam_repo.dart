import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crackitx/app_models/configuration_model.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/app_models/test_result_detail_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/data/remote/app_dio_service.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';

class ExamRepo {
  final dioService = AppDioService.instance;

  /// call login api
  Future<AppResult<List<ExamModel>>> getAllExams(
      {required String orgCode, required String batchId}) async {
    try {
      final response =
          await dioService.postDio(endpoint: 'questionPaper/getExam', body: {
        "orgCode": orgCode,
        "batch": batchId,
        "userId": AppLocalStorage.instance.user.userId
      });
      switch (response) {
        case AppSuccess():
          return AppSuccess((response.value['data'] as List<dynamic>)
              .map((e) => ExamModel.fromJson(e))
              .toList());
        case AppFailure():
          return AppResult.failure(response);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<List>> getCompliance() async {
    try {
      final response = await dioService.getDio(
        endpoint: 'compliance/getCompliance',
      );
      switch (response) {
        case AppSuccess():
          return AppSuccess((response.value['data'] as List<dynamic>).toList());
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<ConfigurationModel>> getConfiguration() async {
    try {
      final response = await dioService.getDio(
        endpoint: 'configuration/getConfiguration',
      );
      switch (response) {
        case AppSuccess():
          return AppSuccess(
              ConfigurationModel.fromJson(response.value['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<bool>> submitExam(List<QuestionModel> paper, String testID,
      {int? timestamp}) async {
    try {
      bool isOnline = await _checkInternet();

      List<Map<String, dynamic>> answerPaper = paper.map((question) {
        Map<String, dynamic> questionData = question.toJson();
        questionData['timeTaken'] = question.timeTaken;
        return questionData;
      }).toList();

      Map<String, dynamic> examData = {
        "answerPaper": answerPaper,
        "userId": AppLocalStorage.instance.user.userId,
        "questionId": testID,
      };

      if (timestamp != null && timestamp > 0) {
        examData['timestamp'] = timestamp;
      }

      if (!isOnline) {
        examData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
        AppLocalStorage.instance.storeExamOffline(examData);
        return AppResult.success(true);
      }

      final response = await dioService.postDio(
          endpoint: 'answerPaper/saveAnswePaper', body: examData);
      switch (response) {
        case AppSuccess():
          AppLocalStorage.instance.removeSingleExamFromStorage(examData);
          return const AppSuccess(true);
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<List<SingleExamHistoryModel>>> getExamHistory(
      {required String userId}) async {
    try {
      final response = await dioService
          .postDio(endpoint: 'report/getAllExamByUserId', body: {
        "userId": userId,
      });
      switch (response) {
        case AppSuccess():
          return AppSuccess((response.value['data'] as List<dynamic>)
              .map((e) => SingleExamHistoryModel.fromJson(e))
              .toList());
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<bool> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<AppResult<TestResultDetailModel>> getTestResultDetails(
      {required String userId, required String qID}) async {
    try {
      final response =
          await dioService.postDio(endpoint: 'answerPaper/getResult', body: {
        "userId": userId,
        "questionId": qID,
      });

      switch (response) {
        case AppSuccess():
          return AppSuccess(
              TestResultDetailModel.fromJson(response.value['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<bool>> createExam(Map<String, dynamic> examData) async {
    try {
      final response = await dioService.postDio(
          endpoint: 'questionPaper/createQuestionPaper', body: examData);

      switch (response) {
        case AppSuccess():
          return AppResult.success(true);
        case AppFailure():
          return AppResult.failure(AppFailure(
              errorMessage: response.errorMessage, code: response.code));
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  void forgotPassword(String text) async {
    try {
      final response =
          await dioService.postDio(endpoint: 'user/forceLogOutRequest', body: {
        "email": text,
      });

      switch (response) {
        case AppSuccess():
          AppSnackbarWidget.showSnackBar(
              isSuccess: true,
              subTitle:
                  'You are log out forcefully\n you will get email for reset pass...');
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: response.errorMessage);
      }
    } catch (e) {}
  }

  Future<AppResult<List<Map<String, dynamic>>>> getStudentListByQuestionId(
      String questionId) async {
    try {
      final response = await dioService
          .postDio(endpoint: 'report/getAllUserByExamId', body: {
        "id": questionId,
      });

      switch (response) {
        case AppSuccess():
          return AppResult.success(
              List<Map<String, dynamic>>.from(response.value['data']));
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: response.errorMessage);
          return const AppFailure();
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  int calculateTotalExamTime(List<QuestionModel> questions) {
    return questions.fold(0, (total, question) => total + question.timeTaken);
  }

  Map<String, dynamic> getTimeStatistics(List<QuestionModel> questions) {
    final times =
        questions.map((q) => q.timeTaken).where((t) => t > 0).toList();

    if (times.isEmpty) {
      return {
        'totalTime': 0,
        'averageTime': 0,
        'maxTime': 0,
        'minTime': 0,
        'questionsAttempted': 0,
      };
    }

    times.sort();

    return {
      'totalTime': times.reduce((a, b) => a + b),
      'averageTime': times.reduce((a, b) => a + b) / times.length,
      'maxTime': times.last,
      'minTime': times.first,
      'questionsAttempted': times.length,
    };
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> getDetailedTimeAnalysis(
      List<QuestionModel> questions) {
    return questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;

      return {
        'questionNumber': index + 1,
        'question': question.question,
        'timeTaken': question.timeTaken,
        'formattedTime': formatTime(question.timeTaken),
        'answered': (question.userAnswer?.isNotEmpty ?? false),
        'correct': question.userAnswer == question.correctAnswer,
        'timeEfficiency': question.timeTaken > 0
            ? (question.userAnswer == question.correctAnswer
                ? 'Efficient'
                : 'Needs Improvement')
            : 'Not Attempted',
      };
    }).toList();
  }
}
