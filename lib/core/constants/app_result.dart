import 'package:offline_test_app/core/constants/app_string_constants.dart';

sealed class AppResult<T> {
  const AppResult();

  factory AppResult.success(T s) => AppSuccess(s);
  factory AppResult.failure(AppFailure f) => f;

  @override
  String toString() {
    return switch (this) {
      AppSuccess<T> s => 'AppResult.success(${s.value})',
      AppFailure f => 'AppResult.failure(error: ${f.errorMessage}, code: ${f.code})',
    };
  }
}

class AppSuccess<T> extends AppResult<T> {
  final T value;
  const AppSuccess(this.value);

  @override
  String toString() => 'AppSuccess($value)';
}

class AppFailure extends AppResult<Never> {
  final String? code;
  final String errorMessage;

  /// If `errorMessage` is `null` or empty, assign a default value
  const AppFailure({String? errorMessage, this.code})
      : errorMessage = errorMessage ?? AppStringConstants.somethingWentWrong;

  @override
  String toString() => 'AppFailure(error: $errorMessage, code: $code)';
}

/// Generic class for API failures with default messages
class AppFailureWithMessage extends AppFailure {
  const AppFailureWithMessage({String? errorMessage, super.code})
      : super(errorMessage: errorMessage ?? AppStringConstants.somethingWentWrong);
}

/// Internet & Timeout Related Errors
class AppNoInternetFailure extends AppFailureWithMessage {
  const AppNoInternetFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.noInternet);
}

class AppConnectionTimeOutFailure extends AppFailureWithMessage {
  const AppConnectionTimeOutFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.connectionTimeOut);
}

class AppRequestTimeOutFailure extends AppFailureWithMessage {
  const AppRequestTimeOutFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.timeOuterror);
}

/// Client Side Errors (4xx)
class AppBadRequestFailure extends AppFailureWithMessage {
  const AppBadRequestFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.badRequest);
}

class AppUnauthorizedFailure extends AppFailureWithMessage {
  const AppUnauthorizedFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.unAuthrized);
}

class AppForbiddenFailure extends AppFailureWithMessage {
  const AppForbiddenFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.forbidden);
}

class AppDataNotFoundFailure extends AppFailureWithMessage {
  const AppDataNotFoundFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.dataNotFound);
}

class AppClientSideError extends AppFailureWithMessage {
  const AppClientSideError({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.clientSideError);
}

/// **Fixes: Adding missing classes**
class ApUnAuthorizedFailure extends AppFailureWithMessage {
  const ApUnAuthorizedFailure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.unAuthrized);
}

class AppForbidFailuure extends AppFailureWithMessage {
  const AppForbidFailuure({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.forbidden);
}

class AppClientSideStautsError extends AppFailureWithMessage {
  const AppClientSideStautsError({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.clientSideError);
}

/// Server Side Errors (5xx)
class AppInternalServerError extends AppFailureWithMessage {
  const AppInternalServerError({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.serverSideError);
}

class AppServerSideError extends AppFailureWithMessage {
  const AppServerSideError({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.serverSideError);
}

class AppUnableToProcessRequest extends AppFailureWithMessage {
  const AppUnableToProcessRequest({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.serverUnableToProccessRequest);
}

class AppBadGatewayError extends AppFailureWithMessage {
  const AppBadGatewayError({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.badGatewayError);
}

class AppServerNotAvailable extends AppFailureWithMessage {
  const AppServerNotAvailable({String? errorMessage})
      : super(errorMessage: errorMessage ?? AppStringConstants.serverNotAvailbale);
}

/// Specific API Success Response with additional data
class AppClientSuccessStatus<T> extends AppFailure {
  final T data;
  const AppClientSuccessStatus({String? errorMessage, required this.data, super.code})
      : super(errorMessage: errorMessage ?? AppStringConstants.clientSideError);
}
