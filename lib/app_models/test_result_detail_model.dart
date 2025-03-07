class TestResultDetailModel {
  List<FinalResult> finalResult;
  int totalQuestion;
  int correctAnswer;
  int incorrectAnswer;
  int totalMarks;

  TestResultDetailModel({
    required this.finalResult,
    required this.totalQuestion,
    required this.correctAnswer,
    required this.incorrectAnswer,
    required this.totalMarks,
  });

  factory TestResultDetailModel.fromJson(Map<String, dynamic> json) {
    return TestResultDetailModel(
      finalResult: (json['finalResult'] as List)
          .map((e) => FinalResult.fromJson(e))
          .toList(),
      totalQuestion: json['totalQuestion'] ?? 0,
      correctAnswer: json['correctAnswer'] ?? 0,
      incorrectAnswer: json['incorrectAnswer'] ?? 0,
      totalMarks: json['totalMarks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finalResult': finalResult.map((e) => e.toJson()).toList(),
      'totalQuestion': totalQuestion,
      'correctAnswer': correctAnswer,
      'incorrectAnswer': incorrectAnswer,
      'totalMarks': totalMarks,
    };
  }

  bool isEmpty() {
    return totalQuestion == 0 &&
        correctAnswer == 0 &&
        incorrectAnswer == 0 &&
        totalMarks == 0 &&
        finalResult.isEmpty;
  }

  static TestResultDetailModel toEmpty() {
    return TestResultDetailModel(
      finalResult: [],
      totalQuestion: 0,
      correctAnswer: 0,
      incorrectAnswer: 0,
      totalMarks: 0,
    );
  }

  @override
  String toString() {
    return 'TestResultDetailModel(totalQuestion: $totalQuestion, correctAnswer: $correctAnswer, incorrectAnswer: $incorrectAnswer, totalMarks: $totalMarks, finalResult: $finalResult)';
  }
}

class FinalResult {
  String question;
  List<String> option;
  String correctAnswer;
  String userAnswer;
  String color;

  FinalResult({
    required this.question,
    required this.option,
    required this.correctAnswer,
    required this.userAnswer,
    required this.color,
  });

  factory FinalResult.fromJson(Map<String, dynamic> json) {
    return FinalResult(
      question: json['question'] ?? '',
      option: List<String>.from(json['option'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      color: json['color'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'option': option,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'color': color,
    };
  }

  @override
  String toString() {
    return 'FinalResult(question: $question, option: $option, correctAnswer: $correctAnswer, userAnswer: $userAnswer, color: $color)';
  }
}
