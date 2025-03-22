import 'dart:developer';
import 'package:offline_test_app/app_models/app_user_model.dart';
import 'package:offline_test_app/core/constants/api_endpoints.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/remote/app_dio_service.dart';

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
      log("error caught in Admin repo getAllUserList func : $e");
      return AppResult.failure(const AppFailure());
    }
  }
}
