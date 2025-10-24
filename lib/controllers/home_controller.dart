import 'dart:async';
import 'package:crackitx/app_models/configuration_model.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/app_models/upcoming_exam_model.dart'
    as upcoming_exam_model;
import 'package:crackitx/app_models/missed_exam_model.dart';
import 'package:crackitx/app_models/app_user_model.dart';
import 'package:crackitx/controllers/auth_controller.dart';
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

enum ExamTab { active, upcoming, missed }

class HomeController extends GetxController {
  HomeController() {}
  static HomeController get to => Get.find<HomeController>();

  bool _isDisposed = false;
  List<Timer> _activeTimers = [];

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isCompliencesLoading = false.obs;
  RxBool isConfigurationLoading = false.obs;
  RxBool isUserProfileLoading = false.obs;
  RxBool isChecked = false.obs;
  RxBool isSearching = false.obs;
  RxBool isExamCardLoading = false.obs;

  Rx<ExamTab> currentTab = ExamTab.active.obs;

  RxList<ExamModel> allExams = <ExamModel>[].obs;
  RxList<ExamModel> filteredExams = <ExamModel>[].obs;
  RxList<upcoming_exam_model.UpcomingExamModel> upcomingExams =
      <upcoming_exam_model.UpcomingExamModel>[].obs;
  RxList<upcoming_exam_model.UpcomingExamModel> filteredUpcomingExams =
      <upcoming_exam_model.UpcomingExamModel>[].obs;
  RxList<MissedExamModel> missedExams = <MissedExamModel>[].obs;
  RxList<MissedExamModel> filteredMissedExams = <MissedExamModel>[].obs;

  RxList<Map<String, dynamic>> compliences = <Map<String, dynamic>>[].obs;
  ConfigurationModel configuration = ConfigurationModel.toEmpty();
  ExamModel selectedExam = ExamModel.toEmpty();
  Rx<UserModel> userProfile = UserModel.toEmpty().obs;

  RxMap<String, String> examTimers = <String, String>{}.obs;
  RxMap<String, String> upcomingExamTimers = <String, String>{}.obs;

  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  int activeCurrentPage = 0;
  int activePageSize = 10;
  bool activeHasNextPage = false;
  bool activeHasPreviousPage = false;
  int activeTotalElements = 0;
  int activeTotalPages = 0;

  int upcomingCurrentPage = 0;
  int upcomingPageSize = 10;
  bool upcomingHasNextPage = false;
  bool upcomingHasPreviousPage = false;
  int upcomingTotalElements = 0;
  int upcomingTotalPages = 0;

  int missedCurrentPage = 0;
  int missedPageSize = 10;
  bool missedHasNextPage = false;
  bool missedHasPreviousPage = false;
  int missedTotalElements = 0;
  int missedTotalPages = 0;

  final ExamRepo examRepo = ExamRepo();
  final AuthRepo authRepo = AuthRepo();

  bool activeRequestInProgress = false;
  bool upcomingRequestInProgress = false;
  bool missedRequestInProgress = false;
  bool complianceLoadError = false;

  @override
  void onInit() {
    super.onInit();
    if (!_isAuthenticated()) {
      return;
    }
    _setupSearchListener();
  }

  @override
  void onReady() {
    super.onReady();
    if (!_isAuthenticated()) {
      return;
    }
    _loadInitialData();
  }

  bool _isAuthenticated() {
    return AppLocalStorage.instance.isLoggedIn;
  }

  Future<void> _safeApiCall(Future<void> Function() apiCall) async {
    if (_isDisposed || !_isAuthenticated()) {
      return;
    }
    try {
      await apiCall();
    } catch (e) {
      if (!_isAuthenticated()) {
        return;
      }
      rethrow;
    }
  }

