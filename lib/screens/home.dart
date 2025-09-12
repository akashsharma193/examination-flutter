import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/controllers/home_controller.dart';
import 'package:crackitx/core/theme/app_theme.dart';
import 'package:crackitx/core/extensions/datetime_extension.dart';
import 'package:crackitx/data/local_storage/app_local_storage.dart';
import 'package:crackitx/screens/admin_screen/admin_home.dart';
import 'package:crackitx/widgets/drawer_widget.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';

Widget homePage() {
  if (AppLocalStorage.instance.user.isAdmin) {
    return const AdminDashboard();
  } else {
    return const StudentHomePage();
  }
}

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  bool isExamLive(ExamModel model) {
    return DateTime.now().isAfter(model.startTime) &&
        DateTime.now().isBefore(model.endTime);
  }

  bool isExamEnded(ExamModel model) {
    return DateTime.now().isAfter(model.endTime);
  }

  void _showLoadingDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading Quiz Details...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = HomeController.init();

    return GetBuilder<HomeController>(
        init: controller,
        builder: (controller) {
          return Scaffold(
            drawer: const AppDrawer(),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  backgroundColor: AppTheme.gradientStart,
                  heroTag: "refresh",
                  onPressed: controller.refreshPage,
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Obx(() => GradientAppBar(
                    title: controller.isSearching.value
                        ? TextField(
                            controller: controller.searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Search by subject name...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            autofocus: true,
                          )
                        : Text(
                            'Home',
                            style: AppTheme.headingLarge
                                .copyWith(color: Colors.white),
                          ),
                    iconTheme: const IconThemeData(color: Colors.white),
                    actions: [
                      Obx(() => IconButton(
                            onPressed: controller.toggleSearch,
                            icon: Icon(
                              controller.isSearching.value
                                  ? Icons.close
                                  : Icons.search,
                              color: Colors.white,
                            ),
                          )),
                      IconButton(
                        onPressed: controller.logOut,
                        icon: const Icon(Icons.logout_outlined,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
            body: Column(
              children: [
                const BannerAdWidget(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppTheme.spacingL),
                        Obx(() {
                          if (controller.isUserProfileLoading.value) {
                            return Text(
                              'Loading...',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.black,
                              ),
                            );
                          }
                          final userProfile = controller.userProfile.value;
                          final displayName = !userProfile.isEmpty &&
                                  userProfile.name.isNotEmpty
                              ? userProfile.name
                              : AppLocalStorage.instance.user.name;

                          return Text(
                            'Hello, $displayName',
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.black,
                            ),
                          );
                        }),
                        const SizedBox(height: AppTheme.spacingL),
                        Expanded(child: getExamListWidget(controller))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget getExamListWidget(HomeController controller) {
    if (AppLocalStorage.instance.user.isAdmin) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (controller.isLoading.value && controller.allExams.isEmpty) {
        return Center(
          child: Text(
            'Fetching exam details...',
            style: AppTheme.bodyLarge.copyWith(color: Colors.black),
          ),
        );
      }

      if (controller.allExams.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Text(
            'No Exams Scheduled for you as of now..',
            style: AppTheme.headingMedium.copyWith(color: Colors.black),
          ),
        );
      }

      if (controller.isSearching.value &&
          controller.filteredExams.isEmpty &&
          controller.searchQuery.value.isNotEmpty) {
        return Center(
          child: Text(
            'No exams found matching "${controller.searchQuery.value}"',
            style: AppTheme.headingMedium.copyWith(color: Colors.black),
          ),
        );
      }

      final examsToShow = controller.isSearching.value
          ? controller.filteredExams
          : controller.allExams;
      final showLoadMore =
          !controller.isSearching.value && controller.hasNextPage;

      return Column(
        children: [
          if (controller.totalElements > 0 && !controller.isSearching.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Showing ${controller.allExams.length} of ${controller.totalElements} exams',
                style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
              ),
            ),
          if (controller.isSearching.value &&
              controller.filteredExams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Found ${controller.filteredExams.length} exam(s)',
                style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
              ),
            ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: examsToShow.length + (showLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == examsToShow.length && showLoadMore) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Obx(() => Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: controller.isLoadingMore.value
                                    ? null
                                    : controller.loadMoreExams,
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9181F4),
                                        Color(0xFF5038ED)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: controller.isLoadingMore.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Load More Exams',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                      const BannerAdWidget(),
                    ],
                  );
                }
                final singleItem = examsToShow[index];
                final originalIndex = controller.allExams.indexOf(singleItem);

                Widget examCard = Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  child: Obx(() => InkWell(
                        onTap: controller.isExamCardLoading.value
                            ? null
                            : () async {
                                if (isExamLive(singleItem)) {
                                  _showLoadingDialog();
                                  controller.selectedExam = controller.allExams[
                                      originalIndex != -1
                                          ? originalIndex
                                          : index];
                                  await controller.getConfiguration();
                                  Get.back();
                                  controller
                                      .showConfigBasedAcknowledgementDialog();
                                } else {
                                  controller.showExamNotLiveDialog(
                                      isExamEnded: isExamEnded(singleItem));
                                }
                              },
                        child: Material(
                          elevation: 2,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusM),
                          color: AppColors.cardBackground,
                          shadowColor: AppTheme.shadowSmall[0].color,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 300,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD3D3D3),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(40),
                                    ),
                                  ),
                                  child: Text(
                                    singleItem.subjectName,
                                    style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 6),
                                            Text(
                                              'by ${singleItem.teacherName}',
                                              style: AppTheme.bodyLarge
                                                  .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Start: ${singleItem.startTime.formatTime}',
                                              style: AppTheme.normalText
                                                  .copyWith(
                                                      color: Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'End: ${singleItem.endTime.formatTime}',
                                              style: AppTheme.normalText
                                                  .copyWith(
                                                      color: Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.schedule,
                                                  color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${singleItem.examDuration} mins',
                                                style: AppTheme.normalText
                                                    .copyWith(
                                                        color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.timer_outlined,
                                                  color: Colors.white),
                                              const SizedBox(width: 4),
                                              Obx(() => Text(
                                                    controller.examTimers[
                                                            singleItem
                                                                .questionId] ??
                                                        'Calculating...',
                                                    style: AppTheme.normalText
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      )),
                );

                if ((index + 1) % 3 == 0 && index != examsToShow.length - 1) {
                  return Column(
                    children: [
                      examCard,
                      const BannerAdWidget(),
                    ],
                  );
                }

                return examCard;
              },
            ),
          ),
        ],
      );
    });
  }
}
