import 'package:crackitx/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
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
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: AppTheme.gradientStart,
          onPressed: controller.refreshPage,
          child: const Icon(Icons.refresh, color: Colors.white),
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
          padding: EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppTheme.spacingL),
              Text(
                'Hello, ${AppLocalStorage.instance.user.name}',
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(2, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingL),
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
    if (controller.isLoading.value) {
      return Text('Fetching exam details...',
          style: AppTheme.bodyLarge.copyWith(color: Colors.black));
    }
    return controller.allExams.isEmpty
        ? Center(
            child: Text(
              'No Exams Scheduled for you as of now..',
              style: AppTheme.headingMedium.copyWith(color: Colors.black),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.allExams.length,
            itemBuilder: (context, index) {
              final singleItem = controller.allExams[index];
              return Padding(
                padding: EdgeInsets.all(AppTheme.spacingS),
                child: InkWell(
                  onTap: () {
                    if (isExamLive(singleItem)) {
                      controller.selectedExam = controller.allExams[index];
                      controller.showAcknowledgementDialogPopUp();
                    } else {
                      controller.showExamNotLiveDialog(
                          isExamEnded: isExamEnded(singleItem));
                    }
                  },
                  child: Material(
                    elevation: 2,
                
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                    color: AppColors.cardBackground,
                    shadowColor: AppTheme.shadowSmall[0].color,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              singleItem.subjectName,
                              style: AppTheme.headingMedium
                                  .copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text(
                                        'by ${singleItem.teacherName}',
                                        style: AppTheme.bodyLarge
                                            .copyWith(color: Colors.white70),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Start: ${singleItem.startTime.formatTime}',
                                        style: AppTheme.bodyMedium
                                            .copyWith(color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'End: ${singleItem.endTime.formatTime}',
                                        style: AppTheme.bodyMedium
                                            .copyWith(color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Right section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Duration: ${singleItem.examDuration} mins',
                                      style: AppTheme.bodyMedium
                                          .copyWith(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(() => Text(
                                          controller.examTimers[
                                                  singleItem.questionId] ??
                                              'Calculating...',
                                          style: AppTheme.bodyMedium
                                              .copyWith(color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
