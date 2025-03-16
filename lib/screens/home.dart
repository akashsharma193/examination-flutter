// import 'package:flutter/material.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:offline_test_app/app_models/exam_model.dart';
// import 'package:offline_test_app/controllers/home_controller.dart';
// import 'package:offline_test_app/core/extensions/datetime_extension.dart';
// import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
// import 'package:offline_test_app/widgets/drawer_widget.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   bool isExamLive(GetExamModel model) {
//     if (model.startTime == null || model.endTime == null) {
//       return false;
//     } else {
//       return DateTime.now().isAfter(model.startTime!) &&
//           DateTime.now().isBefore(model.endTime!);
//     }
//   }

//   bool isExamEnded(GetExamModel model) {
//     if (model.endTime == null) {
//       return false;
//     } else {
//       return DateTime.now().isAfter(model.endTime!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HomeController>(builder: (controller) {
//       return Scaffold(
//         drawer: AppDrawer(),
//         floatingActionButton: FloatingActionButton.small(
//             child: const Icon(Icons.refresh),
//             onPressed: () {
//               controller.refreshPage();
//             }),
//         appBar: AppBar(
//           title: const Text('Home'),
//           actions: [
//             IconButton(
//                 onPressed: () {
//                   controller.initialized ? controller.logOut() : null;
//                 },
//                 icon: const Icon(Icons.logout_outlined))
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 'Hello, ${AppLocalStorage.instance.user.name}',
//                 style: const TextStyle(fontSize: 24),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               if (controller.isLoading.value)
//                 const Text('Fetching exam details...'),
//               Expanded(
//                 child: controller.allExams.isEmpty
//                     ? const Center(
//                         child: Text('No Exams Scheduled for you as of now..'),
//                       )
//                     : ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: controller.allExams.length,
//                         itemBuilder: (context, index) {
//                           final singleItem = controller.allExams[index];
//                           return Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: InkWell(
//                               onTap: () {
//                                 if (isExamLive(singleItem)) {
//                                   controller.selectedExam =
//                                       controller.allExams[index];
//                                   controller.showAcknowledgementDialogPopUp();
//                                 } else {
//                                   controller.showExamNotLiveDialog(
//                                       isExamEnded: isExamEnded(singleItem));
//                                 }
//                               },
//                               child: Material(
//                                 elevation: 2,
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: ListTile(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   tileColor: Colors.black26,
//                                   title: Text(singleItem.subjectName ?? '-'),
//                                   subtitle: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                           'by ${singleItem.teacherName ?? '-'} '),
//                                       Text(
//                                         'Start Time : ${singleItem.startTime?.formatTime}',
//                                       ),
//                                       Text(
//                                         'End Time : ${singleItem.endTime?.formatTime}',
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Column(
//                                     children: [
//                                       Text(
//                                         'Total Duuration : ${singleItem.examDuration} mins',
//                                         textAlign: TextAlign.end,
//                                       ),
//                                       SizedBox(
//                                         width: 140,
//                                         child: Obx(
//                                           () => Text(
//                                             controller.examTimers[
//                                                     singleItem.questionId] ??
//                                                 'Calculating...',
//                                             textAlign: TextAlign.end,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               )
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/controllers/home_controller.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';
import 'package:offline_test_app/core/extensions/datetime_extension.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/widgets/drawer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  bool isExamLive(GetExamModel model) {
    if (model.startTime == null || model.endTime == null) {
      return false;
    }
    return DateTime.now().isAfter(model.startTime!) &&
        DateTime.now().isBefore(model.endTime!);
  }

  bool isExamEnded(GetExamModel model) {
    if (model.endTime == null) {
      return false;
    }
    return DateTime.now().isAfter(model.endTime!);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Scaffold(
        drawer: const AppDrawer(),
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: AppColors.button,
          onPressed: controller.refreshPage,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('Home',
              style: AppTextStyles.heading.copyWith(color: Colors.white)),
          backgroundColor: AppColors.appBar,
          actions: [
            IconButton(
              onPressed: controller.initialized ? controller.logOut : null,
              icon: const Icon(Icons.logout_outlined, color: Colors.white),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Hello, ${AppLocalStorage.instance.user.name}',
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 20),
              if (controller.isLoading.value)
                const Text('Fetching exam details...',
                    style: AppTextStyles.body),
              Expanded(
                child: controller.allExams.isEmpty
                    ? const Center(
                        child: Text(
                          'No Exams Scheduled for you as of now..',
                          style: AppTextStyles.subheading,
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.allExams.length,
                        itemBuilder: (context, index) {
                          final singleItem = controller.allExams[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                if (isExamLive(singleItem)) {
                                  controller.selectedExam =
                                      controller.allExams[index];
                                  controller.showAcknowledgementDialogPopUp();
                                } else {
                                  controller.showExamNotLiveDialog(
                                      isExamEnded: isExamEnded(singleItem));
                                }
                              },
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.cardBackground,
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Text(singleItem.subjectName ?? '-',
                                      style: AppTextStyles.subheading),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'by ${singleItem.teacherName ?? '-'} ',
                                          style: AppTextStyles.body),
                                      Text(
                                        'Start Time : ${singleItem.startTime?.formatTime}',
                                        style: AppTextStyles.body
                                            .copyWith(fontSize: 12),
                                      ),
                                      Text(
                                        'End Time : ${singleItem.endTime?.formatTime}',
                                        style: AppTextStyles.body
                                            .copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Duration : ${singleItem.examDuration} mins',
                                        textAlign: TextAlign.end,
                                        style: AppTextStyles.body
                                            .copyWith(fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Obx(
                                        () => Text(
                                          controller.examTimers[
                                                  singleItem.questionId] ??
                                              'Calculating...',
                                          textAlign: TextAlign.end,
                                          style: AppTextStyles.body
                                              .copyWith(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      );
    });
  }
}
