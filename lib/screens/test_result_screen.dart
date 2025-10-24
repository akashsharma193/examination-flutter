import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/controllers/test_result_detail_controller.dart';
import 'package:crackitx/app_models/test_result_detail_model.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';
import 'dart:convert';
import 'dart:typed_data';

class TestResultScreen extends StatefulWidget {
  final SingleExamHistoryModel model;
  final String userId;
  final TestResultDetailModel? preloadedData;

  const TestResultScreen({
    super.key,
    required this.model,
    required this.userId,
    this.preloadedData,
  });

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  final controller = Get.put(TestResultDetailController());
  String currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.preloadedData != null) {
      controller.setPreloadedData(widget.preloadedData!);
    } else {
      controller.fetchData(widget.model.questionId ?? '', widget.userId);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      currentFilter = 'all';
    });
    if (widget.preloadedData != null) {
      controller.setPreloadedData(widget.preloadedData!);
    } else {
      controller.refreshData(widget.model.questionId ?? '', widget.userId);
    }
  }

  List<FinalResult> _getFilteredQuestions(TestResultDetailModel model) {
    switch (currentFilter) {
      case 'correct':
        return model.finalResult
            .where((q) =>
                q.userAnswer == q.correctAnswer && q.userAnswer.isNotEmpty)
            .toList();
      case 'incorrect':
        return model.finalResult
            .where((q) =>
                q.userAnswer != q.correctAnswer && q.userAnswer.isNotEmpty)
            .toList();
      case 'unattempted':
        return model.finalResult.where((q) => q.userAnswer.isEmpty).toList();
      default:
        return model.finalResult;
    }
  }

  String _getFilterTitle() {
    switch (currentFilter) {
      case 'correct':
        return 'Correct Answers';
      case 'incorrect':
        return 'Wrong Answers';
      case 'unattempted':
        return 'Not Attempted';
      default:
        return 'All Questions';
    }
  }

  String _getOptionIdentifier(FinalResult question, int index) {
    if (question.optionsImage != null && question.optionsImage!.isNotEmpty) {
      final hasTextOptions =
          question.option.any((opt) => opt.trim().isNotEmpty);
      final hasImageOptions = question.optionsImage!
          .any((img) => img != null && img.trim().isNotEmpty);

      if (hasTextOptions && hasImageOptions) {
        return question.option[index];
      } else if (hasImageOptions) {
        return (index + 1).toString();
      }
    }
    return question.option[index];
  }

  bool _isCorrectAnswer(FinalResult question, int index) {
    final optionId = _getOptionIdentifier(question, index);
    if (question.correctAnswer == optionId) return true;

    final correctNum = int.tryParse(question.correctAnswer);
    if (correctNum != null && correctNum == index + 1) return true;

    return false;
  }

  bool _isUserAnswer(FinalResult question, int index) {
    final optionId = _getOptionIdentifier(question, index);
    if (question.userAnswer == optionId) return true;

    final userNum = int.tryParse(question.userAnswer);
    if (userNum != null && userNum == index + 1) return true;

    return false;
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestResultDetailController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: widget.preloadedData == null
              ? FloatingActionButton.small(
                  onPressed: () {
                    controller.refreshData(
                        widget.model.questionId ?? '', widget.userId);
                  },
                  backgroundColor: AppColors.cardBackground,
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                )
              : null,
          appBar: GradientAppBar(
            title: Text(
              "${widget.model.subjectName}",
              style: AppTextStyles.heading.copyWith(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                "Total question: ${controller.testResultDetailModel.totalQuestion}, "),
                            Text(
                                "Attempted: ${controller.testResultDetailModel.totalQuestion - controller.testResultDetailModel.unAttemptedCount}, "),
                            Text(
                                "Not Attempted: ${controller.testResultDetailModel.unAttemptedCount} "),
                          ],
                        ),
                        _buildScoreSection(controller.testResultDetailModel),
                        _buildFilterInfo(),
                        ..._buildQuestionList(controller.testResultDetailModel),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFilterInfo() {
    if (currentFilter == 'all') return const SizedBox.shrink();

    String filterText = '';
    Color filterColor = Colors.blue;

    switch (currentFilter) {
      case 'correct':
        filterText = 'Showing Correct Answers Only';
        filterColor = Colors.green;
        break;
      case 'incorrect':
        filterText = 'Showing Wrong Answers Only';
        filterColor = Colors.red;
        break;
      case 'unattempted':
        filterText = 'Showing Unattempted Questions Only';
        filterColor = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filterColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: filterColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            filterText,
            style: TextStyle(
              color: filterColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                currentFilter = 'all';
              });
            },
            child: Icon(
              Icons.clear,
              color: filterColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(TestResultDetailModel model) {
    double percentage = model.totalQuestion > 0
        ? (model.correctAnswer / model.totalQuestion) * 100
        : 0.0;
    bool isPassed = percentage >= 50;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Total Score: ${model.correctAnswer} / ${model.totalQuestion}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: Get.width * 0.2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Wrong Answer')
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          color: Colors.green,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Correct Answer')
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Not Attempted')
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent && pieTouchResponse != null) {
                          final touchedIndex = pieTouchResponse
                              .touchedSection?.touchedSectionIndex;
                          if (touchedIndex != null) {
                            setState(() {
                              switch (touchedIndex) {
                                case 0:
                                  currentFilter = 'correct';
                                  break;
                                case 1:
                                  currentFilter = 'unattempted';
                                  break;
                                case 2:
                                  currentFilter = 'incorrect';
                                  break;
                              }
                            });
                          }
                        }
                      },
                    ),
                    sections: [
                      PieChartSectionData(
                        value: model.correctAnswer.toDouble(),
                        color: Colors.green,
                        title: "${model.correctAnswer}",
                        radius: currentFilter == 'correct' ? 60 : 50,
                        titleStyle:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: model.unAttemptedCount.toDouble(),
                        color: Colors.grey,
                        title: "${model.unAttemptedCount}",
                        radius: currentFilter == 'unattempted' ? 60 : 50,
                        titleStyle:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: model.incorrectAnswer.toDouble(),
                        color: Colors.red,
                        title: "${model.incorrectAnswer}",
                        radius: currentFilter == 'incorrect' ? 60 : 50,
                        titleStyle:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      isPassed ? "Passed" : "Failed",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionList(TestResultDetailModel model) {
    final filteredQuestions = _getFilteredQuestions(model);

    if (filteredQuestions.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No questions found for ${_getFilterTitle().toLowerCase()}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        )
      ];
    }

    return filteredQuestions.map<Widget>((question) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildQuestionContent(question),
                  ),
                  Text(
                    "Time: ${question.timeTaken} sec",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                children: List.generate(
                  question.option.isNotEmpty
                      ? question.option.length
                      : (question.optionsImage?.length ?? 0),
                  (index) {
                    final option = question.option.isNotEmpty &&
                            index < question.option.length
                        ? question.option[index]
                        : '';
                    final optionImage = question.optionsImage != null &&
                            index < question.optionsImage!.length
                        ? question.optionsImage![index]
                        : null;

                    final isCorrect = _isCorrectAnswer(question, index);
                    final isUserAns = _isUserAnswer(question, index);

                    Color optionColor = Colors.grey[200]!;
                    if (isUserAns) {
                      optionColor = isCorrect ? Colors.green : Colors.red;
                    } else if (isCorrect) {
                      optionColor = Colors.greenAccent;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: optionColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isUserAns
                                ? (isCorrect
                                    ? Icons.check_circle
                                    : Icons.cancel)
                                : Icons.circle_outlined,
                            color: isUserAns ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildOptionContent(option, optionImage),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildQuestionContent(FinalResult question) {
    final hasQuestionText = question.question.trim().isNotEmpty;
    final hasQuestionImage = question.questionImage != null &&
        question.questionImage!.trim().isNotEmpty;

    if (hasQuestionText && hasQuestionImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildBase64Image(question.questionImage!, 150),
          ),
        ],
      );
    } else if (hasQuestionImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildBase64Image(question.questionImage!, 150),
      );
    } else {
      return Text(
        question.question,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    }
  }

  Widget _buildOptionContent(String option, String? optionImage) {
    final hasText = option.trim().isNotEmpty;
    final hasValidImage = optionImage != null &&
        optionImage.trim().isNotEmpty &&
        optionImage.length > 50;

    if (hasText && hasValidImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _buildBase64Image(optionImage, 100),
          ),
        ],
      );
    } else if (hasValidImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _buildBase64Image(optionImage, 100),
      );
    } else {
      return Text(
        option,
        style: const TextStyle(fontSize: 14),
      );
    }
  }
}
