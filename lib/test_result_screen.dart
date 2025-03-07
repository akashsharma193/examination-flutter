import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/test_result_detail_controller.dart';
import 'package:offline_test_app/app_models/test_result_detail_model.dart';

class TestResultScreen extends StatelessWidget {
  final String qId;

  const TestResultScreen({super.key, required this.qId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestResultDetailController>(
      init: TestResultDetailController()..fetchData(qId),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Test Result"),
            backgroundColor: Colors.blueAccent,
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              _buildScoreSection(controller.testResultDetailModel),
              Expanded(child: _buildQuestionList(controller.testResultDetailModel)),
            ],
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
          Text(
            "Total Score: ${model.correctAnswer} / ${model.totalQuestion}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
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
  Widget _buildQuestionList(TestResultDetailModel model) {
    return ListView.builder(
      itemCount: model.finalResult.length,
      itemBuilder: (context, index) {
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
                      optionColor =
                      option == question.correctAnswer ? Colors.green : Colors.red;
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
