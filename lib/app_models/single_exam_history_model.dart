import 'package:offline_test_app/app_models/exam_model.dart';

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
  final int totalMarks;
  final List<QuestionModel> questionList;

  SingleExamHistoryModel(
      {required this.id,
      this.answerPaper,
      this.subjectName,
      this.teacherName,
      this.orgCode,
      this.batch,
      this.userId,
      this.questionId,
      this.startTime,
      this.endTime,
      required this.totalMarks,
      required this.questionList,
      this.examDuration});

  factory SingleExamHistoryModel.fromJson(Map<String, dynamic> json) =>
      SingleExamHistoryModel(
        id: json['id'] ?? '',
        answerPaper: json["answerPaper"] ?? '',
        subjectName: json["subjectName"] as String? ?? 'Unknown Subject',
        teacherName: json["teacherName"] as String? ?? 'Unknown Teacher',
        orgCode: json["orgCode"] as String? ?? 'N/A',
        batch: json["batch"] as String? ?? 'N/A',
        userId: json["userId"] as String? ?? 'N/A',
        questionId: json["questionId"] as String? ?? 'N/A',
        startTime: DateTime.tryParse(json["startTime"] ?? ''),
        endTime: DateTime.tryParse(json['endTime'] ?? ''),
        totalMarks: json['totalMarks'] ?? 0,
        questionList: json['questionList'] == null
            ? []
            : (json['questionList'] as List)
                .map(
                    (e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
        examDuration: json['examDuration'] == null
            ? 5
            : json['examDuration'] is int
                ? json['examDuration']
                : int.tryParse(json['examDuration']),
      );
  Map<String, dynamic> toJson() => {
        "answerPaper": answerPaper,
        "subjectName": subjectName,
        "teacherName": teacherName,
        "orgCode": orgCode,
        "batch": batch,
        "userId": userId,
        "questionId": questionId,
        "startTime": startTime,
        "endTime": endTime,
        "questionList": questionList,
        'examDuration': examDuration,
        'totalMarks': totalMarks,
        'id': id,
      };

  @override
  String toString() {
    return 'SingleExamHistoryModel(id:$id, answerPaper: $answerPaper, subjectName: $subjectName, teacherName: $teacherName, orgCode: $orgCode, batch: $batch, userId: $userId, questionId: $questionId, startTime: $startTime, endTime: $endTime, examDuration: $examDuration, questionList : $questionList)';
  }

  bool isEmpty() {
    return id.isNotEmpty &&
        answerPaper == null &&
        subjectName == null &&
        teacherName == null &&
        orgCode == null &&
        batch == null &&
        userId == null &&
        questionId == null &&
        startTime == null &&
        examDuration != null &&
        questionList.isNotEmpty &&
        endTime == null;
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
      totalMarks: 0,
      questionList: [],
    );
  }
}
