import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';

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
    if (await _checkInternet()) {
      Get.offAllNamed('/home'); // Navigate to home page
    }
  }

  void submitExam() async {
    if (!await _checkInternet()) {
      AppSnackbarWidget.showSnackBar(
          isSuccess: false, subTitle: 'No internet Connection available');
      return;
    }
    ExamRepo()
        .submitExam(
      list,
      testID,
    )
        .then((v) {
      switch (v) {
        case AppSuccess(value: bool v):
          AppSnackbarWidget.showSnackBar(
              isSuccess: v,
              subTitle: 'exam submitted status : ${v ? 'Success' : 'Failed'}');
          _goToHome();
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: v.errorMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (await _checkInternet()) {
          Get.offAllNamed('/home');
        }
      },
      child: Scaffold(
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
                const SizedBox(height: 10),
                const Text(
                  "To submit your exam, please turn on your internet connection now. The app requires an active internet connection to securely upload your answers. Do not close or kill the app during this process. If the app is closed before submission, your exam may not be submitted and your attempt could be marked as incomplete or lost. Ensure you stay on this screen until you see the confirmation that your paper has been successfully submitted.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: submitExam,
                  child: const Text("Go to Home"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
