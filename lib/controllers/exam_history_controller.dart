import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/repositories/admin_repo.dart';
import 'package:crackitx/repositories/exam_repo.dart';
import 'package:crackitx/widgets/app_snackbar_widget.dart';

class ExamHistoryController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<SingleExamHistoryModel> allAttemptedExamsList =
      <SingleExamHistoryModel>[].obs;

  int currentPage = 0;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalElements = 0;
  int totalPages = 0;

  bool isFromGetAllExamTab = false;
  bool showOnlyActiveExams = false;
  String currentUserId = '';
  bool _isInitialized = false;
  bool isRequestInProgress = false;

  final ExamRepo examRepo = ExamRepo();
  final AdminRepo adminRepo = AdminRepo();

  RxString searchQuery = ''.obs;
  RxString selectedBatch = ''.obs;
  RxString selectedOrganization = ''.obs;

  List<String> get batches => allAttemptedExamsList
      .map((e) => (e.batch ?? '').trim())
      .toSet()
      .where((e) => e.isNotEmpty)
      .toList();

  List<SingleExamHistoryModel> get filteredExams {
    return allAttemptedExamsList.where((user) {
      final matchesSearch = (user.subjectName ?? '')
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          (user.teacherName ?? '')
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
      final matchesBatch =
          selectedBatch.value.isEmpty || user.batch == selectedBatch.value;
      final matchesOrg = selectedOrganization.value.isEmpty ||
          user.orgCode == selectedOrganization.value;
      return matchesSearch && matchesBatch && matchesOrg;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
  }

  void setup({required String? userId, bool showActiveExam = false}) {
    if (_isInitialized) return;

    isFromGetAllExamTab = userId == null;
    currentUserId = userId ?? AppLocalStorage.instance.user.userId;
    showOnlyActiveExams = showActiveExam;
    currentPage = 0;
    hasNextPage = false;
    isRequestInProgress = false;
    allAttemptedExamsList.clear();
    _isInitialized = true;
    _loadInitialData();
  }

  void refresh() {
    currentPage = 0;
    hasNextPage = false;
    isRequestInProgress = false;
    allAttemptedExamsList.clear();
    _loadInitialData();
  }

  void _filterActiveExam() {
    if (showOnlyActiveExams) {
      final filtered = allAttemptedExamsList
          .where((e) => e.endTime?.isAfter(DateTime.now()) ?? false)
          .toList();
      allAttemptedExamsList.value = filtered;
    }
  }

  void loadMoreExamHistory() async {
    if (isLoadingMore.value ||
        !hasNextPage ||
        isFromGetAllExamTab ||
        isLoading.value ||
        isRequestInProgress) return;

    try {
      isRequestInProgress = true;
      isLoadingMore.value = true;

      await Future.delayed(const Duration(milliseconds: 300));

      final nextPage = currentPage + 1;
      print("Loading more exam history - requesting page: $nextPage");

      final resp = await examRepo.getExamHistory(
        userId: currentUserId,
        pageNumber: nextPage,
        pageSize: pageSize,
      );

      switch (resp) {
        case AppSuccess():
          final data = resp.value;
          List<SingleExamHistoryModel> newHistory = data['content'] ?? [];

          print("Received ${newHistory.length} new history items");

          if (newHistory.isNotEmpty) {
            allAttemptedExamsList.addAll(newHistory);
            currentPage = nextPage;
          }

          hasNextPage = data['hasNext'] ?? false;
          hasPreviousPage = data['hasPrevious'] ?? false;
          totalElements = data['totalElements'] ?? 0;
          totalPages = data['totalPages'] ?? 0;

          print(
              "Updated exam history pagination: hasNextPage=$hasNextPage, totalElements=$totalElements");
          break;
        case AppFailure():
          print("Failed to load more exam history: ${resp.errorMessage}");
          AppSnackbarWidget.showSnackBar(
            isSuccess: false,
            subTitle: 'Failed to load more exam history',
          );
          break;
      }
    } catch (e) {
      print("Exception in loadMoreExamHistory: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      isLoadingMore.value = false;
      isRequestInProgress = false;
    }
  }

  void _loadInitialData() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      isRequestInProgress = true;

      if (isFromGetAllExamTab) {
        await _loadAdminData();
      } else {
        await _loadStudentData();
      }

      _filterActiveExam();
    } catch (e) {
      debugPrint("Error in _loadInitialData: $e");
      allAttemptedExamsList.value = [];
    } finally {
      isLoading.value = false;
      isRequestInProgress = false;
    }
  }

  Future<void> _loadAdminData() async {
    final resp =
        await adminRepo.getAllExamsList(AppLocalStorage.instance.user.orgCode);

    switch (resp) {
      case AppSuccess():
        allAttemptedExamsList.value = resp.value;
        totalElements = resp.value.length;
        hasNextPage = false;
        hasPreviousPage = false;
        totalPages = 1;
        break;
      case AppFailure():
        allAttemptedExamsList.value = [];
        break;
      case null:
        allAttemptedExamsList.value = [];
        break;
    }
  }

  Future<void> _loadStudentData() async {
    print(
        "Loading initial exam history data - currentPage: $currentPage, pageSize: $pageSize");

    final resp = await examRepo.getExamHistory(
      userId: currentUserId,
      pageNumber: currentPage,
      pageSize: pageSize,
    );

    switch (resp) {
      case AppSuccess():
        final data = resp.value;
        List<SingleExamHistoryModel> history = data['content'] ?? [];
        allAttemptedExamsList.value = history;

        hasNextPage = data['hasNext'] ?? false;
        hasPreviousPage = data['hasPrevious'] ?? false;
        totalElements = data['totalElements'] ?? 0;
        totalPages = data['totalPages'] ?? 0;

        print("Initial exam history load complete:");
        print("- Loaded ${history.length} history items");
        print("- hasNextPage: $hasNextPage");
        print("- totalElements: $totalElements");
        print("- totalPages: $totalPages");
        break;
      case AppFailure():
        print("Failed to load exam history: ${resp.errorMessage}");
        allAttemptedExamsList.value = [];
        break;
      case null:
        allAttemptedExamsList.value = [];
        break;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
