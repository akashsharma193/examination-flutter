import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';
import 'package:offline_test_app/widgets/app_snackbar_widget.dart';

class TestCompletedScreen extends StatelessWidget {
  final List<QuestionModel> list;
  final String testID;

  const TestCompletedScreen(
      {super.key, required this.list, required this.testID});
  Future<bool> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final result =
        connectivityResult.where((e) => e != ConnectivityResult.none);
    return result.isNotEmpty;
  }

  void _goToHome() async {
    Get.offAllNamed('/home'); // Navigate to home page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Test Completed")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                "Congratulations!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "You have successfully completed the test.\nGreat job!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _goToHome,
                child: const Text("Go to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
