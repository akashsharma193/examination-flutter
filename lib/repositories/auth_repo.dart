import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:offline_test_app/app_models/app_user_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/remote/app_dio_service.dart';

class AuthRepo {
  final dioService = AppDioService.instance;

  /// call  login api
  Future<AppResult<UserModel>> login(
      {required String user, required String pass}) async {
    try {
      final response = await dioService.postDio(
          endpoint: 'user/login', body: {'email': user, 'password': pass});

      switch (response) {
        case AppSuccess():
          return AppResult.success(UserModel.fromJson(response.value));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
        default:
          return AppFailure(
              errorMessage: 'Failed to login in Auth Repo default case');
      }
    } catch (e) {
      log("erro caught in auth repo login func : $e");
      return AppResult.failure(AppSomethingWentWrong());
    }
  }
}
