class NetworkLog {
  final String url;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? queryParams;
  final Map<String,dynamic>? requestBody;
  final int? statusCode;
  final Map<String,dynamic>? responseBody;
  final DateTime timestamp;

  NetworkLog({
    required this.url,
    this.headers,
    this.queryParams,
    this.requestBody,
    this.statusCode,
    this.responseBody,
  }) : timestamp = DateTime.now();
}
