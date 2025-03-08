import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/data/remote/network_log_interceptor.dart';
import 'package:offline_test_app/services/device_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class AppDioService {
  static AppDioService instance = AppDioService._();
  AppDioService._();
  factory AppDioService() {
    return instance;
  }
  static Dio get dio => Dio();

  final Dio _serviceDio = dio;

  Future<void> initDioService(
      {required String baseUrl, List<Interceptor>? interceptors}) async {
    _serviceDio.options = BaseOptions(
        baseUrl: baseUrl,
        headers: {'deviceId': await DeviceService.instance.uniqueDeviceId},
        connectTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        validateStatus: (code){
          return code!=null && code >=200 && code <=503;
        },
        contentType: 'application/json');
    _serviceDio.interceptors.addAll(interceptors ?? []);

    _serviceDio.interceptors.add(NetworkLogInterceptor());
  }

  /// Get Request DIO
  Future<AppResult> getDio(
      {required String endpoint,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      return _serviceDio.get(endpoint, queryParameters: queryParams).then((v) {
        if (v.statusCode == 200) {
          return AppSuccess(v.data);
        } else {
          return _handleOtherStatusCodeResponse(v);
        }
      });
    } on DioException catch (e) {
      return _handleDioExceptionError(e);
    } catch (e, s) {
      debugPrint("error caught in get request in Dio service  :$e");

      return _handleCaughtError(e, s);
    }
    // return AppResult.failure(AppFailure());
  }

  /// POST Request DIO
  Future<AppResult> postDio({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    try {
      log("📡 [DIO] Sending POST request to: $endpoint");
      log("📌 [DIO] Request Body: $body");
      log("🔍 [DIO] Query Params: $queryParams");

      final response = await _serviceDio.post(endpoint, data: body, queryParameters: queryParams);

      log("✅ [DIO] Response received from: $endpoint");
      log("🔗 [DIO] Status Code: ${response.statusCode}");
      log("📩 [DIO] Response Data: ${response.data}");

      if (response.statusCode == 201) {
        return AppSuccess(response.data);
      } else {
        return _handleOtherStatusCodeResponse(response);
      }
    } on SocketException catch (e) {
      log("🚫 [DIO] SocketException in POST: No Internet - $e");
      return AppResult.failure(AppNoInternetFailure());
    } on DioException catch (e) {
      log("❌ [DIO] DioException in POST request: $endpoint");
      return _handleDioExceptionError(e);
    } catch (e, s) {
      log("💥 [DIO] Unknown Error in POST request: $endpoint", error: e, stackTrace: s);
      return _handleCaughtError(e, s);
    }
  }


  /// Delete Request DIO
  Future<AppResult> deleteDio(
      {required String endpoint,
      required Map<String, dynamic> body,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      return _serviceDio
          .delete(endpoint, data: body, queryParameters: queryParams)
          .then((v) {
        if (v.statusCode == 204) {
          return AppSuccess(null);
        } else {
          return _handleOtherStatusCodeResponse(v);
        }
      });
    } on DioException catch (e) {
      _handleDioExceptionError(e);
    } catch (e, s) {
      debugPrint("error caught in POST request in Dio service  :$e");

      return _handleCaughtError(e, s);
    }
    return AppResult.failure(AppFailure());
  }
}

_handleCaughtError(Object e, StackTrace s) {
  log('\n<---------------- \n Error Caught in Dio Service File \n',
      name: 'Dio service Caught Error \n ', error: e, stackTrace: s);

  return AppResult.failure(AppFailure());
}

AppResult _handleDioExceptionError(DioException e) {
  log("❌ DioException caught in API request: ${e.requestOptions.uri}");
  log("👉 Dio Error Type: ${e.type}");
  log("📝 Error Message: ${e.message}");
  log("🔗 Status Code: ${e.response?.statusCode}");
  log("📡 Response Data: ${e.response?.data}");
  if (e.type == DioExceptionType.connectionError) {
    log("no internet available.....");
    return AppResult.failure(AppNoInternetFailure());
  }else
  if (e.type == DioExceptionType.connectionTimeout) {
    return AppResult.failure(AppConnectionTimeOutFailure());
  } else if (e.type == DioExceptionType.sendTimeout) {
    return AppResult.failure(AppRequestTimeOutFailure());
  } else if (e.type == DioExceptionType.receiveTimeout) {
    return AppResult.failure(AppRequestTimeOutFailure());
  }
  else if (e.type == DioExceptionType.badResponse) {
    return AppResult.failure(AppRequestTimeOutFailure());
  }
  else if (e.response?.statusCode != null) {
    if ((e.response?.statusCode ?? 0) >= 400) {
      return _handleClientSideError(e.response);
    } else {
      return _handleServerSideError(e.response);
    }
  } else {
    return AppResult.failure(AppFailure());
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
    return AppResult.failure(AppClientSideStautsError());
  }
  switch (r.statusCode ?? 0) {
    case 400:
      return AppResult.failure(AppBadRequestFailure(errorMessage: r.data['message']));
    case 401:
      return AppResult.failure(ApUnAuthorizedFailure(errorMessage: r.data['message']));
    case 403:
      return AppResult.failure(AppForbidFailuure(errorMessage: r.data['message']));
    case 404:
      return AppResult.failure(AppDataNotFoundFailure(errorMessage: r.data['message']));
    default:
      return AppResult.failure(AppClientSideStautsError(errorMessage: r.data['message']));
  }
}

_handleServerSideError(Response? r) {
  if (r == null) {
    return AppResult.failure(AppServerSideError());
  }
  switch (r.statusCode ?? 0) {
    case 500:
      return AppResult.failure(AppBadRequestFailure(errorMessage: r.data['message']));
    case 501:
      return AppResult.failure(ApUnAuthorizedFailure(errorMessage: r.data['message']));
    case 502:
      return AppResult.failure(AppForbidFailuure(errorMessage: r.data['message']));
    case 503:
      return AppResult.failure(AppDataNotFoundFailure(errorMessage: r.data['message']));
    default:
      return AppResult.failure(AppServerSideError(errorMessage: r.data['message']));
  }
}
