import 'package:crackitx/core/constants/color_constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
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
        appBar: GradientAppBar(
          title: Text(
            'Home',
            style: AppTheme.headingLarge.copyWith(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: controller.initialized ? controller.logOut : null,
              icon: const Icon(Icons.logout_outlined, color: Colors.white),
            ),
          ],
        ),
        body: Padding(
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
                final displayName =
                    !userProfile.isEmpty && userProfile.name.isNotEmpty
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

      return Column(
        children: [
          if (controller.totalElements > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Showing ${controller.allExams.length} of ${controller.totalElements} exams',
                style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: controller.scrollController,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.allExams.length +
                  (controller.hasNextPage || controller.isLoadingMore.value
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == controller.allExams.length) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Loading more exams...',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final singleItem = controller.allExams[index];
                return Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  child: InkWell(
                    onTap: () async {
                      if (isExamLive(singleItem)) {
                        controller.selectedExam = controller.allExams[index];
                        await controller.getConfiguration();
                        controller.showConfigBasedAcknowledgementDialog();
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        Text(
                                          'by ${singleItem.teacherName}',
                                          style: AppTheme.bodyLarge.copyWith(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Start: ${singleItem.startTime.formatTime}',
                                          style: AppTheme.normalText
                                              .copyWith(color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'End: ${singleItem.endTime.formatTime}',
                                          style: AppTheme.normalText
                                              .copyWith(color: Colors.white),
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
                                                .copyWith(color: Colors.white),
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
                                                controller.examTimers[singleItem
                                                        .questionId] ??
                                                    'Calculating...',
                                                style: AppTheme.normalText
                                                    .copyWith(
                                                        color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
