import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class NetworkLogInterceptor extends Interceptor {
  static final Map<String, Map<String, dynamic>> _networkLogs = {};
  static const Uuid _uuid = Uuid();
  static List<Map<String, dynamic>> get networkLogs =>
      _networkLogs.values.toList().reversed.toList();

  void _addLog(String requestId, String type, Map<String, dynamic> log) {
    if (!_networkLogs.containsKey(requestId)) {
      _networkLogs[requestId] = {
        "request": null,
        "response": null,
        "error": null
      };
    }

    _networkLogs[requestId]![type] = log;

    // Keep logs manageable (e.g., limit to 50 entries)
    if (_networkLogs.length > 100) {
      _networkLogs.remove(_networkLogs.keys.first);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = _uuid.v4(); // Generate unique request ID
    options.extra["requestId"] = requestId;
    final logEntry = {
      "requestId": requestId,
      "timestamp": DateTime.now().toIso8601String(),
      "type": "Request",
      "url": options.uri.toString(),
      "method": options.method,
      "headers": options.headers,
      "queryParams": options.queryParameters,
      "requestBody": options.data,
    };

    _addLog(requestId, "request", logEntry);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra["requestId"] ?? "Unknown";

    final logEntry = {
      "requestId": requestId,
      "timestamp": DateTime.now().toIso8601String(),
      "type": "Response",
      "url": response.requestOptions.uri.toString(),
      "statusCode": response.statusCode,
      "responseBody": response.data,
    };

    _addLog(requestId, "response", logEntry);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.extra["requestId"] ?? "Unknown";

    final logEntry = {
      "requestId": requestId,
      "timestamp": DateTime.now().toIso8601String(),
      "type": "Error",
      "url": err.requestOptions.uri.toString(),
      "errorType": err.type.toString(),
      "errorMessage": err.message,
      "statusCode": err.response?.statusCode,
      "responseBody": err.response?.data,
    };

    _addLog(requestId, "error", logEntry);

    super.onError(err, handler);
  }
}
