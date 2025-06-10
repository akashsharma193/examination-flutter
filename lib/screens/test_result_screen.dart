import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/controllers/test_result_detail_controller.dart';
import 'package:crackitx/app_models/test_result_detail_model.dart';
import 'package:crackitx/core/constants/color_constants.dart';
import 'package:crackitx/core/constants/textstyles_constants.dart';
import 'package:crackitx/widgets/gradient_app_bar.dart';

class TestResultScreen extends StatefulWidget {
  final SingleExamHistoryModel model;

  const TestResultScreen(
      {super.key, required this.model, required this.userId});
  final String userId;
  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  final controller = Get.put(TestResultDetailController());
  String currentFilter = 'all';

  @override
  void initState() {
    controller.fetchData(widget.model.questionId ?? '', widget.userId);
    super.initState();
  }

  Future<void> _onRefresh() async {
    setState(() {
      currentFilter = 'all';
    });
    controller.refreshData(widget.model.questionId ?? '', widget.userId);
  }

  List<dynamic> _getFilteredQuestions(TestResultDetailModel model) {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestResultDetailController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              controller.refreshData(
                  widget.model.questionId ?? '', widget.userId);
            },
            backgroundColor: AppColors.cardBackground,
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
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
    double percentage = (model.correctAnswer / model.totalQuestion) * 100;
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
                        radius: 50,
                        titleStyle:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: model.unAttemptedCount.toDouble(),
                        color: Colors.grey,
                        title: "${model.unAttemptedCount}",
                        radius: 50,
                        titleStyle:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: model.incorrectAnswer.toDouble(),
                        color: Colors.red,
                        title: "${model.incorrectAnswer}",
                        radius: 50,
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

  /// List of Questions with User Answers - FIXED VERSION
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

    // Fixed: Using map instead of List.generate and converting to List<Widget>
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
                  SizedBox(
                    width: Get.width * 0.55,
                    child: Text(
                      question.question,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "Time: ${question.timeTaken ?? 0} sec",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                children: question.option.map<Widget>((option) {
                  Color optionColor = Colors.grey[200]!;
                  if (option == question.userAnswer) {
                    optionColor = option == question.correctAnswer
                        ? Colors.green
                        : Colors.red;
                  } else if (option == question.correctAnswer) {
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
                      children: [
                        Icon(
                          option == question.userAnswer
                              ? (option == question.correctAnswer
                                  ? Icons.check_circle
                                  : Icons.cancel)
                              : Icons.circle_outlined,
                          color: option == question.userAnswer
                              ? (option == question.correctAnswer
                                  ? Colors.white
                                  : Colors.white)
                              : Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
