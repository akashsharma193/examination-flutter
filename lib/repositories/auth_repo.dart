import 'package:crackitx/app_models/app_user_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/data/remote/app_dio_service.dart';
import 'package:crackitx/services/firebase_services_app.dart';

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
          return AppSuccess(UserModel.fromJson(response.value['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  /// call  login api
  Future<AppResult<dynamic>> logOut({required String userId}) async {
    try {
      final response = await dioService
          .postDio(endpoint: 'user/logOut', body: {"userId": userId});

      switch (response) {
        case AppSuccess():
          return const AppSuccess(null);
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<UserModel>> register(Map<String, dynamic> body) async {
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

  /// call  FCM api
  // Future<AppResult<dynamic>> saveFCMToken({required String userId}) async {
  //   try {
  //     final token = await AppFirebaseService.instance.getFcmToken();
  //     if (token == null || token.isEmpty) {
  //       return AppResult.success(null);
  //     }
  //     final response = await dioService.postDio(
  //         endpoint: 'user/saveFcmToken',
  //         body: {
  //           "fcmToken": token,
  //           "userId": AppLocalStorage.instance.user.userId
  //         });

  //     switch (response) {
  //       case AppSuccess():
  //         return const AppSuccess(null);
  //       case AppFailure():
  //         return AppFailure(
  //             errorMessage: response.errorMessage, code: response.code);
  //     }
  //   } catch (e) {
  //     return AppResult.failure(const AppFailure());
  //   }
  // }

  Future<AppResult<bool>> sendTempPassword(String email) async {
    try {
      final response = await dioService.postDio(
        endpoint: 'user/sendTempPassword',
        body: {'id': email},
      );
      switch (response) {
        case AppSuccess():
          return const AppSuccess(true); // Assuming no specific data returned
        case AppFailure():
          return AppFailure(
            errorMessage: response.errorMessage,
            code: response.code,
          );
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<bool>> resetPassword({
    required String email,
    required String tempPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dioService.postDio(
        endpoint: 'user/resetPassword',
        body: {
          'email': email,
          'tempPassword': tempPassword,
          'password': newPassword,
        },
      );
      switch (response) {
        case AppSuccess():
          return const AppSuccess(true);
        case AppFailure():
          return AppFailure(
            errorMessage: response.errorMessage,
            code: response.code,
          );
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }
}
