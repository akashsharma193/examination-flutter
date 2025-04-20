import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/exam_model.dart';
import 'package:offline_test_app/controllers/exam_controller.dart';
import 'package:offline_test_app/widgets/test_completed_screen.dart';

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
        Get.dialog(
          AlertDialog(
            title: const Text("Are You Sure , you want to Back?"),
            content: const Text('The Paper will be automatically submitted.'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.offAll(() => TestCompletedScreen(
                        list: controller.questionList
                            .map((e) => QuestionModel.fromJson(
                                Map<String, dynamic>.from(e)))
                            .toList(),
                        testID: testId,
                      ));
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(examName),
          elevation: 1, // Subtle shadow
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          leading: null,
          automaticallyImplyLeading: false,
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
            padding: const EdgeInsets.all(16.0),
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

  Widget _buildQuestionIndicator(
      ExamController controller, BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.2),
      // height: Get.height * 0.2,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
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
    return Row(
      children: [
        Expanded(
          child: Text(
            "Q ${controller.currentQuestionIndex.value + 1}: ${currentQuestion["question"]}",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ) ??
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            controller.questionList[controller.currentQuestionIndex.value]
                    ["isMarked"] =
                !(controller.questionList[controller.currentQuestionIndex.value]
                        ["isMarked"] ??
                    false);
            controller.questionList.refresh();
          },
          icon: Icon(
              (controller.questionList[controller.currentQuestionIndex.value]
                          ["isMarked"] ??
                      false)
                  ? Icons.bookmark
                  : Icons.bookmark_add_outlined),
        ),
        TextButton(
          onPressed: controller.clearAnswer,
          child: const Text('CLEAR'),
        ),
      ],
    );
  }

  Widget _buildOptions(ExamController controller,
      Map<String, dynamic> currentQuestion, BuildContext context) {
    return ListView.separated(
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
              ElevatedButton(
                onPressed: controller.previousQuestion,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Previous"),
              ),
            if (controller.currentQuestionIndex.value !=
                controller.questionList.length - 1)
              ElevatedButton(
                onPressed: controller.nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Next"),
              ),
          ],
        ),
        SizedBox(
          width: Get.width,
          child: FilledButton(
              onPressed: () {
                controller.showExamSubumitConfirmationDialog();
                   Get.offAll(() => TestCompletedScreen(
                        list: controller.questionList
                            .map((e) => QuestionModel.fromJson(
                                Map<String, dynamic>.from(e)))
                            .toList(),
                        testID: testId,
                      ));
              },
              child: const Text('Submit')),
        ),
      ],
    );
  }
}
