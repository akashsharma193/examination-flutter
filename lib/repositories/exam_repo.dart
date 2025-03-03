import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:offline_test_app/app_models/app_user_model.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/remote/app_dio_service.dart';

class ExamRepo {
  final dioService = AppDioService.instance;

  /// call  login api
  Future<AppResult<List<GetExamModel>>> getAllExams(
      {required String orgCode, required String batchId}) async {
    try {
      final response = await dioService.postDio(
          endpoint: 'questionPaper/getExam',
          body: {"orgCode": orgCode, "batch": batchId});
      switch (response) {
        case AppSuccess():
          return AppSuccess((response.value['data'] as List<dynamic>)
              .map((e) => GetExamModel.fromJson(e))
              .toList());
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
        default:
          return AppFailure(
              errorMessage:
                  'Failed to fetch all exams in Exam Repo default case');
      }
    } catch (e) {
      log("error caught in Exam repo getALlExams func : $e");
      return AppResult.failure(AppSomethingWentWrong());
    }
  }
}
