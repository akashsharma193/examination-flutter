import 'dart:async';

import 'package:crackitx/app_models/configuration_model.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/app_models/app_user_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/theme/app_theme.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/repositories/auth_repo.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/services/internet_service_checker.dart';
import 'package:crackitx/widgets/app_dialog.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();

  static HomeController init() {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    return Get.find<HomeController>();
  }

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isCompliencesLoading = false.obs;
  RxBool isConfigurationLoading = false.obs;
  RxBool isUserProfileLoading = false.obs;
  RxBool isChecked = false.obs;
  RxBool isSearching = false.obs;

  RxList<ExamModel> allExams = <ExamModel>[].obs;
  RxList<ExamModel> filteredExams = <ExamModel>[].obs;
  RxList<Map<String, dynamic>> compliences = <Map<String, dynamic>>[].obs;
  ConfigurationModel configuration = ConfigurationModel.toEmpty();
  ExamModel selectedExam = ExamModel.toEmpty();
  Rx<UserModel> userProfile = UserModel.toEmpty().obs;

  RxMap<String, String> examTimers = <String, String>{}.obs;

  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  int currentPage = 0;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalElements = 0;
  int totalPages = 0;

  final ExamRepo examRepo = ExamRepo();
  final AuthRepo authRepo = AuthRepo();

  bool isRequestInProgress = false;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    if (!_isInitialized) {
      _isInitialized = true;
      refreshPage();
    }

    ever(isLoadingMore, (bool loading) {
      print("isLoadingMore changed to: $loading");
    });

    ever(allExams, (List<ExamModel> exams) {
      print("allExams length changed to: ${exams.length}");
      if (!isSearching.value) {
        filteredExams.value = exams;
      }
    });

    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterExams();
    });
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
      filteredExams.value = allExams;
    }
  }

  void filterExams() {
    if (searchQuery.value.isEmpty) {
      filteredExams.value = allExams;
    } else {
      filteredExams.value = allExams.where((exam) {
        return exam.subjectName
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  void refreshPage() {
    currentPage = 0;
    hasNextPage = false;
    isRequestInProgress = false;
    getAndSubmitOfflinePendingExams();
    isLoading(false);
    isCompliencesLoading(false);
    isUserProfileLoading(false);
    isChecked(false);
    isSearching(false);
    searchController.clear();
    searchQuery.value = '';
    allExams.clear();
    filteredExams.clear();
    compliences.clear();
    userProfile.value = UserModel.toEmpty();
    Future.delayed(Durations.medium3, () {
      getExams();
      getUserProfile();
    });
    update();
  }

  void loadMoreExams() async {
    if (isLoadingMore.value || !hasNextPage || isRequestInProgress) return;

    try {
      isRequestInProgress = true;
      isLoadingMore.value = true;
      currentPage++;

      final resp = await examRepo.getAllExams(
          orgCode: AppLocalStorage.instance.user.orgCode,
          batchId: AppLocalStorage.instance.user.batch,
          pageNumber: currentPage,
          pageSize: pageSize);

      switch (resp) {
        case AppSuccess():
          final data = resp.value;
          List<ExamModel> newExams = data['content'] ?? [];

          if (newExams.isNotEmpty) {
            allExams.addAll(newExams);
          }

          hasNextPage = data['hasNext'] ?? false;
          hasPreviousPage = data['hasPrevious'] ?? false;
          totalElements = data['totalElements'] ?? 0;
          totalPages = data['totalPages'] ?? 0;

          _initializeTimers();
          break;
        case AppFailure():
          currentPage--;
          Fluttertoast.showToast(
              msg: 'Failed to load more exams: ${resp.errorMessage}');
          break;
      }
    } finally {
      isLoadingMore.value = false;
      isRequestInProgress = false;
    }
  }

  getAndSubmitOfflinePendingExams() async {
    final unSubmitedExams =
        AppLocalStorage.instance.getOfflineUnSubmittedExams();

    for (Map<String, dynamic> item in unSubmitedExams) {
      List<QuestionModel> questionList = List<QuestionModel>.from(
          item['answerPaper'].map(
              (e) => QuestionModel.fromJson(Map<String, dynamic>.from(e))));
      final res = await examRepo.submitExam(questionList, item['questionId'],
          timestamp: item["timestamp"]);

      switch (res) {
        case AppSuccess():
          break;
        case AppFailure():
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void getUserProfile() async {
    try {
      isUserProfileLoading.value = true;
      update();
      final resp = await authRepo.getUserProfile();

      switch (resp) {
        case AppSuccess():
          userProfile.value = resp.value;
          break;
        case AppFailure():
          Fluttertoast.showToast(
              msg: 'Failed to fetch user profile: ${resp.errorMessage}');
          userProfile.value = UserModel.toEmpty();
          break;
      }
    } finally {
      isUserProfileLoading.value = false;
      update();
    }
  }

  void getExams() async {
    try {
      isLoading.value = true;
      isRequestInProgress = true;
      update();
      print(
          "Getting initial exams - currentPage: $currentPage, pageSize: $pageSize");

      final resp = await examRepo.getAllExams(
          orgCode: AppLocalStorage.instance.user.orgCode,
          batchId: AppLocalStorage.instance.user.batch,
          pageNumber: currentPage,
          pageSize: pageSize);

      switch (resp) {
        case AppSuccess():
          final data = resp.value;
          List<ExamModel> exams = data['content'] ?? [];
          allExams.value = exams;

          hasNextPage = data['hasNext'] ?? false;
          hasPreviousPage = data['hasPrevious'] ?? false;
          totalElements = data['totalElements'] ?? 0;
          totalPages = data['totalPages'] ?? 0;

          _initializeTimers();
          break;
        case AppFailure():
          print("Failed to fetch exams: ${resp.errorMessage}");
          Fluttertoast.showToast(
              msg: 'Failed to fetch exam : ${resp.errorMessage}');
          allExams.value = [];
          break;
      }
    } finally {
      isLoading.value = false;
      isRequestInProgress = false;
      update();
    }
  }

  void _initializeTimers() {
    for (var exam in allExams) {
      _startCountdown(exam.questionId ?? 'uniqExam', exam.startTime);
    }
  }

  void _startCountdown(String examId, DateTime startTime) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remaining = startTime.difference(now);

      if (remaining.isNegative) {
        examTimers[examId] = "Exam Started!";
        timer.cancel();
      } else {
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;
        examTimers[examId] = "$hours h : $minutes m : $seconds s";
      }

      examTimers.refresh();
    });
  }

  void logOut() async {
    try {
      final AuthRepo repo = AuthRepo();
      repo.logOut(userId: AppLocalStorage.instance.user.userId);
      AppLocalStorage.instance.clearStorage();
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  getConfiguration() async {
    try {
      isConfigurationLoading.value = true;
      update();
      final resp = await examRepo.getConfiguration();

      switch (resp) {
        case AppSuccess():
          configuration = resp.value;
          break;
        case AppFailure():
          configuration = ConfigurationModel.toEmpty();
          Fluttertoast.showToast(
              msg: 'Failed to fetch configuration: ${resp.errorMessage}');
      }
    } finally {
      isConfigurationLoading.value = false;
      update();
    }
  }

  getCompliances() async {
    try {
      isCompliencesLoading.value = true;
      update();
      final resp = await examRepo.getCompliance();

      switch (resp) {
        case AppSuccess():
          compliences.value =
              resp.value.map((e) => e as Map<String, dynamic>).toList();
          break;
        case AppFailure():
          compliences.value = [];
      }
    } finally {
      isCompliencesLoading.value = false;
      update();
    }
  }

  void showExamNotLiveDialog({bool isExamEnded = false}) {
    AppDialog().show(
      title: isExamEnded ? 'Exam Ended' : 'Exam not Started yet!',
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(isExamEnded
            ? 'This Exam has Ended, please Attempt Live or Upcoming Exams!'
            : 'Exam will start soon, come back when Exam is Live!'),
      ),
      buttonText: 'Ok',
      onPressed: () => Get.back(),
      restrictBack: false,
      isDismissible: true,
    );
  }

  void showConfigBasedAcknowledgementDialog() async {
    await getCompliances();

    isChecked.value = false;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Test Acknowledgement",
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (isConfigurationLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (configuration.isInternetDisabled == true)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border:
                                    Border.all(color: Colors.orange.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.wifi_off,
                                      color: Colors.orange.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Internet must be disabled to start this exam. Please turn off your internet connection before proceeding.",
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (compliences.isNotEmpty) ...[
                            Text(
                              "Instructions:",
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...compliences.map((compliance) => _buildReminder(
                                compliance['compliance'] as String? ?? '')),
                            const SizedBox(height: 16),
                          ],
                          CheckboxListTile(
                            title: Text(
                              "I acknowledge the instructions and requirements.",
                              style: AppTheme.bodyMedium
                                  .copyWith(color: Colors.black),
                            ),
                            value: isChecked.value,
                            onChanged: (value) {
                              isChecked.value = value!;
                              setState(() {});
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  "Cancel",
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: isChecked.value
                                    ? () => _handleExamStart()
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.cardBackground,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text("Start Exam"),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _handleExamStart() async {
    bool isInternetConnected =
        await InternetServiceChecker().isInternetConnected;

    if (configuration.isInternetDisabled == true) {
      if (isInternetConnected) {
        AppSnackbarWidget.showSnackBar(
          isSuccess: false,
          subTitle:
              'Please disable your internet connection to start this exam.',
        );
        return;
      }
    }

    Get.back();
    Get.toNamed('/exam-screen', arguments: {
      "questions": selectedExam.questionList ?? [],
      "testId": selectedExam.questionId ?? '',
      'name': selectedExam.subjectName,
      'time': selectedExam.examDuration ?? '0',
    });
  }

  Widget _buildReminder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    for (String examId in examTimers.keys) {
      Timer? timer = Timer(Duration.zero, () {});
      timer?.cancel();
    }
    searchController.dispose();
    super.onClose();
  }
}
