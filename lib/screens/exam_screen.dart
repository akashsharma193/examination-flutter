import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/controllers/exam_controller.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/widgets/app_dialog.dart';
import 'package:crackitx/widgets/test_completed_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';

class ExamScreen extends StatelessWidget {
  final List<QuestionModel> questions;
  final String examDurationMinutes;
  final String testId;
  final String examName;

  const ExamScreen({
    super.key,
    required this.testId,
    required this.examName,
    required this.questions,
    this.examDurationMinutes = '30',
  });

  @override
  Widget build(BuildContext context) {
    final ExamController controller = Get.put(ExamController(
      questions: questions,
      examDurationMinutes: examDurationMinutes,
      testId: testId,
    ));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (controller.remainingSeconds.value > 0) {
          AppDialog().show(
            title: "Are You Sure ?",
            content: const Text(
              'Do you want to Go Back?\nThe Paper will be automatically submitted.',
              textAlign: TextAlign.center,
            ),
            buttonText: "OK",
            onPressed: () {
              Get.back();
              Get.offAll(() => TestCompletedScreen(
                    list: controller.questionList
                        .map((e) => QuestionModel.fromJson(
                            Map<String, dynamic>.from(e)))
                        .toList(),
                    testID: testId,
                  ));
            },
          );
        }
      },
      child: Scaffold(
        appBar: GradientAppBar(
          title: Text(examName, style: const TextStyle(color: Colors.white)),
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Obx(() => Text(
                      "⏳ ${controller.formatTime(controller.remainingSeconds.value)}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600, // Semi-bold
                              ) ??
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                    )),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isAppInSplitScreen.value) {
            return const Center(
              child: Text(
                "This app is not accessible in split-screen or floating window mode.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final currentQuestion =
              controller.questionList[controller.currentQuestionIndex.value];

          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildQuestionIndicator(controller, context),
                const SizedBox(height: 12),
                _buildQuestionHeader(controller, currentQuestion, context),
                const SizedBox(height: 12),
                Expanded(
                    child: _buildOptions(controller, currentQuestion, context)),
                const SizedBox(height: 12),
                _buildNavigationButtons(controller, context),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Widget _buildQuestionIndicator(
  //     ExamController controller, BuildContext context) {
  //   return Container(
  //     constraints: BoxConstraints(maxHeight: Get.height * 0.2),
  //     // height: Get.height * 0.2,
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       controller: controller.scrollController,
  //       child: Wrap(
  //         spacing: 8,
  //         runSpacing: 4,
  //         children: List.generate(controller.questionList.length, (index) {
  //           final isSelected = index == controller.currentQuestionIndex.value;
  //           final isMarked =
  //               controller.questionList[index]['isMarked'] ?? false;
  //           final answered =
  //               (controller.questionList[index]['userAnswer'] as String?)
  //                       ?.isNotEmpty ??
  //                   false;
  //           return InkWell(
  //             onTap: () => controller.currentQuestionIndex.value = index,
  //             borderRadius: BorderRadius.circular(12),
  //             child: Container(
  //               width: 48,
  //               height: 48,
  //               decoration: BoxDecoration(
  //                 color: isMarked
  //                     ? Colors.purple
  //                     : answered
  //                         ? Colors.green
  //                         : isSelected
  //                             ? Theme.of(context).primaryColor
  //                             : Colors.grey.shade100,
  //                 borderRadius: BorderRadius.circular(24),
  //                 border: Border.all(
  //                     color: answered
  //                         ? Colors.grey.shade300
  //                         : AppColors.cardBackground),
  //               ),
  //               alignment: Alignment.center,
  //               child: Text(
  //                 "${index + 1}",
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                           fontWeight: FontWeight.w600,
  //                           color: isSelected || isMarked || answered
  //                               ? Colors.white
  //                               : Colors.black87,
  //                         ) ??
  //                     TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                       color: isSelected || isMarked || answered
  //                           ? Colors.white
  //                           : Colors.black87,
  //                     ),
  //               ),
  //             ),
  //           );
  //         }),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildQuestionIndicator(
      ExamController controller, BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.2),
      // height: Get.height * 0.2,
      child: SingleChildScrollView(
        controller: controller.scrollController,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: List.generate(controller.questionList.length, (index) {
            final isSelected = index == controller.currentQuestionIndex.value;
            final isMarked =
                controller.questionList[index]['isMarked'] ?? false;
            final answered =
                (controller.questionList[index]['userAnswer'] as String?)
                        ?.isNotEmpty ??
                    false;
            return InkWell(
              onTap: () => controller.currentQuestionIndex.value = index,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isMarked
                      ? Colors.purple
                      : answered
                          ? Colors.green
                          : isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: answered
                          ? Colors.grey.shade300
                          : AppColors.cardBackground),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected || isMarked || answered
                                ? Colors.white
                                : Colors.black87,
                          ) ??
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected || isMarked || answered
                            ? Colors.white
                            : Colors.black87,
                      ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(ExamController controller,
      Map<String, dynamic> currentQuestion, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Q ${controller.currentQuestionIndex.value + 1}: ${currentQuestion["question"]}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ) ??
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                controller.questionList[controller.currentQuestionIndex.value]
                    ["isMarked"] = !(controller
                            .questionList[controller.currentQuestionIndex.value]
                        ["isMarked"] ??
                    false);
                controller.questionList.refresh();
              },
              icon: Icon((controller.questionList[
                          controller.currentQuestionIndex.value]["isMarked"] ??
                      false)
                  ? Icons.bookmark_outline_rounded
                  : Icons.bookmark_add_outlined),
            ),
            TextButton(
              onPressed: controller.clearAnswer,
              child: const Text('CLEAR'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptions(ExamController controller,
      Map<String, dynamic> currentQuestion, BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: currentQuestion['options'].length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final option = currentQuestion['options'][index];
        return Card(
          elevation: 2, // Subtle shadow
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: currentQuestion["userAnswer"],
            onChanged: (value) => controller.selectAnswer(value!),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(
      ExamController controller, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: controller.currentQuestionIndex.value == 0
              ? MainAxisAlignment.end
              : MainAxisAlignment.spaceBetween,
          children: [
            if (controller.currentQuestionIndex.value != 0)
              ElevatedButton.icon(
                onPressed: controller.previousQuestion,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            if (controller.currentQuestionIndex.value !=
                controller.questionList.length - 1)
              ElevatedButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: controller.nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text('Next',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                icon: const Icon(Icons.arrow_forward),
              ),
          ],
        ),
        const SizedBox(
          height: 24,
        ),
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              controller.showExamSubumitConfirmationDialog();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF9181F4),
                    Color(0xFF5038ED)
                  ], // Your gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
