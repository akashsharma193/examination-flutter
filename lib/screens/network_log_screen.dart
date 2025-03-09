import 'package:flutter/material.dart';
import 'package:offline_test_app/data/remote/network_log_interceptor.dart';

class NetworkLogScreen extends StatelessWidget {
  const NetworkLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = NetworkLogInterceptor.networkLogs;

    return Scaffold(
      appBar: AppBar(title: const Text('Network Logs')),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              collapsedBackgroundColor:
                  log["statusCode"] == 200 || log["statusCode"] == 201
                      ? Colors.green
                      : Colors.red,
              title: Text(log["url"],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Status: ${log["statusCode"] ?? 'Error'}"),
              children: [
                _buildLogTile("Headers", log["headers"]),
                _buildLogTile("Query Params", log["queryParams"]),
                _buildLogTile("Request Body", log["requestBody"]),
                _buildLogTile("Response", log["responseBody"]),
                _buildLogTile("Error Message", log["errorMessage"]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogTile(String title, dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(data != null ? data.toString() : 'No Data'),
          const Divider(),
        ],
      ),
    );
  }
}
