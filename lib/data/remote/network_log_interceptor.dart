import 'dart:developer';
import 'package:dio/dio.dart';

class NetworkLogInterceptor extends Interceptor {
  static final List<Map<String, dynamic>> _networkLogs = [];

  static List<Map<String, dynamic>> get networkLogs => _networkLogs.reversed.toList();

  void _addLog(Map<String, dynamic> log) {
    _networkLogs.add(log);

    // Keep logs manageable (e.g., limit to 50 entries)
    if (_networkLogs.length > 100) {
      _networkLogs.removeAt(0);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final logEntry = {
      "timestamp": DateTime.now().toIso8601String(),
      "type": "Request",
      "url": options.uri.toString(),
      "method": options.method,
      "headers": options.headers,
      "queryParams": options.queryParameters,
      "requestBody": options.data,
    };

    _addLog(logEntry);
    log("📡 [REQUEST] ${logEntry["url"]} \n📌 Query Params: ${logEntry["queryParams"]} \n📩 Body: ${logEntry["requestBody"]}");

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final logEntry = {
      "timestamp": DateTime.now().toIso8601String(),
      "type": "Response",
      "url": response.requestOptions.uri.toString(),
      "statusCode": response.statusCode,
      "responseBody": response.data,
    };

    _addLog(logEntry);
    log("✅ [RESPONSE] ${logEntry["url"]} \n🔗 Status Code: ${logEntry["statusCode"]} \n📩 Body: ${logEntry["responseBody"]}");

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final logEntry = {
      "timestamp": DateTime.now().toIso8601String(),
      "type": "Error",
      "url": err.requestOptions.uri.toString(),
      "errorType": err.type.toString(),
      "errorMessage": err.message,
      "statusCode": err.response?.statusCode,
      "responseBody": err.response?.data,
    };

    _addLog(logEntry);
    log("❌ [ERROR] ${logEntry["url"]} \n🔗 Status Code: ${logEntry["statusCode"]} \n📝 Message: ${logEntry["errorMessage"]}");

    super.onError(err, handler);
  }
}
