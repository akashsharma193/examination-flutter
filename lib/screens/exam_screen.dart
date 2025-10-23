import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/controllers/exam_controller.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/widgets/app_dialog.dart';
import 'package:crackitx/widgets/test_completed_screen.dart';
import 'package:crackitx/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
            Obx(() {
              if (controller.categories.length > 1) {
                return _buildCategoryTabs(controller);
              }
              return const SizedBox.shrink();
            }),
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

                final currentQuestion = controller
                    .currentCategoryQuestions[controller.currentQuestionIndex.value];

                return Column(
                  children: [
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
                            _buildQuestionContent(currentQuestion),
                            const SizedBox(height: 16),
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

  Widget _buildCategoryTabs(ExamController controller) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategory.value == category;
          final questionCount = controller.questionsByCategory[category]?.length ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => controller.selectCategory(category),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardBackground : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$questionCount',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionIndicator(ExamController controller, BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.12),
      child: SingleChildScrollView(
        controller: controller.scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          children: controller.categories.map((category) {
            final categoryQuestions = controller.questionsByCategory[category] ?? [];
            if (categoryQuestions.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.categories.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, top: 8),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: categoryQuestions.map((question) {
                    final originalIndex = question['originalIndex'] as int;
                    final isSelected = controller.selectedCategory.value == category &&
                        controller.currentQuestionIndex.value == categoryQuestions.indexOf(question);
                    final isMarked = controller.questionList[originalIndex]['isMarked'] ?? false;
                    final answered = (controller.questionList[originalIndex]['userAnswer'] as String?)?.isNotEmpty ?? false;

                    return InkWell(
                      onTap: () {
                        controller.selectCategory(category);
                        controller.currentQuestionIndex.value = categoryQuestions.indexOf(question);
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
                              color: answered ? Colors.grey.shade300 : AppColors.cardBackground),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${originalIndex + 1}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected || isMarked || answered ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(ExamController controller, Map<String, dynamic> currentQuestion, BuildContext context) {
    final originalIndex = currentQuestion['originalIndex'] as int;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Q ${originalIndex + 1}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ) ??
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            if (controller.categories.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBackground),
                ),
                child: Text(
                  controller.selectedCategory.value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cardBackground,
                  ),
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                controller.questionList[originalIndex]["isMarked"] = !(controller.questionList[originalIndex]["isMarked"] ?? false);
                controller.questionList.refresh();
              },
              icon: Icon((controller.questionList[originalIndex]["isMarked"] ?? false)
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

  Widget _buildQuestionContent(Map<String, dynamic> currentQuestion) {
    final String? questionText = currentQuestion['question'] as String?;
    final String? questionImage = currentQuestion['questionImage'] as String?;
    
    final hasText = questionText != null && questionText.trim().isNotEmpty;
    final hasImage = questionImage != null && questionImage.trim().isNotEmpty;

    if (hasText && hasImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: questionImage,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ],
      );
    } else if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: questionImage,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    } else if (hasText) {
      return Text(
        questionText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildOptions(ExamController controller, Map<String, dynamic> currentQuestion, BuildContext context) {
    final List<dynamic> options = currentQuestion['options'] ?? [];
    final List<dynamic>? optionsImage = currentQuestion['optionsImage'] as List<dynamic>?;
    final originalIndex = currentQuestion['originalIndex'] as int;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final String option = options[index] as String;
        final String? optionImage = optionsImage != null && index < optionsImage.length ? optionsImage[index] as String? : null;
        
        final hasText = option.trim().isNotEmpty;
        final hasImage = optionImage != null && optionImage.trim().isNotEmpty;

        final String optionIdentifier = _getOptionIdentifier(options, optionsImage, index);
        final bool isSelected = controller.questionList[originalIndex]["userAnswer"] == optionIdentifier;

        return Card(
          elevation: isSelected ? 4 : 2,
          color: isSelected ? AppColors.cardBackground.withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.cardBackground : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => controller.selectAnswer(optionIdentifier),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.cardBackground : Colors.grey,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.cardBackground : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOptionContent(option, optionImage, index, hasText, hasImage),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionContent(String option, String? optionImage, int index, bool hasText, bool hasImage) {
    if (hasText && hasImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: optionImage!,
              fit: BoxFit.contain,
              height: 120,
              placeholder: (context, url) => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const SizedBox(
                height: 120,
                child: Center(child: Icon(Icons.error)),
              ),
            ),
          ),
        ],
      );
    } else if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: optionImage!,
          fit: BoxFit.contain,
          height: 120,
          placeholder: (context, url) => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const SizedBox(
            height: 120,
            child: Center(child: Icon(Icons.error)),
          ),
        ),
      );
    } else {
      return Text(
        option,
        style: const TextStyle(fontSize: 14),
      );
    }
  }

  String _getOptionIdentifier(List<dynamic> options, List<dynamic>? optionsImage, int index) {
    if (optionsImage != null && optionsImage.isNotEmpty) {
      final hasTextOptions = options.any((opt) => (opt as String).trim().isNotEmpty);
      final hasImageOptions = optionsImage.any((img) => img != null && (img as String).trim().isNotEmpty);

      if (hasTextOptions && hasImageOptions) {
        return options[index] as String;
      } else if (hasImageOptions) {
        return (index + 1).toString();
      }
    }
    return options[index] as String;
  }

  Widget _buildNavigationButtons(ExamController controller, BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            if (controller.currentQuestionIndex.value != controller.currentCategoryQuestions.length - 1)
              ElevatedButton.icon(
                iconAlignment: IconAlignment.end,
                onPressed: controller.nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text('Next', style: TextStyle(fontWeight: FontWeight.w600)),
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
  }
}