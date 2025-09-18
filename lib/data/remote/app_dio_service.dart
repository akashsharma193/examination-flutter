import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/state_manager.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/data/remote/network_log_interceptor.dart';
import 'package:crackitx/services/device_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class AppDioService {
  static AppDioService instance = AppDioService._();
  AppDioService._();
  factory AppDioService() {
    return instance;
  }
  static Dio get dio => Dio();

  final Dio _serviceDio = dio;

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
          'Origin': 'https://examdy.in',
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
  }

  Future<AppResult> getDio(
      {required String endpoint,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      final mergedHeaders = {..._getHeaders, ...?headers};
      Map<String, dynamic> encryptedQueryParams = {};

      if (queryParams != null) {
        final encryptedData = _encryptData(queryParams);
        encryptedQueryParams = {'encPayload': encryptedData};
      }

      return _serviceDio
          .get(endpoint,
              queryParameters: encryptedQueryParams,
              options: Options(headers: mergedHeaders))
          .then((v) {
        return _handleResponse(v);
      });
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

      final response = await _serviceDio.post(endpoint,
          data: encryptedBody,
          queryParameters: queryParams,
          options: Options(headers: mergedHeaders));

      return _handleResponse(response);
    } on SocketException {
      return AppResult.failure(const AppNoInternetFailure());
    } on DioException catch (e) {
      return _handleDioExceptionError(e);
    } catch (e, s) {
      log("💥 [DIO] Unknown Error in POST request: $endpoint",
          error: e, stackTrace: s);
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

      return _serviceDio
          .delete(endpoint,
              data: encryptedBody,
              queryParameters: queryParams,
              options: Options(headers: mergedHeaders))
          .then((v) {
        if (v.statusCode == 204) {
          return const AppSuccess(null);
        } else {
          return _handleResponse(v);
        }
      });
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
      responseData = _decryptData(response.data['encPayloadRes']);
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
    log('\n<---------------- \n Error Caught in Dio Service File \n',
        name: 'Dio service Caught Error \n ', error: e, stackTrace: s);

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
