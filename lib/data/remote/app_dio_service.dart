import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/state_manager.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/data/remote/network_log_interceptor.dart';
import 'package:crackitx/services/device_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:get/get.dart' as getx;

class AppDioService {
  static AppDioService instance = AppDioService._();
  AppDioService._();
  factory AppDioService() {
    return instance;
  }
  static Dio get dio => Dio();

  final Dio _serviceDio = dio;
  bool _isRefreshing = false;
  final List<Completer<String?>> _failedQueue = [];

  void _processQueue(dynamic error, String? token) {
    for (final completer in _failedQueue) {
      if (!completer.isCompleted) {
        if (error != null) {
          completer.completeError(error);
        } else {
          completer.complete(token);
        }
      }
    }
    _failedQueue.clear();
  }

  Map<String, String> get _getHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'encDisabled': 'false',
    };

    final token = AppLocalStorage.instance.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  String _encryptData(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return base64Encode(utf8.encode(jsonString));
  }

  Map<String, dynamic> _decryptData(String encryptedData) {
    final decodedBytes = base64Decode(encryptedData);
    final jsonString = utf8.decode(decodedBytes);
    return jsonDecode(jsonString);
  }

  Future<void> initDioService(
      {required String baseUrl, List<Interceptor>? interceptors}) async {
    _serviceDio.options = BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'deviceId': await DeviceService.instance.uniqueDeviceId,
          'encDisabled': 'false',
          'Origin': 'https://crackitx.contentive.in',
        },
        connectTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        validateStatus: (code) {
          return code != null && code >= 200 && code <= 503;
        },
        contentType: 'application/json');

    if (kDebugMode) {
      _serviceDio.interceptors.add(PrettyDioLogger(
          request: true, requestBody: true, responseBody: true));
    }

    _serviceDio.interceptors.addAllIf(interceptors != null, interceptors ?? []);
    _serviceDio.interceptors.add(NetworkLogInterceptor());

    _serviceDio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.data != null &&
              response.data is Map<String, dynamic> &&
              response.data.containsKey('encPayloadRes')) {
            response.data = _decryptData(response.data['encPayloadRes']);
          }

          if (response.statusCode == 401) {
            _handle401Error(response, handler);
            return;
          }

          handler.next(response);
        },
        onError: (error, handler) async {
          final originalRequest = error.requestOptions;

          if (error.response?.data != null &&
              error.response!.data is Map<String, dynamic> &&
              error.response!.data.containsKey('encPayloadRes')) {
            error.response!.data =
                _decryptData(error.response!.data['encPayloadRes']);
          }

          if (error.response?.statusCode == 401 &&
              originalRequest.extra['retry'] != true) {
            if (originalRequest.path.contains('/user-open/login')) {
              handler.next(error);
              return;
            }

            if (_isRefreshing) {
              final completer = Completer<String?>();
              _failedQueue.add(completer);

              try {
                final newToken = await completer.future;
                if (newToken != null) {
                  final retryOptions = Options(
                    method: originalRequest.method,
                    headers: {
                      ...originalRequest.headers,
                      'Authorization': 'Bearer $newToken',
                    },
                    extra: {
                      ...originalRequest.extra,
                      'retry': true,
                    },
                  );

                  final response = await _serviceDio.request(
                    originalRequest.path,
                    options: retryOptions,
                    data: originalRequest.data,
                    queryParameters: originalRequest.queryParameters,
                  );
                  handler.resolve(response);
                  return;
                }
              } catch (e) {
                handler.next(error);
                return;
              }
            }

            originalRequest.extra['retry'] = true;
            _isRefreshing = true;

            final refreshToken = AppLocalStorage.instance.refreshToken;
            final userId = AppLocalStorage.instance.user.userId;

            if (refreshToken == null ||
                refreshToken.isEmpty ||
                userId.isEmpty) {
              _handleLogout('Session expired. Please login again.');
              _processQueue(error, null);
              _isRefreshing = false;
              handler.next(error);
              return;
            }

            try {
              final refreshDio = Dio();
              refreshDio.options = BaseOptions(
                baseUrl: _serviceDio.options.baseUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'encDisabled': 'false',
                },
                connectTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              );

              final refreshPayload = {
                'refreshToken': refreshToken,
                'userId': userId,
              };

              final refreshBody = {
                'encPayload': _encryptData(refreshPayload),
              };

              final refreshResponse = await refreshDio.post(
                '/user-open/refreshToken',
                data: refreshBody,
              );

              Map<String, dynamic> responseData = refreshResponse.data;

              if (responseData.containsKey('encPayloadRes')) {
                responseData = _decryptData(responseData['encPayloadRes']);
              }

              if (responseData['success'] == true &&
                  responseData.containsKey('data')) {
                final data = responseData['data'];
                final newToken = data['token'];
                final newRefreshToken = data['refreshToken'];
                final newUserId = data['userId'];

                if (newToken != null) {
                  AppLocalStorage.instance.setTokens(newToken, newRefreshToken);

                  final retryOptions = Options(
                    method: originalRequest.method,
                    headers: {
                      ...originalRequest.headers,
                      'Authorization': 'Bearer $newToken',
                    },
                    extra: {
                      ...originalRequest.extra,
                      'retry': true,
                    },
                  );

                  _processQueue(null, newToken);

                  final response = await _serviceDio.request(
                    originalRequest.path,
                    options: retryOptions,
                    data: originalRequest.data,
                    queryParameters: originalRequest.queryParameters,
                  );

                  handler.resolve(response);
                  return;
                } else {
                  throw Exception('No access token in refresh response');
                }
              } else {
                throw Exception(
                    'Invalid refresh token response: ${responseData['message'] ?? 'Unknown error'}');
              }
            } catch (refreshError) {
              _processQueue(refreshError, null);

              if (refreshError is DioException) {
                final statusCode = refreshError.response?.statusCode;
                if (statusCode == 401 ||
                    statusCode == 403 ||
                    statusCode == 400) {
                  _handleLogout('Session expired. Please login again.');
                } else if (statusCode != null && statusCode >= 500) {
                  _handleLogout('Server error. Please try logging in again.');
                } else {
                  _handleLogout('Authentication failed. Please login again.');
                }
              } else {
                _handleLogout('Authentication failed. Please login again.');
              }

              handler.next(error);
            } finally {
              _isRefreshing = false;
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _handle401Error(
      Response response, ResponseInterceptorHandler handler) async {
    final originalRequest = response.requestOptions;

    if (originalRequest.path.contains('/user-open/login')) {
      final error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
      handler.reject(error);
      return;
    }

    if (_isRefreshing) {
      final completer = Completer<String?>();
      _failedQueue.add(completer);

      try {
        final newToken = await completer.future;
        if (newToken != null) {
          final retryOptions = Options(
            method: originalRequest.method,
            headers: {
              ...originalRequest.headers,
              'Authorization': 'Bearer $newToken',
            },
            extra: {
              ...originalRequest.extra,
              'retry': true,
            },
          );

          final response = await _serviceDio.request(
            originalRequest.path,
            options: retryOptions,
            data: originalRequest.data,
            queryParameters: originalRequest.queryParameters,
          );
          handler.resolve(response);
          return;
        }
      } catch (e) {
        final error = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
        handler.reject(error);
        return;
      }
    }

    if (originalRequest.extra['retry'] == true) {
      final error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
      handler.reject(error);
      return;
    }

    _isRefreshing = true;

    final refreshToken = AppLocalStorage.instance.refreshToken;
    final userId = AppLocalStorage.instance.user.userId;

    if (refreshToken == null || refreshToken.isEmpty || userId.isEmpty) {
      _handleLogout('Session expired. Please login again.');
      _processQueue(response, null);
      _isRefreshing = false;
      final error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
      handler.reject(error);
      return;
    }

    try {
      final refreshDio = Dio();
      refreshDio.options = BaseOptions(
        baseUrl: _serviceDio.options.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'encDisabled': 'false',
        },
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      );

      final refreshPayload = {
        'refreshToken': refreshToken,
        'userId': userId,
      };

      final refreshBody = {
        'encPayload': _encryptData(refreshPayload),
      };

      final refreshResponse = await refreshDio.post(
        '/user-open/refreshToken',
        data: refreshBody,
      );

      Map<String, dynamic> responseData = refreshResponse.data;

      if (responseData.containsKey('encPayloadRes')) {
        responseData = _decryptData(responseData['encPayloadRes']);
      }

      if (responseData['success'] == true && responseData.containsKey('data')) {
        final data = responseData['data'];
        final newToken = data['token'];
        final newRefreshToken = data['refreshToken'];
        final newUserId = data['userId'];

        if (newToken != null) {
          AppLocalStorage.instance.setTokens(newToken, newRefreshToken);

          final retryOptions = Options(
            method: originalRequest.method,
            headers: {
              ...originalRequest.headers,
              'Authorization': 'Bearer $newToken',
            },
            extra: {
              ...originalRequest.extra,
              'retry': true,
            },
          );

          _processQueue(null, newToken);

          final retryResponse = await _serviceDio.request(
            originalRequest.path,
            options: retryOptions,
            data: originalRequest.data,
            queryParameters: originalRequest.queryParameters,
          );

          handler.resolve(retryResponse);
          return;
        } else {
          throw Exception('No access token in refresh response');
        }
      } else {
        throw Exception(
            'Invalid refresh token response: ${responseData['message'] ?? 'Unknown error'}');
      }
    } catch (refreshError) {
      _processQueue(refreshError, null);

      if (refreshError is DioException) {
        final statusCode = refreshError.response?.statusCode;
        if (statusCode == 401 || statusCode == 403 || statusCode == 400) {
          _handleLogout('Session expired. Please login again.');
        } else if (statusCode != null && statusCode >= 500) {
          _handleLogout('Server error. Please try logging in again.');
        } else {
          _handleLogout('Authentication failed. Please login again.');
        }
      } else {
        _handleLogout('Authentication failed. Please login again.');
      }

      final error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
      handler.reject(error);
    } finally {
      _isRefreshing = false;
    }
  }

  void _handleLogout(String message) {
    AppLocalStorage.instance.clearTokens();
    AppLocalStorage.instance.setIsUserLoggedIn(false);

    Get.snackbar('Session Expired', message);
    Get.offAllNamed('/login');
  }

  Future<AppResult> getDio(
      {required String endpoint,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      final mergedHeaders = {..._getHeaders, ...?headers};
      Map<String, dynamic>? encryptedQueryParams;

      if (queryParams != null && queryParams.isNotEmpty) {
        final encryptedData = _encryptData(queryParams);
        encryptedQueryParams = {'encPayload': encryptedData};
      }

      final response = await _serviceDio.get(
        endpoint,
        queryParameters: encryptedQueryParams,
        options: Options(headers: mergedHeaders),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioExceptionError(e);
    } catch (e, s) {
      return _handleCaughtError(e, s);
    }
  }

  Future<AppResult> postDio({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final mergedHeaders = {..._getHeaders, ...?headers};
      final encryptedData = _encryptData(body);
      final encryptedBody = {'encPayload': encryptedData};

      final response = await _serviceDio.post(
        endpoint,
        data: encryptedBody,
        queryParameters: queryParams,
        options: Options(headers: mergedHeaders),
      );

      return _handleResponse(response);
    } on SocketException {
      return AppResult.failure(const AppNoInternetFailure());
    } on DioException catch (e) {
      return _handleDioExceptionError(e);
    } catch (e, s) {
      return _handleCaughtError(e, s);
    }
  }

  Future<AppResult> deleteDio(
      {required String endpoint,
      required Map<String, dynamic> body,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      final mergedHeaders = {..._getHeaders, ...?headers};
      final encryptedData = _encryptData(body);
      final encryptedBody = {'encPayload': encryptedData};

      final response = await _serviceDio.delete(
        endpoint,
        data: encryptedBody,
        queryParameters: queryParams,
        options: Options(headers: mergedHeaders),
      );

      if (response.statusCode == 204) {
        return const AppSuccess(null);
      } else {
        return _handleResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioExceptionError(e);
    } catch (e, s) {
      return _handleCaughtError(e, s);
    }
  }

  AppResult _handleResponse(Response response) {
    Map<String, dynamic> responseData = {};

    if (response.data is Map<String, dynamic> &&
        response.data.containsKey('encPayloadRes')) {
      try {
        responseData = _decryptData(response.data['encPayloadRes']);
      } catch (e) {
        responseData = response.data;
      }
    } else if (response.data is Map<String, dynamic>) {
      responseData = response.data;
    } else {
      responseData = {'data': response.data};
    }

    if (response.statusCode! >= 200 && response.statusCode! <= 299) {
      if (responseData.containsKey('success') &&
          responseData['success'] == false) {
        return AppResult.failure(AppFailure(
          errorMessage: responseData['message'] ?? 'Request failed',
          code: responseData['errorCode'] ?? response.statusCode.toString(),
        ));
      }
      return AppSuccess(responseData);
    } else {
      return _handleErrorResponse(response, responseData);
    }
  }

  AppResult _handleErrorResponse(
      Response response, Map<String, dynamic> responseData) {
    final errorMessage = responseData['message'] ??
        _getDefaultErrorMessage(response.statusCode!);
    final errorCode =
        responseData['errorCode'] ?? response.statusCode.toString();

    return AppResult.failure(AppFailure(
      errorMessage: errorMessage,
      code: errorCode,
    ));
  }

  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  AppResult _handleCaughtError(Object e, StackTrace s) {
    return AppResult.failure(const AppFailure());
  }

  AppResult _handleDioExceptionError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return AppResult.failure(const AppNoInternetFailure());
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return AppResult.failure(const AppConnectionTimeOutFailure());
    } else if (e.type == DioExceptionType.sendTimeout) {
      return AppResult.failure(const AppRequestTimeOutFailure());
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return AppResult.failure(const AppRequestTimeOutFailure());
    } else if (e.type == DioExceptionType.badResponse) {
      if (e.response?.data != null) {
        Map<String, dynamic> responseData = {};

        if (e.response!.data is Map<String, dynamic> &&
            e.response!.data.containsKey('encPayloadRes')) {
          try {
            responseData = _decryptData(e.response!.data['encPayloadRes']);
          } catch (_) {
            responseData = e.response!.data;
          }
        } else if (e.response!.data is Map<String, dynamic>) {
          responseData = e.response!.data;
        }

        final errorMessage = responseData['message'] ??
            _getDefaultErrorMessage(e.response!.statusCode!);
        final errorCode =
            responseData['errorCode'] ?? e.response!.statusCode.toString();

        return AppResult.failure(AppFailure(
          errorMessage: errorMessage,
          code: errorCode,
        ));
      }
      return AppResult.failure(const AppFailure());
    } else {
      return AppResult.failure(const AppFailure());
    }
  }
}
