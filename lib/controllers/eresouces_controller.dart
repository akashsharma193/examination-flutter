import 'dart:developer';
import 'package:crackitx/app_models/eresources_model.dart';
import 'package:get/get.dart';
import 'package:crackitx/core/constants/app_result.dart';
import 'package:crackitx/repositories/eresources_repo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

class EResourcesController extends GetxController {
  final EResourcesRepo eResourcesRepo = EResourcesRepo();

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<EResourceModel> resources = <EResourceModel>[].obs;

  int currentPage = 0;
  int pageSize = 10;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  int totalElements = 0;
  int totalPages = 0;
  bool requestInProgress = false;

  @override
  void onInit() {
    super.onInit();
    getResources();
  }

  Future<void> getResources() async {
    try {
      isLoading.value = true;
      requestInProgress = true;
      currentPage = 0;

      final resp = await eResourcesRepo.getResources(
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      switch (resp) {
        case AppSuccess():
          final data = resp.value;
          List<EResourceModel> fetchedResources = data['content'] ?? [];
          resources.value = fetchedResources;

          hasNextPage = data['hasNext'] ?? false;
          hasPreviousPage = data['hasPrevious'] ?? false;
          totalElements = data['totalElements'] ?? 0;
          totalPages = data['totalPages'] ?? 0;
          break;
        case AppFailure():
          Fluttertoast.showToast(
              msg: 'Failed to fetch resources: ${resp.errorMessage}');
          resources.value = [];
          break;
      }
    } finally {
      isLoading.value = false;
      requestInProgress = false;
    }
  }

  Future<void> loadMoreResources() async {
    if (isLoadingMore.value || !hasNextPage || requestInProgress) return;

    try {
      requestInProgress = true;
      isLoadingMore.value = true;
      currentPage++;

      final resp = await eResourcesRepo.getResources(
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      switch (resp) {
        case AppSuccess():
          final data = resp.value;
          List<EResourceModel> newResources = data['content'] ?? [];

          if (newResources.isNotEmpty) {
            resources.addAll(newResources);
          }

          hasNextPage = data['hasNext'] ?? false;
          hasPreviousPage = data['hasPrevious'] ?? false;
          totalElements = data['totalElements'] ?? 0;
          totalPages = data['totalPages'] ?? 0;
          break;
        case AppFailure():
          currentPage--;
          Fluttertoast.showToast(
              msg: 'Failed to load more resources: ${resp.errorMessage}');
          break;
      }
    } finally {
      isLoadingMore.value = false;
      requestInProgress = false;
    }
  }

  Future<void> downloadResource(String resourceId) async {
    try {
      Fluttertoast.showToast(msg: 'Downloading file...');
      final result = await eResourcesRepo.downloadResource(resourceId);

      switch (result) {
        case AppSuccess():
          final filePath = result.value;
          Fluttertoast.showToast(msg: 'File downloaded successfully');

          try {
            final openResult = await OpenFile.open(filePath);
            if (openResult.type != ResultType.done) {
              log('Could not open file: ${openResult.message}');
              Fluttertoast.showToast(msg: 'File saved to Downloads folder');
            }
          } catch (e) {
            log('Error opening file: $e');
            Fluttertoast.showToast(msg: 'File saved to Downloads folder');
          }
          break;
        case AppFailure():
          Fluttertoast.showToast(
              msg: 'Failed to download file: ${result.errorMessage}');
          break;
      }
    } catch (e) {
      log('Error downloading resource: $e');
      Fluttertoast.showToast(msg: 'An error occurred while downloading file');
    }
  }

  Future<void> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(msg: 'Could not open URL');
      }
    } catch (e) {
      log('Error opening URL: $e');
      Fluttertoast.showToast(msg: 'Failed to open URL');
    }
  }
}
