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

  factory ExamModel.fromRawJson(String str) =>
      ExamModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

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

  bool get isEmpty => id.isEmpty && questionList.isEmpty;

  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return "ExamModel(id: $id, subjectName: $subjectName, teacherName: $teacherName, isActive: $isActive)";
  }
}

class QuestionModel {
  final String? question;
  final String? questionImage;
  final List<String>? options;
  final List<String>? optionsImage;
  final String correctAnswer;
  final String? userAnswer;
  final String? color;
  final String? category;
  int timeTaken;
  bool isMarked;

  QuestionModel({
    this.question,
    this.questionImage,
    this.options,
    this.optionsImage,
    required this.correctAnswer,
    this.userAnswer,
    this.color,
    this.category,
    this.timeTaken = 0,
    this.isMarked = false,
  });

  factory QuestionModel.fromRawJson(String str) =>
      QuestionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuestionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return QuestionModel.toEmpty();

    return QuestionModel(
      question: json["question"],
      questionImage: json["questionImage"],
      options: json["options"] != null
          ? (json["options"] as List).map((x) => x.toString()).toList()
          : null,
      optionsImage: json["optionsImage"] != null
          ? (json["optionsImage"] as List).map((x) => x.toString()).toList()
          : null,
      correctAnswer: json["correctAnswer"] ?? "",
      userAnswer: json["userAnswer"],
      color: json["color"],
      category: json["category"],
      timeTaken: json['timeTaken'] ?? 0,
      isMarked: json['isMarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "question": question,
        "questionImage": questionImage,
        "options": options,
        "optionsImage": optionsImage,
        "correctAnswer": correctAnswer,
        "userAnswer": userAnswer,
        "color": color,
        "category": category,
        'timeTaken': timeTaken,
        'isMarked': isMarked,
      };

  factory QuestionModel.toEmpty() => QuestionModel(
        question: null,
        questionImage: null,
        options: null,
        optionsImage: null,
        correctAnswer: "",
        userAnswer: null,
        color: null,
        category: null,
        timeTaken: 0,
        isMarked: false,
      );

  bool get isEmpty =>
      (question?.isEmpty ?? true) &&
      (questionImage?.isEmpty ?? true) &&
      (options?.isEmpty ?? true);

  bool get isNotEmpty => !isEmpty;

  bool get hasQuestion => question != null && question!.isNotEmpty;

  bool get hasQuestionImage =>
      questionImage != null && questionImage!.isNotEmpty;

  bool get hasOptionsImage => optionsImage != null && optionsImage!.isNotEmpty;

  @override
  String toString() {
    return "QuestionModel(question: $question, questionImage: ${questionImage?.substring(0, 20)}..., category: $category, correctAnswer: $correctAnswer, userAnswer: $userAnswer, timeTaken: $timeTaken, isMarked: $isMarked)";
  }
}
