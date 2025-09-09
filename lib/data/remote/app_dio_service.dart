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
        if (v.statusCode == 200) {
          if (v.data is Map<String, dynamic> &&
              v.data.containsKey('encPayloadRes')) {
            final decryptedData = _decryptData(v.data['encPayloadRes']);
            return AppSuccess(decryptedData);
          }
          return AppSuccess(v.data);
        } else {
          return _handleOtherStatusCodeResponse(v);
        }
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('encPayloadRes')) {
          final decryptedData = _decryptData(response.data['encPayloadRes']);
          return AppSuccess(decryptedData);
        }
        return AppSuccess(response.data);
      } else {
        return _handleOtherStatusCodeResponse(response);
      }
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
          if (v.data is Map<String, dynamic> &&
              v.data.containsKey('encPayloadRes')) {
            final decryptedData = _decryptData(v.data['encPayloadRes']);
            return AppSuccess(decryptedData);
          }
          return _handleOtherStatusCodeResponse(v);
        }
      });
    } on DioException catch (e) {
      _handleDioExceptionError(e);
    } catch (e, s) {
      return _handleCaughtError(e, s);
    }
    return AppResult.failure(const AppFailure());
  }
}

_handleCaughtError(Object e, StackTrace s) {
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
    return AppResult.failure(const AppRequestTimeOutFailure());
  } else if (e.response?.statusCode != null) {
    if ((e.response?.statusCode ?? 0) >= 400) {
      return _handleClientSideError(e.response);
    } else {
      return _handleServerSideError(e.response);
    }
  } else {
    return AppResult.failure(const AppFailure());
  }
}

AppResult _handleOtherStatusCodeResponse(Response r) {
  switch (r.statusCode ?? 0) {
    case > 100 && <= 201:
      return AppSuccess(r.data);
    case > 201 && < 300:
      return AppClientSuccessStatus(
          code: '${r.statusCode ?? 0}',
          errorMessage: 'statusCode :${r.statusCode}',
          data: r.data);
    case >= 400 && < 500:
      return _handleClientSideError(r);
    case > 500:
      return _handleServerSideError(r);
    default:
      return AppFailure(
          errorMessage: 'Something Went Wrong... ${r.statusCode}');
  }
}

AppResult _handleClientSideError(Response? r) {
  if (r == null) {
    return AppResult.failure(const AppClientSideStautsError());
  }
  switch (r.statusCode ?? 0) {
    case 400:
      return AppResult.failure(
          AppBadRequestFailure(errorMessage: r.data['message']));
    case 401:
      return AppResult.failure(
          ApUnAuthorizedFailure(errorMessage: r.data['message']));
    case 403:
      return AppResult.failure(
          AppForbidFailuure(errorMessage: r.data['message']));
    case 404:
      return AppResult.failure(
          AppDataNotFoundFailure(errorMessage: r.data['message']));
    default:
      return AppResult.failure(
          AppClientSideStautsError(errorMessage: r.data['message']));
  }
}

_handleServerSideError(Response? r) {
  if (r == null) {
    return AppResult.failure(const AppServerSideError());
  }
  switch (r.statusCode ?? 0) {
    case 500:
      return AppResult.failure(
          AppBadRequestFailure(errorMessage: r.data['message']));
    case 501:
      return AppResult.failure(
          ApUnAuthorizedFailure(errorMessage: r.data['message']));
    case 502:
      return AppResult.failure(
          AppForbidFailuure(errorMessage: r.data['message']));
    case 503:
      return AppResult.failure(
          AppDataNotFoundFailure(errorMessage: r.data['message']));
    default:
      return AppResult.failure(
          AppServerSideError(errorMessage: r.data['message']));
  }
}
