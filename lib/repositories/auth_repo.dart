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
      debugPrint("response of login  : ${response.runtimeType}");
      switch (response) {
        case AppSuccess():
          debugPrint("case Success-----");
          return AppSuccess(UserModel.fromJson(response.value['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
        default:
          return AppFailure(
              errorMessage: 'Failed to login in Auth Repo default case');
      }
    } catch (e) {
      log("error caught in auth repo login func : $e");
      return AppResult.failure(AppFailure());
    }
  }

  /// call  login api
  Future<AppResult<dynamic>> logOut({required String userId}) async {
    try {
      final response = await dioService
          .postDio(endpoint: 'user/logOut', body: {"userId": userId});
      debugPrint("response of logout  : ${response.runtimeType}");
      switch (response) {
        case AppSuccess():
          debugPrint("case Success-----");
          return AppSuccess(null);
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
        default:
          return AppFailure(
              errorMessage: 'Failed to logout in Auth Repo default case');
      }
    } catch (e) {
      log("error caught in auth repo Logout func : $e");
      return AppResult.failure(AppFailure());
    }
  }
}
