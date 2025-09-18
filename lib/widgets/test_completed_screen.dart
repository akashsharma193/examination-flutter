import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/controllers/home_controller.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';
import 'package:crackitx/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TestCompletedScreen extends StatefulWidget {
  final List<QuestionModel> list;
  final String testID;
  final bool isAlreadySubmitted;

  const TestCompletedScreen({
    super.key,
    required this.list,
    required this.testID,
    this.isAlreadySubmitted = false,
  });

  @override
  State<TestCompletedScreen> createState() => _TestCompletedScreenState();
}

class _TestCompletedScreenState extends State<TestCompletedScreen> {
  bool _isSubmitting = false;
  bool _isLoadingAd = false;
  InterstitialAd? _interstitialAd;

  Future<bool> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    final result =
        connectivityResult.where((e) => e != ConnectivityResult.none);
    return result.isNotEmpty;
  }

  void _loadAdAndNavigate() async {
    if (!await _checkInternet()) {
      return;
    }

    setState(() {
      _isLoadingAd = true;
    });

    final adUnitId = AdHelper.getInterstitialVideoAdUnitId();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              setState(() {
                _isLoadingAd = false;
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              Get.offAllNamed('/home');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              setState(() {
                _isLoadingAd = false;
              });
              Get.offAllNamed('/home');
            },
          );

          _interstitialAd!.show();
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _isLoadingAd = false;
          });
          Get.offAllNamed('/home');
        },
      ),
    );
  }

  void _goToHome() async {
    Get.delete<HomeController>(force: true);
    _loadAdAndNavigate();
  }

  void submitExam() async {
    if (_isSubmitting) return;

    if (widget.isAlreadySubmitted) {
      _goToHome();
      return;
    }

    if (!await _checkInternet()) {
      AppSnackbarWidget.showSnackBar(
          isSuccess: false, subTitle: 'No internet Connection available');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ExamRepo().submitExam(widget.list, widget.testID);

      switch (result) {
        case AppSuccess(value: bool v):
          AppSnackbarWidget.showSnackBar(
              isSuccess: v,
              subTitle: 'Exam submitted status : ${v ? 'Success' : 'Failed'}');
          if (v) {
            _goToHome();
          }
          break;
        case AppFailure():
          AppSnackbarWidget.showSnackBar(
              isSuccess: false, subTitle: result.errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!_isSubmitting && !_isLoadingAd) {
          _goToHome();
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  "Thanks Note",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "You have successfully completed the test.\nGreat job!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                if (!widget.isAlreadySubmitted)
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Note: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondaryColor),
                        ),
                        TextSpan(
                          text: "To submit your exam, please ",
                        ),
                        TextSpan(
                          text: "turn on your internet connection now",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              ". The app requires an active internet connection to securely upload your answers. ",
                        ),
                        TextSpan(
                          text:
                              "Do not close or kill the app during this process",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondaryColor),
                        ),
                        TextSpan(
                          text:
                              ". If the app is closed before submission, your exam may not be submitted and your attempt could be marked as incomplete or lost. Ensure you stay on this screen until you see the confirmation that your paper has been successfully submitted.",
                        ),
                      ],
                    ),
                  ),
                if (widget.isAlreadySubmitted)
                  const Text(
                    "Your exam has been successfully submitted!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                const SizedBox(height: 30),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: (_isSubmitting || _isLoadingAd) ? null : submitExam,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: (_isSubmitting || _isLoadingAd)
                              ? [Colors.grey.shade400, Colors.grey.shade500]
                              : [
                                  const Color(0xFF9181F4),
                                  const Color(0xFF5038ED)
                                ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: (_isSubmitting || _isLoadingAd)
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isSubmitting
                                        ? "Submitting..."
                                        : "Loading Ad...",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                widget.isAlreadySubmitted
                                    ? "Go to Home"
                                    : "Go to Home",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
