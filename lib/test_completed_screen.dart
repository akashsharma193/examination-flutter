import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class TestCompletedScreen extends StatelessWidget {
 final List<QuestionModel> list ;
 final String testID;

  const TestCompletedScreen({super.key, required this.list, required this.testID});
  Future<bool> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final result = connectivityResult.where((e)=>e!=ConnectivityResult.none);
    return result.isNotEmpty;
  }

  void _goToHome() async {
    bool hasInternet = await _checkInternet();
    if (hasInternet) {
      ExamRepo repo = ExamRepo();
      repo.submitExam(list, testID);
      Get.offAllNamed('/home'); // Navigate to home page
    } else {
      Get.snackbar(
        "No Internet",
        "Please connect to the internet to proceed.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
              Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              SizedBox(height: 20),
              Text(
                "Congratulations!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "You have successfully completed the test.\nGreat job!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _goToHome,
                child: Text("Go to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
