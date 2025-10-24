import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/controllers/exam_controller.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/widgets/app_dialog.dart';
import 'package:crackitx/widgets/test_completed_screen.dart';
import 'package:crackitx/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';
import 'dart:convert';
import 'dart:typed_data';

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
            showCancel: true,
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
                                fontWeight: FontWeight.w600,
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
        body: Column(
          children: [
            const BannerAdWidget(),
            Expanded(
              child: Obx(() {
                if (controller.isAppInSplitScreen.value) {
                  return const Center(
                    child: Text(
                      "This app is not accessible in split-screen or floating window mode.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final currentQuestion = controller.currentCategoryQuestions[
                    controller.currentQuestionIndex.value];

                return Column(
                  children: [
                    _buildCategoryTabs(controller, context),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0),
                      child: _buildQuestionIndicator(controller, context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuestionHeader(
                                controller, currentQuestion, context),
                            const SizedBox(height: 12),
                            _buildOptions(controller, currentQuestion, context),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(16.0),
                      child: _buildNavigationButtons(controller, context),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(ExamController controller, BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() {
        if (controller.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = controller.selectedCategory.value == category;
            final categoryQuestions =
                controller.questionsByCategory[category] ?? [];
            final answeredCount = categoryQuestions.where((q) {
              final originalIndex = q['originalIndex'] as int;
              final userAnswer = controller.questionList[originalIndex]
                  ['userAnswer'] as String?;
              return userAnswer?.isNotEmpty ?? false;
            }).length;

            return GestureDetector(
              onTap: () => controller.selectCategory(category),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF9181F4), Color(0xFF5038ED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color:
                        isSelected ? Colors.transparent : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$answeredCount/${categoryQuestions.length}',
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildQuestionIndicator(
      ExamController controller, BuildContext context) {
    const int questionsPerRow = 7;

    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.12),
      child: Obx(() {
        final categoryQuestions = controller.currentCategoryQuestions;

        return SingleChildScrollView(
          controller: controller.scrollController,
          scrollDirection: Axis.vertical,
          child: Column(
            children: List.generate(
              (categoryQuestions.length / questionsPerRow).ceil(),
              (rowIndex) {
                int startIndex = rowIndex * questionsPerRow;
                int endIndex = (startIndex + questionsPerRow)
                    .clamp(0, categoryQuestions.length);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      endIndex - startIndex,
                      (colIndex) {
                        int index = startIndex + colIndex;
                        final questionData = categoryQuestions[index];
                        final originalIndex =
                            questionData['originalIndex'] as int;

                        final isSelected =
                            index == controller.currentQuestionIndex.value;
                        final isMarked = controller.questionList[originalIndex]
                                ['isMarked'] ??
                            false;
                        final answered = (controller.questionList[originalIndex]
                                    ['userAnswer'] as String?)
                                ?.isNotEmpty ??
                            false;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: InkWell(
                            onTap: () {
                              controller.currentQuestionIndex.value = index;
                              controller.scrollToCurrentIndex();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isMarked
                                    ? Colors.purple
                                    : answered
                                        ? Colors.green
                                        : isSelected
                                            ? AppColors.cardBackground
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
                                style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected || isMarked || answered
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ) ??
                                    TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected || isMarked || answered
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuestionHeader(ExamController controller,
      Map<String, dynamic> currentQuestion, BuildContext context) {
    final originalIndex = currentQuestion['originalIndex'] as int;
    final originalQuestionData = controller.questionList[originalIndex];
    final questionText = originalQuestionData["question"] as String?;
    final questionImage = originalQuestionData["questionImage"] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (questionText != null && questionText.isNotEmpty)
          Text(
            "Q ${controller.currentQuestionIndex.value + 1}: $questionText",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ) ??
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        if (questionImage != null && questionImage.isNotEmpty) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildBase64Image(questionImage, 200),
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                controller.questionList[originalIndex]["isMarked"] =
                    !(controller.questionList[originalIndex]["isMarked"] ??
                        false);
                controller.questionList.refresh();
              },
              icon: Icon(
                  (controller.questionList[originalIndex]["isMarked"] ?? false)
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

  Widget _buildBase64Image(String base64String, double height) {
    try {
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      final Uint8List bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        height: height,
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(height: 8),
              Text('Error loading image',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildOptions(ExamController controller,
      Map<String, dynamic> currentQuestion, BuildContext context) {
    final originalIndex = currentQuestion['originalIndex'] as int;
    final originalQuestionData = controller.questionList[originalIndex];
    final options = originalQuestionData['options'] as List?;
    final optionsImage = originalQuestionData['optionsImage'] as List?;

    if ((options == null || options.isEmpty) &&
        (optionsImage == null || optionsImage.isEmpty)) {
      return const SizedBox.shrink();
    }

    final hasTextOptions = options != null && options.isNotEmpty;
    final hasImageOptions = optionsImage != null && optionsImage.isNotEmpty;

    final itemCount = hasTextOptions
        ? options.length
        : (hasImageOptions ? optionsImage.length : 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final option = (hasTextOptions && index < options.length)
            ? options[index] as String?
            : null;
        final optionImage = (hasImageOptions && index < optionsImage.length)
            ? optionsImage[index] as String?
            : null;

        final hasValidImage = optionImage != null &&
            optionImage.trim().isNotEmpty &&
            optionImage.length > 50;

        final optionValue =
            (hasTextOptions && option != null && option.isNotEmpty)
                ? option
                : (index + 1).toString();

        final userAnswer = controller.questionList[originalIndex]["userAnswer"];
        final isSelected = userAnswer == optionValue;

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => controller.selectAnswer(optionValue),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.cardBackground
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: optionValue,
                    groupValue: userAnswer,
                    onChanged: (value) => controller.selectAnswer(value!),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (option != null && option.isNotEmpty)
                          Text(
                            option,
                            style: const TextStyle(fontSize: 14),
                          ),
                        if (hasValidImage) ...[
                          if (option != null && option.isNotEmpty)
                            const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildBase64Image(optionImage!, 100),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(
      ExamController controller, BuildContext context) {
    return Obx(() {
      final isFirstQuestion = controller.currentQuestionIndex.value == 0;
      final isLastQuestionInCategory = controller.currentQuestionIndex.value ==
          controller.currentCategoryQuestions.length - 1;
      final currentCategoryIndex =
          controller.categories.indexOf(controller.selectedCategory.value);
      final isLastCategory =
          currentCategoryIndex == controller.categories.length - 1;
      final isFirstCategory = currentCategoryIndex == 0;

      return Column(
        children: [
          Row(
            mainAxisAlignment: isFirstQuestion && isFirstCategory
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
            children: [
              if (!(isFirstQuestion && isFirstCategory))
                ElevatedButton.icon(
                  onPressed: controller.previousQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              if (!isLastQuestionInCategory || !isLastCategory)
                ElevatedButton.icon(
                  iconAlignment: IconAlignment.end,
                  onPressed: controller.nextQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  label: const Text('Next',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  icon: const Icon(Icons.arrow_forward),
                ),
            ],
          ),
          const SizedBox(height: 24),
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
                    colors: [Color(0xFF9181F4), Color(0xFF5038ED)],
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
        ],
      );
    });
  }
}
