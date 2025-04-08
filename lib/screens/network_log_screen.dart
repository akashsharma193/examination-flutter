import 'package:flutter/material.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/data/remote/network_log_interceptor.dart';

class ScaffoldNetworkScreen extends StatelessWidget {
  const ScaffoldNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: NetworkLogScreen(),
    );
  }
}

class NetworkLogScreen extends StatelessWidget {
  const NetworkLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = NetworkLogInterceptor.networkLogs;
    return logs.isEmpty
        ? Center(
            child: Text('No Logs..'),
          )
        : ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final logData = logs[index];
              final request = logData["request"];
              final response = logData["response"];
              final error = logData["error"];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: ExpansionTile(
                    collapsedBackgroundColor: response != null
                        ? (response["statusCode"] == 200 ||
                                response["statusCode"] == 201
                            ? Colors.green.shade200
                            : Colors.red.shade200)
                        : Colors.grey.shade300,
                    title: Text(request?["url"] ?? "Unknown URL",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Status: ${response?["statusCode"] ?? error?["statusCode"] ?? 'Pending'}"),
                    children: [
                      if (request != null) _buildLogTile("📡 Request", request),
                      if (response != null)
                        _buildLogTile("✅ Response", response),
                      if (error != null) _buildLogTile("❌ Error", error),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildLogTile(String title, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          _buildTextRow("Timestamp", data["timestamp"]),
          _buildTextRow("URL", data["url"]),
          if (data["method"] != null) _buildTextRow("Method", data["method"]),
          if (data["statusCode"] != null)
            _buildTextRow("Status Code", data["statusCode"].toString()),
          if (data["queryParams"] != null)
            _buildTextRow("Query Params", data["queryParams"].toString()),
          if (data["requestBody"] != null)
            _buildTextRow("Request Body", data["requestBody"].toString()),
          if (data["responseBody"] != null)
            _buildTextRow("Response Body", data["responseBody"].toString()),
          if (data["errorMessage"] != null)
            _buildTextRow("Error Message", data["errorMessage"]),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTextRow(String key, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$key: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "N/A", softWrap: true)),
        ],
      ),
    );
  }
}
