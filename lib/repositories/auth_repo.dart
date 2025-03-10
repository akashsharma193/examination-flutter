import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:offline_test_app/app_models/app_user_model.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/data/remote/app_dio_service.dart';
import 'package:offline_test_app/services/firebase_services_app.dart';

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
      }
    } catch (e) {
      log("error caught in auth repo login func : $e");
      return AppResult.failure(const AppFailure());
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
          return const AppSuccess(null);
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      log("error caught in auth repo Logout func : $e");
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<UserModel>> register(Map<String, dynamic> body) async {
    try {
      final response =
          await dioService.postDio(endpoint: 'user/registration', body: body);
      debugPrint("response of registration  : ${response.runtimeType}");
      switch (response) {
        case AppSuccess():
          debugPrint("case Success-----");
          return AppSuccess(UserModel.fromJson(response.value['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      log("error caught in auth repo registration func : $e");
      return AppResult.failure(const AppFailure());
    }
  }

  /// call  FCM api
  Future<AppResult<dynamic>> saveFCMToken({required String userId}) async {
    try {
      final token = await FirebaseService().getFcmToken();
      if (token == null || token.isEmpty) {
        return AppResult.success(null);
      }
      final response = await dioService.postDio(
          endpoint: 'user/saveFcmToken',
          body: {
            "fcmToken": token,
            "userId": AppLocalStorage.instance.user.userId
          });
      debugPrint("response of saveFCMToken  : ${response.runtimeType}");
      switch (response) {
        case AppSuccess():
          debugPrint("case Success-----");
          return const AppSuccess(null);
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      log("error caught in auth repo saveFCMToken func : $e");
      return AppResult.failure(const AppFailure());
    }
  }
}
