class GetExamModel {
  final List<QuestionModel>? questionList;
  final String? subjectName;
  final String? teacherName;
  final String? orgCode;
  final String? batch;
  final dynamic userId;
  final String? questionId;
  final String? examDuration;
  final String? stratTime;
  final String? endTime;

  GetExamModel({
    this.questionList,
    this.subjectName,
    this.teacherName,
    this.orgCode,
    this.batch,
    this.userId,
    this.questionId,
    this.examDuration,
    this.stratTime,
    this.endTime,
  });

  factory GetExamModel.fromJson(Map<String, dynamic> json) => GetExamModel(
        questionList: json["questionList"] == null
            ? []
            : List<QuestionModel>.from(
                json["questionList"]!.map((x) => QuestionModel.fromJson(x))),
        subjectName: json["subjectName"],
        teacherName: json["teacherName"],
        orgCode: json["orgCode"],
        batch: json["batch"],
        userId: json["userId"],
        questionId: json["questionId"],
        examDuration: json["examDuration"],
        stratTime: json["stratTime"],
        endTime: json["endTime"],
      );

  Map<String, dynamic> toJson() => {
        "questionList": questionList == null
            ? []
            : List<dynamic>.from(questionList!.map((x) => x.toJson())),
        "subjectName": subjectName,
        "teacherName": teacherName,
        "orgCode": orgCode,
        "batch": batch,
        "userId": userId,
        "questionId": questionId,
        "examDuration": examDuration,
        "stratTime": stratTime,
        "endTime": endTime,
      };

  @override
  String toString() {
    return 'GetExamModel(subjectName: $subjectName, teacherName: $teacherName, orgCode: $orgCode, batch: $batch, userId: $userId, questionId: $questionId, examDuration: $examDuration, stratTime: $stratTime, endTime: $endTime, questionList: $questionList)';
  }

  /// Returns an empty instance of GetExamModel
  factory GetExamModel.toEmpty() => GetExamModel(
        questionList: [],
        subjectName: '',
        teacherName: '',
        orgCode: '',
        batch: '',
        userId: null,
        questionId: '',
        examDuration: '',
        stratTime: '',
        endTime: '',
      );

  /// Checks if the model is empty
  bool get isEmpty =>
      (questionList == null || questionList!.isEmpty) &&
      (subjectName == null || subjectName!.isEmpty) &&
      (teacherName == null || teacherName!.isEmpty) &&
      (orgCode == null || orgCode!.isEmpty) &&
      (batch == null || batch!.isEmpty) &&
      (userId == null) &&
      (questionId == null || questionId!.isEmpty) &&
      (examDuration == null || examDuration!.isEmpty) &&
      (stratTime == null || stratTime!.isEmpty) &&
      (endTime == null || endTime!.isEmpty);
}

class QuestionModel {
  final String? question;
  final List<String>? option;
  final String? correctAnswer;
  final dynamic userAnswer;
  final dynamic color;

  QuestionModel({
    this.question,
    this.option,
    this.correctAnswer,
    this.userAnswer,
    this.color,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        question: json["question"],
        option: json["option"] == null
            ? []
            : List<String>.from(json["option"]!.map((x) => x)),
        correctAnswer: json["correctAnswer"],
        userAnswer: json["userAnswer"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "question": question,
        "option":
            option == null ? [] : List<dynamic>.from(option!.map((x) => x)),
        "correctAnswer": correctAnswer,
        "userAnswer": userAnswer,
        "color": color,
      };

  @override
  String toString() {
    return 'QuestionModel(question: $question, option: $option, correctAnswer: $correctAnswer, userAnswer: $userAnswer, color: $color)';
  }
}
