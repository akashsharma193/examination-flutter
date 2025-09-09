class TestResultDetailModel {
  String id;
  List<FinalResult> finalResult;
  String subjectName;
  String teacherName;
  String orgCode;
  String batch;
  String questionId;
  String userId;
  String startTime;
  String endTime;
  int totalQuestion;
  int correctAnswer;
  int incorrectAnswer;
  int totalMarks;
  int unAttemptedCount;

  TestResultDetailModel({
    required this.id,
    required this.finalResult,
    required this.subjectName,
    required this.teacherName,
    required this.orgCode,
    required this.batch,
    required this.questionId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.totalQuestion,
    required this.correctAnswer,
    required this.incorrectAnswer,
    required this.totalMarks,
    required this.unAttemptedCount,
  });

  factory TestResultDetailModel.fromJson(Map<String, dynamic> json) {
    List<FinalResult> answerList = ((json['answerList'] ?? []) as List)
        .map((e) => FinalResult.fromJson(e))
        .toList();

    int totalQuestions = answerList.length;
    int correct = 0;
    int incorrect = 0;
    int unattempted = 0;

    for (var answer in answerList) {
      if (answer.userAnswer.isEmpty) {
        unattempted++;
      } else if (answer.userAnswer == answer.correctAnswer) {
        correct++;
      } else {
        incorrect++;
      }
    }

    return TestResultDetailModel(
      id: json['id'] ?? '',
      finalResult: answerList,
      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      orgCode: json['orgCode'] ?? '',
      batch: json['batch'] ?? '',
      questionId: json['questionId'] ?? '',
      userId: json['userId'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      totalQuestion: totalQuestions,
      correctAnswer: correct,
      incorrectAnswer: incorrect,
      totalMarks: correct,
      unAttemptedCount: unattempted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answerList': finalResult.map((e) => e.toJson()).toList(),
      'subjectName': subjectName,
      'teacherName': teacherName,
      'orgCode': orgCode,
      'batch': batch,
      'questionId': questionId,
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'totalQuestion': totalQuestion,
      'correctAnswer': correctAnswer,
      'incorrectAnswer': incorrectAnswer,
      'totalMarks': totalMarks,
      'unAttempted': unAttemptedCount,
    };
  }

  bool isEmpty() {
    return totalQuestion == 0 &&
        correctAnswer == 0 &&
        incorrectAnswer == 0 &&
        totalMarks == 0 &&
        unAttemptedCount == 0 &&
        finalResult.isEmpty;
  }

  static TestResultDetailModel toEmpty() {
    return TestResultDetailModel(
      id: '',
      finalResult: [],
      subjectName: '',
      teacherName: '',
      orgCode: '',
      batch: '',
      questionId: '',
      userId: '',
      startTime: '',
      endTime: '',
      totalQuestion: 0,
      correctAnswer: 0,
      incorrectAnswer: 0,
      totalMarks: 0,
      unAttemptedCount: 0,
    );
  }

  @override
  String toString() {
    return 'TestResultDetailModel(id: $id, totalQuestion: $totalQuestion, correctAnswer: $correctAnswer, incorrectAnswer: $incorrectAnswer, totalMarks: $totalMarks, unAttempted: $unAttemptedCount, finalResult: $finalResult)';
  }
}

class FinalResult {
  String question;
  List<String> option;
  String correctAnswer;
  String userAnswer;
  bool isImage;
  String? color;
  int timeTaken;

  FinalResult({
    required this.question,
    required this.option,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isImage,
    this.color,
    required this.timeTaken,
  });

  factory FinalResult.fromJson(Map<String, dynamic> json) {
    return FinalResult(
      question: json['question'] ?? '',
      option: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      isImage: json['isImage'] ?? false,
      color: json['color'],
      timeTaken: json['timeTaken'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': option,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isImage': isImage,
      'color': color,
      'timeTaken': timeTaken,
    };
  }

  @override
  String toString() {
    return 'FinalResult(question: $question, option: $option, correctAnswer: $correctAnswer, userAnswer: $userAnswer, isImage: $isImage, color: $color, timeTaken: $timeTaken)';
  }
}
