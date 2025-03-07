import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
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
        connectTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
        validateStatus: (code){
          return code!=null && code >=200 && code <=503;
        },
        contentType: 'application/json');
    _serviceDio.interceptors.addAll(interceptors ?? []);

    _serviceDio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      maxWidth: 90,
      enabled: true,
    ));
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
    // return AppResult.failure(AppSomethingWentWrong());
  }

  /// POST Request DIO
  Future<AppResult> postDio(
      {required String endpoint,
      required Map<String, dynamic> body,
      Map<String, dynamic>? queryParams,
      Map<String, dynamic>? headers}) async {
    try {
      return _serviceDio
          .post(endpoint, data: body, queryParameters: queryParams)
          .then((v) {
        if (v.statusCode == 201) {
          return AppSuccess(v.data);
        } else {
          return _handleOtherStatusCodeResponse(v);
        }
      });
    } on DioException catch (e) {
      return _handleDioExceptionError(e);
    } catch (e, s) {
      debugPrint("error caught in POST request in Dio service  :$e");

      return _handleCaughtError(e, s);
    }
    // return AppResult.failure(AppSomethingWentWrong());
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
    return AppResult.failure(AppSomethingWentWrong());
  }
}

_handleCaughtError(Object e, StackTrace s) {
  log('\n<---------------- \n Error Caught in Dio Service File \n',
      name: 'Dio service Caught Error \n ', error: e, stackTrace: s);

  return AppSomethingWentWrong();
}

AppResult _handleDioExceptionError(DioException e) {
  log("Error caught in DioException on api :  ${e.requestOptions.uri}\n,error: ${e.error},message: ${e.message}");

  if (e.type == DioExceptionType.connectionError) {
    log("no internet available.....");
    return AppNoInternetFailure();
  }
  if (e.type == DioExceptionType.connectionTimeout) {
    return AppConnectionTimeOutFailure();
  } else if (e.type == DioExceptionType.sendTimeout) {
    return AppRequestTimeOutFailure();
  } else if (e.type == DioExceptionType.receiveTimeout) {
    return AppRequestTimeOutFailure();
  }
  else if (e.type == DioExceptionType.badResponse) {
    return AppRequestTimeOutFailure();
  }
  else if (e.response?.statusCode != null) {
    if ((e.response?.statusCode ?? 0) >= 400) {
      return _handleClientSideError(e.response);
    } else {
      return _handleServerSideError(e.response);
    }
  } else {
    return AppSomethingWentWrong();
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
      return AppSomethingWentWrong(
          errorMessage: 'Something Went Wrong... ${r.statusCode}');
  }
}

AppFailure _handleClientSideError(Response? r) {
  if (r == null) {
    return AppClientSideStautsError();
  }
  switch (r.statusCode ?? 0) {
    case 400:
      return AppBadRequestFailure(errorMessage: r.data['message']);
    case 401:
      return ApUnAuthorizedFailure(errorMessage: r.data['message']);
    case 403:
      return AppForbidFailuure(errorMessage: r.data['message']);
    case 404:
      return AppDataNotFoundFailure(errorMessage: r.data['message']);
    default:
      return AppClientSideStautsError(errorMessage: r.data['message']);
  }
}

_handleServerSideError(Response? r) {
  if (r == null) {
    return AppServerSideError();
  }
  switch (r.statusCode ?? 0) {
    case 500:
      return AppBadRequestFailure(errorMessage: r.data['message']);
    case 501:
      return ApUnAuthorizedFailure(errorMessage: r.data['message']);
    case 502:
      return AppForbidFailuure(errorMessage: r.data['message']);
    case 503:
      return AppDataNotFoundFailure(errorMessage: r.data['message']);
    default:
      return AppServerSideError(errorMessage: r.data['message']);
  }
}
