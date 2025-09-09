import 'package:crackitx/app_models/exam_model.dart';

class SingleExamHistoryModel {
  final String id;
  final dynamic answerPaper;
  final String? subjectName;
  final String? teacherName;
  final String? orgCode;
  final String? batch;
  final String? userId;
  final String? questionId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? examDuration;
  final String? minusMarks;
  final int? studentCount;
  final int totalMarks;
  final List<QuestionModel> questionList;
  final int totalQuestion;

  SingleExamHistoryModel({
    required this.id,
    this.answerPaper,
    this.subjectName,
    this.teacherName,
    this.orgCode,
    this.batch,
    this.userId,
    this.questionId,
    this.startTime,
    this.endTime,
    this.examDuration,
    this.minusMarks,
    this.studentCount,
    required this.totalMarks,
    required this.questionList,
    required this.totalQuestion,
  });

  factory SingleExamHistoryModel.fromJson(Map<String, dynamic> json) =>
      SingleExamHistoryModel(
        id: json['id'] ?? '',
        answerPaper: json["answerPaper"],
        subjectName: json["subjectName"] as String?,
        teacherName: json["teacherName"] as String?,
        orgCode: json["orgCode"] as String?,
        batch: json["batch"] as String?,
        userId: json["userId"] as String?,
        questionId: json["questionId"] as String?,
        startTime: json["startTime"] != null
            ? DateTime.tryParse(json["startTime"])
            : null,
        endTime:
            json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
        examDuration: json['examDuration'] != null
            ? (json['examDuration'] is int
                ? json['examDuration']
                : int.tryParse(json['examDuration'].toString()))
            : null,
        minusMarks: json["minusMarks"] as String?,
        studentCount: json["studentCount"] as int?,
        totalMarks: json['totalMarks'] ?? 0,
        totalQuestion: json['questionList'] != null
            ? (json['questionList'] as List).length
            : 0,
        questionList: json['questionList'] != null
            ? (json['questionList'] as List)
                .map(
                    (e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "answerPaper": answerPaper,
        "subjectName": subjectName,
        "teacherName": teacherName,
        "orgCode": orgCode,
        "batch": batch,
        "userId": userId,
        "questionId": questionId,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "examDuration": examDuration,
        "minusMarks": minusMarks,
        "studentCount": studentCount,
        "questionList": questionList.map((q) => q.toJson()).toList(),
        "totalMarks": totalMarks,
        "totalQuestion": totalQuestion,
      };

  @override
  String toString() {
    return 'SingleExamHistoryModel(id: $id, answerPaper: $answerPaper, subjectName: $subjectName, teacherName: $teacherName, orgCode: $orgCode, batch: $batch, userId: $userId, questionId: $questionId, startTime: $startTime, endTime: $endTime, examDuration: $examDuration, minusMarks: $minusMarks, studentCount: $studentCount, totalMarks: $totalMarks, totalQuestion: $totalQuestion, questionList: $questionList)';
  }

  bool isEmpty() {
    return id.isEmpty &&
        answerPaper == null &&
        subjectName == null &&
        teacherName == null &&
        orgCode == null &&
        batch == null &&
        userId == null &&
        questionId == null &&
        startTime == null &&
        endTime == null &&
        examDuration == null &&
        minusMarks == null &&
        studentCount == null &&
        totalMarks == 0 &&
        totalQuestion == 0 &&
        questionList.isEmpty;
  }

  SingleExamHistoryModel toEmpty() {
    return SingleExamHistoryModel(
      id: '',
      answerPaper: null,
      subjectName: null,
      teacherName: null,
      orgCode: null,
      batch: null,
      userId: null,
      questionId: null,
      startTime: null,
      endTime: null,
      examDuration: null,
      minusMarks: null,
      studentCount: null,
      totalQuestion: 0,
      totalMarks: 0,
      questionList: [],
    );
  }
}
