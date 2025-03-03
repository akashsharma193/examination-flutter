import 'package:offline_test_app/core/constants/app_string_constants.dart';

sealed class AppResult<T> {
  AppResult();
  factory AppResult.success(T s) => AppSuccess(s);
  factory AppResult.failure(AppFailure f) =>
      AppFailure(errorMessage: f.errorMessage, code: f.code);

  @override
  String toString() {
    return switch (this) {
      AppSuccess<T> s => 'AppResult.success(${s.value})',
      AppFailure f =>
        'AppResult.failure(error: ${f.errorMessage}, code: ${f.code})',
    };
  }
}

class AppSuccess<T> extends AppResult<T> {
  T value;
  AppSuccess(this.value);

  @override
  String toString() => 'AppSuccess($value)';
}

class AppFailure<T> extends AppResult<T> {
  String? code;
  String errorMessage;
  AppFailure({required this.errorMessage, this.code});

  @override
  String toString() => 'AppFailure(error: $errorMessage, code: $code)';
}

class AppNoInternetFailure extends AppFailure {
  AppNoInternetFailure({super.errorMessage = AppStringConstants.noInternet});
}

class AppSomethingWentWrong extends AppFailure {
  AppSomethingWentWrong({super.errorMessage = AppStringConstants.unAuthrized});
}

class AppBadRequestFailure extends AppFailure {
  AppBadRequestFailure({super.errorMessage = AppStringConstants.badRequest});
}

class AppDataNotFoundFailure extends AppFailure {
  AppDataNotFoundFailure(
      {super.errorMessage = AppStringConstants.dataNotFound});
}

class ApUnAuthorizedFailure extends AppFailure {
  ApUnAuthorizedFailure({super.errorMessage = AppStringConstants.unAuthrized});
}

class AppForbidFailuure extends AppFailure {
  AppForbidFailuure({super.errorMessage = AppStringConstants.forbidden});
}

class AppClientSideStautsError extends AppFailure {
  AppClientSideStautsError(
      {super.errorMessage = AppStringConstants.clientSideError});
}

class AppInternalServerError extends AppFailure {
  AppInternalServerError(
      {super.errorMessage = AppStringConstants.serverSideError});
}

class AppServerSideError extends AppFailure {
  AppServerSideError({super.errorMessage = AppStringConstants.serverSideError});
}

class AppUnableToProcessRequest extends AppFailure {
  AppUnableToProcessRequest(
      {super.errorMessage = AppStringConstants.serverUnableToProccessRequest});
}

class AppBadGatewayError extends AppFailure {
  AppBadGatewayError({super.errorMessage = AppStringConstants.badGatewayError});
}

class AppServerNotAvailable extends AppFailure {
  AppServerNotAvailable(
      {super.errorMessage = AppStringConstants.serverNotAvailbale});
}

class AppConnectionTimeOutFailure extends AppFailure {
  AppConnectionTimeOutFailure(
      {super.errorMessage = AppStringConstants.connectionTimeOut});
}

class AppRequestTimeOutFailure extends AppFailure {
  AppRequestTimeOutFailure(
      {super.errorMessage = AppStringConstants.timeOuterror});
}

class AppClientSuccessStatus<T> extends AppFailure {
  final T data;
  AppClientSuccessStatus(
      {required super.errorMessage, required this.data, super.code});
}
