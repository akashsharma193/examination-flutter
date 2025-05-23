import 'package:crackitx/app_models/app_user_model.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/core/constants/api_endpoints.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/remote/app_dio_service.dart';

class AdminRepo {
  final dioService = AppDioService.instance;

  Future<AppResult<List<UserModel>>> getAllUserList({
    required String orgCode,
  }) async {
    try {
      final response = await dioService.postDio(
          endpoint: ApiEndpoints.getAllUsersList,
          body: {"orgCode": orgCode, "isActive": true});
      switch (response) {
        case AppSuccess():
          return AppSuccess((response.value['data'] as List<dynamic>)
              .map((e) => UserModel.fromJson(e))
              .toList());
        case AppFailure():
          return AppResult.failure(response);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<UserModel>> fetchUserDetails(String userId,
      {required String orgCode}) async {
    try {
      final response = await dioService.postDio(
          endpoint: ApiEndpoints.getAllUsersList,
          body: {"orgCode": orgCode, "userId": userId});
      switch (response) {
        case AppSuccess():
          return AppSuccess(UserModel.fromJson(response.value['data'] ?? {}));
        case AppFailure():
          return AppResult.failure(response);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<UserModel>> updateUserDetails(
      Map<String, dynamic> body) async {
    try {
      final response =
          await dioService.postDio(endpoint: 'user/registration', body: body);
      switch (response) {
        case AppSuccess():
          return AppSuccess(UserModel.fromJson(response.value['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<List<SingleExamHistoryModel>>> getAllExamsList(
      String orgCode) async {
    try {
      final response = await dioService.postDio(
          endpoint: ApiEndpoints.getAllExamsList, body: {"orgCode": orgCode});
      switch (response) {
        case AppSuccess():
          return AppSuccess((response.value['data'] as List)
              .map((e) => SingleExamHistoryModel.fromJson(Map.from(e)))
              .toList());
        case AppFailure():
          return AppResult.failure(response);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<Map<String, dynamic>>> getReportCount(String orgCode) async {
    try {
      final response = await dioService.postDio(
        endpoint: 'report/getCount',
        body: {"id": orgCode},
      );
      switch (response) {
        case AppSuccess():
          return AppSuccess(response.value['data']);
        case AppFailure():
          return AppResult.failure(response);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }
}