  void changeTab(ExamTab tab) {
    if (_isDisposed) return;
    currentTab.value = tab;
    searchController.clear();
    searchQuery.value = '';
    isSearching.value = false;

    switch (tab) {
      case ExamTab.active:
        if (allExams.isEmpty) {
          getExams();
        }
        break;
      case ExamTab.upcoming:
        if (upcomingExams.isEmpty) {
          getUpcomingExams();
        }
        break;
      case ExamTab.missed:
        if (missedExams.isEmpty) {
          getMissedExams();
        }
        break;
    }
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      if (_isDisposed) return;
      searchQuery.value = searchController.text;
      filterExams();
    });
  }

  void _loadInitialData() {
    getAndSubmitOfflinePendingExams();
    getUserProfile();
    getExams();
    getUpcomingExams();
    getMissedExams();
  }

  void toggleSearch() {
    if (_isDisposed) return;
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
      filterExams();
    }
  }

  void filterExams() {
    if (_isDisposed) return;
    if (searchQuery.value.isEmpty) {
      filteredExams.value = allExams;
      filteredUpcomingExams.value = upcomingExams;
      filteredMissedExams.value = missedExams;
    } else {
      filteredExams.value = allExams.where((exam) {
        return exam.subjectName
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();

      filteredUpcomingExams.value = upcomingExams.where((exam) {
        return exam.subjectName
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();

      filteredMissedExams.value = missedExams.where((exam) {
        return exam.subjectName
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  void refreshPage() {
    if (!_isAuthenticated() || _isDisposed) return;
    _resetPagination();
    _clearData();
    _loadInitialData();
  }

  void _resetPagination() {
    activeCurrentPage = 0;
    activeHasNextPage = false;
    activeRequestInProgress = false;

    upcomingCurrentPage = 0;
    upcomingHasNextPage = false;
    upcomingRequestInProgress = false;

    missedCurrentPage = 0;
    missedHasNextPage = false;
    missedRequestInProgress = false;

    complianceLoadError = false;
  }

  void _clearData() {
    allExams.clear();
    filteredExams.clear();
    upcomingExams.clear();
    filteredUpcomingExams.clear();
    missedExams.clear();
    filteredMissedExams.clear();
    compliences.clear();
    userProfile.value = UserModel.toEmpty();
    searchController.clear();
    searchQuery.value = '';
    isChecked.value = false;
    isSearching.value = false;
    isExamCardLoading.value = false;
  }

  void loadMoreExams() async {
    if (!_isAuthenticated() || _isDisposed) return;

    switch (currentTab.value) {
      case ExamTab.active:
        _loadMoreActiveExams();
        break;
      case ExamTab.upcoming:
        _loadMoreUpcomingExams();
        break;
      case ExamTab.missed:
        _loadMoreMissedExams();
        break;
    }
  }

  void _loadMoreActiveExams() async {
    if (isLoadingMore.value || !activeHasNextPage || activeRequestInProgress)
      return;

    await _safeApiCall(() async {
      try {
        activeRequestInProgress = true;
        isLoadingMore.value = true;
        activeCurrentPage++;

        final resp = await examRepo.getAllExams(
            orgCode: AppLocalStorage.instance.user.orgCode,
            batchId: AppLocalStorage.instance.user.batch,
            pageNumber: activeCurrentPage,
            pageSize: activePageSize);

        switch (resp) {
          case AppSuccess():
            final data = resp.value;
            List<ExamModel> newExams = data['content'] ?? [];

            if (newExams.isNotEmpty) {
              allExams.addAll(newExams);
            }

            activeHasNextPage = data['hasNext'] ?? false;
            activeHasPreviousPage = data['hasPrevious'] ?? false;
            activeTotalElements = data['totalElements'] ?? 0;
            activeTotalPages = data['totalPages'] ?? 0;

            _initializeActiveTimers();
            break;
          case AppFailure():
            activeCurrentPage--;
            Fluttertoast.showToast(
                msg: 'Failed to load more exams: ${resp.errorMessage}');
            break;
        }
      } finally {
        isLoadingMore.value = false;
        activeRequestInProgress = false;
      }
    });
  }

  void _loadMoreUpcomingExams() async {
    if (isLoadingMore.value ||
        !upcomingHasNextPage ||
        upcomingRequestInProgress) return;

    await _safeApiCall(() async {
      try {
        upcomingRequestInProgress = true;
        isLoadingMore.value = true;
        upcomingCurrentPage++;

        final resp = await examRepo.getUpcomingExams(
            pageNumber: upcomingCurrentPage, pageSize: upcomingPageSize);

        switch (resp) {
          case AppSuccess():
            final data = resp.value;
            List<upcoming_exam_model.UpcomingExamModel> newExams =
                data['content'] ?? [];

            if (newExams.isNotEmpty) {
              upcomingExams.addAll(newExams);
            }

            upcomingHasNextPage = data['hasNext'] ?? false;
            upcomingHasPreviousPage = data['hasPrevious'] ?? false;
            upcomingTotalElements = data['totalElements'] ?? 0;
            upcomingTotalPages = data['totalPages'] ?? 0;

            _initializeUpcomingTimers();
            break;
          case AppFailure():
            upcomingCurrentPage--;
            Fluttertoast.showToast(
                msg:
                    'Failed to load more upcoming exams: ${resp.errorMessage}');
            break;
        }
      } finally {
        isLoadingMore.value = false;
        upcomingRequestInProgress = false;
      }
    });
  }

  void _loadMoreMissedExams() async {
    if (isLoadingMore.value || !missedHasNextPage || missedRequestInProgress)
      return;

    await _safeApiCall(() async {
      try {
        missedRequestInProgress = true;
        isLoadingMore.value = true;
        missedCurrentPage++;

        final resp = await examRepo.getMissedExams(
            pageNumber: missedCurrentPage, pageSize: missedPageSize);

        switch (resp) {
          case AppSuccess():
            final data = resp.value;
            List<MissedExamModel> newExams = data['content'] ?? [];

            if (newExams.isNotEmpty) {
              missedExams.addAll(newExams);
            }

            missedHasNextPage = data['hasNext'] ?? false;
            missedHasPreviousPage = data['hasPrevious'] ?? false;
            missedTotalElements = data['totalElements'] ?? 0;
            missedTotalPages = data['totalPages'] ?? 0;

            break;
          case AppFailure():
            missedCurrentPage--;
            Fluttertoast.showToast(
                msg: 'Failed to load more missed exams: ${resp.errorMessage}');
            break;
        }
      } finally {
        isLoadingMore.value = false;
        missedRequestInProgress = false;
      }
    });
  }

  getAndSubmitOfflinePendingExams() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await _safeApiCall(() async {
      final unSubmitedExams =
          AppLocalStorage.instance.getOfflineUnSubmittedExams();

      for (Map<String, dynamic> item in unSubmitedExams) {
        if (!_isAuthenticated() || _isDisposed) return;

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
    });
  }

  void getUserProfile() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await _safeApiCall(() async {
      try {
        isUserProfileLoading.value = true;
        final resp = await authRepo.getUserProfile();

        switch (resp) {
          case AppSuccess():
            userProfile.value = resp.value;

            if (resp.value.batch.isNotEmpty) {
              final currentUser = AppLocalStorage.instance.user;
              final updatedUser = UserModel(
                id: currentUser.userId,
                email: resp.value.email.isNotEmpty
                    ? resp.value.email
                    : currentUser.email,
                name: resp.value.name.isNotEmpty
                    ? resp.value.name
                    : currentUser.name,
                mobile: resp.value.mobile.isNotEmpty
                    ? resp.value.mobile
                    : currentUser.mobile,
                password: currentUser.password,
                userId: currentUser.userId,
                fcmToken: currentUser.fcmToken,
                isActive: currentUser.isActive,
                batch: resp.value.batch,
                orgCode: resp.value.orgCode.isNotEmpty
                    ? resp.value.orgCode
                    : currentUser.orgCode,
                isAdmin: currentUser.isAdmin,
              );
              AppLocalStorage.instance.saveUser(updatedUser);
            }
            break;
          case AppFailure():
            Fluttertoast.showToast(
                msg: 'Failed to fetch user profile: ${resp.errorMessage}');
            userProfile.value = UserModel.toEmpty();
            break;
        }
      } finally {
        isUserProfileLoading.value = false;
      }
    });
  }

  void getExams() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await _safeApiCall(() async {
      try {
        isLoading.value = true;
        activeRequestInProgress = true;

        final resp = await examRepo.getAllExams(
            orgCode: AppLocalStorage.instance.user.orgCode,
            batchId: AppLocalStorage.instance.user.batch,
            pageNumber: activeCurrentPage,
            pageSize: activePageSize);

        switch (resp) {
          case AppSuccess():
            final data = resp.value;
            List<ExamModel> exams = data['content'] ?? [];
            allExams.value = exams;
            filteredExams.value = exams;

            activeHasNextPage = data['hasNext'] ?? false;
            activeHasPreviousPage = data['hasPrevious'] ?? false;
            activeTotalElements = data['totalElements'] ?? 0;
            activeTotalPages = data['totalPages'] ?? 0;

            _initializeActiveTimers();
            break;
          case AppFailure():
            Fluttertoast.showToast(
                msg: 'Failed to fetch exam : ${resp.errorMessage}');
            allExams.value = [];
            break;
        }
      } finally {
        isLoading.value = false;
        activeRequestInProgress = false;
      }
    });
  }

  void getUpcomingExams() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await _safeApiCall(() async {
      try {
        isLoading.value = true;
        upcomingRequestInProgress = true;

        final resp = await examRepo.getUpcomingExams(
            pageNumber: upcomingCurrentPage, pageSize: upcomingPageSize);

        switch (resp) {
          case AppSuccess():
            final data = resp.value;
            List<upcoming_exam_model.UpcomingExamModel> exams =
                data['content'] ?? [];
            upcomingExams.value = exams;
            filteredUpcomingExams.value = exams;

            upcomingHasNextPage = data['hasNext'] ?? false;
            upcomingHasPreviousPage = data['hasPrevious'] ?? false;
            upcomingTotalElements = data['totalElements'] ?? 0;
            upcomingTotalPages = data['totalPages'] ?? 0;

            _initializeUpcomingTimers();
            break;
          case AppFailure():
            Fluttertoast.showToast(
                msg: 'Failed to fetch upcoming exams: ${resp.errorMessage}');
            upcomingExams.value = [];
            break;
        }
      } finally {
        isLoading.value = false;
        upcomingRequestInProgress = false;
      }
    });
  }

  void getMissedExams() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await _safeApiCall(() async {
      try {
        isLoading.value = true;
        missedRequestInProgress = true;

        final resp = await examRepo.getMissedExams(
            pageNumber: missedCurrentPage, pageSize: missedPageSize);

        switch (resp) {
          case AppSuccess():
            final data = resp.value;
            List<MissedExamModel> exams = data['content'] ?? [];
            missedExams.value = exams;
            filteredMissedExams.value = exams;

            missedHasNextPage = data['hasNext'] ?? false;
            missedHasPreviousPage = data['hasPrevious'] ?? false;
            missedTotalElements = data['totalElements'] ?? 0;
            missedTotalPages = data['totalPages'] ?? 0;

            break;
          case AppFailure():
            Fluttertoast.showToast(
                msg: 'Failed to fetch missed exams: ${resp.errorMessage}');
            missedExams.value = [];
            break;
        }
      } finally {
        isLoading.value = false;
        missedRequestInProgress = false;
      }
    });
  }

  Future<bool> submitFeedback(String feedback) async {
    if (!_isAuthenticated() || _isDisposed) return false;

    try {
      final result = await examRepo.submitFeedback(feedback);
      
      switch (result) {
        case AppSuccess():
          Get.snackbar(
            'Success',
            'Thank you for your feedback!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return true;
        case AppFailure():
          Get.snackbar(
            'Error',
            result.errorMessage ?? 'Failed to submit feedback',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while submitting feedback',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
  }

  void _initializeActiveTimers() {
    if (_isDisposed) return;
    for (var exam in allExams) {
      _startCountdown(exam.questionId ?? 'uniqExam', exam.startTime);
    }
  }

  void _initializeUpcomingTimers() {
    if (_isDisposed) return;
    for (var exam in upcomingExams) {
      _startUpcomingCountdown(exam.questionId ?? 'uniqExam', exam.startTime);
    }
  }

  void _startCountdown(String examId, DateTime startTime) {
    if (_isDisposed) return;

    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !_isAuthenticated()) {
        timer.cancel();
        return;
      }

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

    _activeTimers.add(timer);
  }

  void _startUpcomingCountdown(String examId, DateTime startTime) {
    if (_isDisposed) return;

    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !_isAuthenticated()) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final remaining = startTime.difference(now);

      if (remaining.isNegative) {
        upcomingExamTimers[examId] = "Exam Started!";
        timer.cancel();
      } else {
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;
        upcomingExamTimers[examId] = "$hours h : $minutes m : $seconds s";
      }

      upcomingExamTimers.refresh();
    });

    _activeTimers.add(timer);
  }

  void logOut() async {
    try {
      final AuthRepo repo = AuthRepo();
      repo.logOut(userId: AppLocalStorage.instance.userId);
      AppLocalStorage.instance.clearStorage();

      _cancelAllTimers();

      Get.delete<HomeController>(force: true);
      Get.delete<AppAuthController>(force: true);
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  void _cancelAllTimers() {
    for (var timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
  }

  getConfiguration() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await _safeApiCall(() async {
      try {
        isExamCardLoading.value = true;
        isConfigurationLoading.value = true;
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
      }
    });
  }

  getCompliances() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await _safeApiCall(() async {
      try {
        complianceLoadError = false;
        isCompliencesLoading.value = true;
        final resp = await examRepo.getCompliance();

        switch (resp) {
          case AppSuccess():
            compliences.value =
                resp.value.map((e) => e as Map<String, dynamic>).toList();
            break;
          case AppFailure():
            complianceLoadError = true;
            compliences.value = [];
        }
      } finally {
        isExamCardLoading.value = false;
        isCompliencesLoading.value = false;
      }
    });
  }

  void showExamNotLiveDialog({bool isExamEnded = false}) {
    if (_isDisposed) return;
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

  void showUpcomingExamDialog() {
    if (_isDisposed) return;
    AppDialog().show(
      title: 'Upcoming Exam',
      content: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
            'This exam has not started yet. Please check back when the exam is scheduled to begin.'),
      ),
      buttonText: 'Ok',
      onPressed: () => Get.back(),
      restrictBack: false,
      isDismissible: true,
    );
  }

  void showConfigBasedAcknowledgementDialog() async {
    if (!_isAuthenticated() || _isDisposed) return;

    await getCompliances();

    if (complianceLoadError) {
      AppDialog().show(
        title: 'Unable to Load Exam Requirements',
        content: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              'Failed to load exam compliance details. Please check your internet connection and try again, or contact support if the problem persists.'),
        ),
        buttonText: 'Ok',
        onPressed: () => Get.back(),
        restrictBack: false,
        isDismissible: true,
      );
      return;
    }

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (configuration.isInternetDisabled == true)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade300),
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
                    ),
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
    if (!_isAuthenticated() || _isDisposed) return;

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
      "questions": selectedExam.questionList,
      "testId": selectedExam.questionId,
      'name': selectedExam.subjectName,
      'time': selectedExam.examDuration,
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
    _isDisposed = true;
    _cancelAllTimers();
    searchController.dispose();
    super.onClose();
  }
}