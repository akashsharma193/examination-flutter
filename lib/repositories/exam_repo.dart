import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/app_models/test_result_detail_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/data/remote/app_dio_service.dart';

class ExamRepo {
  final dioService = AppDioService.instance;

  /// call  login api
  Future<AppResult<List<GetExamModel>>> getAllExams(
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
              .map((e) => GetExamModel.fromJson(e))
              .toList());
        case AppFailure():
          return AppResult.failure(response);
      }
    } catch (e) {
      log("error caught in Exam repo getALlExams func : $e");
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
      log("error caught in Exam repo getCompliance func : $e");
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<bool>> submitExam(
      List<QuestionModel> paper, String testID) async {
    try {
      log("calling sub exam in exam repo  :${DateTime.now()}");
      bool isOnline = await _checkInternet();
      Map<String, dynamic> examData = {
        "answerPaper": paper.map((e) => e.toJson()).toList(),
        "userId": AppLocalStorage.instance.user.userId,
        "questionId": testID
      };

      if (!isOnline) {
        _storeExamOffline(testID, examData);
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
      log("error caught in Exam repo submitExam func : $e");
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<List<SingleExamHistoryModel>>> getExamHistory(
      {required String userId}) async {
    try {
      final response =
          await dioService.postDio(endpoint: 'answerPaper/getAllTest', body: {
        "userId": AppLocalStorage.instance.user.userId,
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
      log("error caught in Exam repo getExamHistory func : $e");
      return AppResult.failure(const AppFailure());
    }
  }

  Future<bool> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  Future<void> _storeExamOffline(
      String testId, Map<String, dynamic> examData) async {
    List<Map<String, dynamic>> pendingExams =
        (AppLocalStorage.instance.box.get('pending_exams') as List<dynamic>? ??
                [])
            .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
            .toList();
    pendingExams.add(examData);
    AppLocalStorage.instance.box
        .put('pending_exams', pendingExams.toSet().toList());
  }

  Future<AppResult<TestResultDetailModel>> getTestResultDetails(
      {required String userId, required String qID}) async {
    try {
      final response =
          await dioService.postDio(endpoint: 'answerPaper/getResult', body: {
        "userId": AppLocalStorage.instance.user.userId,
        "questionId": qID,
      });
      log("response of getresult: $response");

      switch (response) {
        case AppSuccess():
          return AppSuccess(
              TestResultDetailModel.fromJson(response.value['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
     
      }
    } catch (e) {
      log("error caught in Exam repo getTestResult func : $e");
      return AppResult.failure(const AppFailure());
    }
  }
}
