import 'dart:convert';

class ExamModel {
  final String id;
  final List<QuestionModel> questionList;
  final String subjectName;
  final String teacherName;
  final String orgCode;
  final String batch;
  final String questionId;
  final String examDuration;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  ExamModel({
    required this.id,
    required this.questionList,
    required this.subjectName,
    required this.teacherName,
    required this.orgCode,
    required this.batch,
    required this.questionId,
    required this.examDuration,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  /// Convert JSON String to `ExamModel`
  factory ExamModel.fromRawJson(String str) =>
      ExamModel.fromJson(json.decode(str));

  /// Convert `ExamModel` to JSON String
  String toRawJson() => json.encode(toJson());

  /// Convert JSON Map to `ExamModel` (Handles null values)
  factory ExamModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ExamModel.toEmpty();

    return ExamModel(
      id: json["id"] ?? "",
      questionList: (json["questionList"] as List?)
              ?.map((x) => QuestionModel.fromJson(x))
              .toList() ??
          [],
      subjectName: json["subjectName"] ?? "",
      teacherName: json["teacherName"] ?? "",
      orgCode: json["orgCode"] ?? "",
      batch: json["batch"] ?? "",
      questionId: json["questionId"] ?? "",
      examDuration: json["examDuration"] ?? "",
      startTime:
          DateTime.tryParse(json["startTime"] ?? "") ?? DateTime(2000, 1, 1),
      endTime: DateTime.tryParse(json["endTime"] ?? "") ?? DateTime(2000, 1, 1),
      isActive: json["isActive"] ?? false,
    );
  }

  /// Convert `ExamModel` to JSON Map
  Map<String, dynamic> toJson() => {
        "id": id,
        "questionList": questionList.map((x) => x.toJson()).toList(),
        "subjectName": subjectName,
        "teacherName": teacherName,
        "orgCode": orgCode,
        "batch": batch,
        "questionId": questionId,
        "examDuration": examDuration,
        "startTime": startTime.toIso8601String(),
        "endTime": endTime.toIso8601String(),
        "isActive": isActive,
      };

  /// Returns an **empty ExamModel** (Safe Default)
  factory ExamModel.toEmpty() => ExamModel(
        id: "",
        questionList: [],
        subjectName: "",
        teacherName: "",
        orgCode: "",
        batch: "",
        questionId: "",
        examDuration: "",
        startTime: DateTime(2000, 1, 1),
        endTime: DateTime(2000, 1, 1),
        isActive: false,
      );

  /// Checks if the object is empty
  bool get isEmpty => id.isEmpty && questionList.isEmpty;

  /// Checks if the object is not empty
  bool get isNotEmpty => !isEmpty;

  /// Debugging: Convert `ExamModel` to String
  @override
  String toString() {
    return "ExamModel(id: $id, subjectName: $subjectName, teacherName: $teacherName, isActive: $isActive)";
  }
}

class QuestionModel {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? userAnswer;
  final String? color;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.color,
  });

  /// Convert JSON String to `QuestionModel`
  factory QuestionModel.fromRawJson(String str) =>
      QuestionModel.fromJson(json.decode(str));

  /// Convert `QuestionModel` to JSON String
  String toRawJson() => json.encode(toJson());

  /// Convert JSON Map to `QuestionModel` (Handles null values)
  factory QuestionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return QuestionModel.toEmpty();

    return QuestionModel(
      question: json["question"] ?? "",
      options:
          (json["options"] as List?)?.map((x) => x.toString()).toList() ?? [],
      correctAnswer: json["correctAnswer"] ?? "",
      userAnswer: json["userAnswer"],
      color: json["color"],
    );
  }

  /// Convert `QuestionModel` to JSON Map
  Map<String, dynamic> toJson() => {
        "question": question,
        "options": options,
        "correctAnswer": correctAnswer,
        "userAnswer": userAnswer,
        "color": color,
      };

  /// Returns an **empty QuestionModel** (Safe Default)
  factory QuestionModel.toEmpty() => QuestionModel(
        question: "",
        options: [],
        correctAnswer: "",
        userAnswer: null,
        color: null,
      );

  /// Checks if the object is empty
  bool get isEmpty => question.isEmpty && options.isEmpty;

  /// Checks if the object is not empty
  bool get isNotEmpty => !isEmpty;

  /// Debugging: Convert `QuestionModel` to String
  @override
  String toString() {
    return "QuestionModel(question: $question, correctAnswer: $correctAnswer, userAnswer: $userAnswer)";
  }
}
