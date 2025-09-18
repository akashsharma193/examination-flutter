import 'package:crackitx/app_models/app_user_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/data/remote/app_dio_service.dart';
import 'package:crackitx/services/firebase_services_app.dart';
import 'package:get/get.dart';

class AuthRepo {
  final dioService = AppDioService.instance;

  Future<AppResult<UserModel>> login(
      {required String user, required String pass}) async {
    try {
      final response = await dioService.postDio(
          endpoint: 'user-open/login', body: {'email': user, 'password': pass});

      switch (response) {
        case AppSuccess():
          final responseData = response.value;

          if (responseData['data'] != null) {
            final data = responseData['data'];

            if (responseData.containsKey('data') &&
                data.containsKey('token') &&
                data.containsKey('refreshToken')) {
              AppLocalStorage.instance
                  .setTokens(data['token'], data['refreshToken']);
            }

            if (data.containsKey('userId')) {
              AppLocalStorage.instance.setUserId(data['userId']);
            }

            if (data.containsKey('role')) {
              AppLocalStorage.instance.setUserRole(data['role']);
            }
          }

          return AppSuccess(UserModel.fromJson(responseData['data']));
        case AppFailure():
          return AppFailure(
              errorMessage: response.errorMessage, code: response.code);
      }
    } catch (e) {
      return AppResult.failure(const AppFailure());
    }
  }

  Future<AppResult<bool>> refreshToken() async {
    try {
      final refreshToken = AppLocalStorage.instance.refreshToken;
      final userId = AppLocalStorage.instance.userId;

      if (refreshToken == null || refreshToken.isEmpty || userId.isEmpty) {
        _forceLogout();
        return AppResult.failure(
            const AppFailure(errorMessage: 'Session expired'));
      }

      final response = await dioService.postDio(
        endpoint: 'user-open/refreshToken',
        body: {'refreshToken': refreshToken, 'userId': userId},
      );

      switch (response) {
        case AppSuccess():
          final responseData = response.value;
          if (responseData['data'] != null) {
            final data = responseData['data'];
            if (data.containsKey('token') && data.containsKey('refreshToken')) {
              AppLocalStorage.instance
                  .setTokens(data['token'], data['refreshToken']);
              return const AppSuccess(true);
            }
          }
          _forceLogout();
          return AppResult.failure(
              const AppFailure(errorMessage: 'Session expired'));
        case AppFailure():
          _forceLogout();
          return AppFailure(
              errorMessage: 'Session expired', code: response.code);
      }
    } catch (e) {
      _forceLogout();
      return AppResult.failure(
          const AppFailure(errorMessage: 'Session expired'));
    }
  }

  void _forceLogout() {
    AppLocalStorage.instance.clearTokens();
    AppLocalStorage.instance.setIsUserLoggedIn(false);
    Get.snackbar('Session Expired', 'Please login again');
    Get.offAllNamed('/login');
  }

  Future<AppResult<dynamic>> logOut({required String userId}) async {
    try {
      final response = await dioService.postDio(
        endpoint: 'user-secured/logOut',
        body: {"userId": userId},
      );

      switch (response) {
        case AppSuccess():
          AppLocalStorage.instance.clearTokens();
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
      final response = await dioService.postDio(
          endpoint: 'user-open/registration', body: body);

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

  Future<AppResult<dynamic>> saveFCMToken({required String userId}) async {
    try {
      final token = await AppFirebaseService.instance.getFcmToken();
      if (token == null || token.isEmpty) {
        return AppResult.success(null);
      }
      final response = await dioService
          .postDio(endpoint: 'user-secured/saveFcmToken', body: {
        "fcmToken": token,
      });

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

  Future<AppResult<bool>> sendTempPassword(String email) async {
    try {
      final response = await dioService.postDio(
        endpoint: 'user-open/sendTempPassword',
        body: {'id': email},
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

  Future<AppResult<bool>> resetPassword({
    required String email,
    required String tempPassword,
    required String newPassword,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'tempPassword': tempPassword,
        'password': newPassword,
        'email': email,
      };

      final response = await dioService.postDio(
        endpoint: 'user-open/resetPassword',
        body: requestBody,
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

  Future<AppResult<UserModel>> getUserProfile() async {
    try {
      final response = await dioService.getDio(
        endpoint: 'user-activity/getUserProfile',
      );

      switch (response) {
        case AppSuccess():
          return AppSuccess(UserModel.fromJson(response.value['data']));
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
