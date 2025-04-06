import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/app_models/single_exam_history_model.dart';
import 'package:offline_test_app/controllers/test_result_detail_controller.dart';
import 'package:offline_test_app/app_models/test_result_detail_model.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/core/constants/textstyles_constants.dart';

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
  @override
  void initState() {
    controller.fetchData(widget.model.questionId ?? '', widget.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestResultDetailController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              controller.refreshData(
                  widget.model.questionId ?? '', widget.userId);
            },
            child: const Icon(Icons.refresh),
          ),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: AppColors.appBar,
            title: Text(
              "${widget.model.subjectName}",
              style: AppTextStyles.heading.copyWith(color: Colors.white),
            ),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
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
                      ..._buildQuestionList(controller.testResultDetailModel),
                    ],
                  ),
                ),
        );
      },
    );
  }

  /// Score and Graph Representation
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

  /// List of Questions with User Answers
  List<Widget> _buildQuestionList(TestResultDetailModel model) {
    return List.generate(
      model.finalResult.length,
      (index) {
        final question = model.finalResult[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: question.option.map((option) {
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
      },
    );
  }
}
