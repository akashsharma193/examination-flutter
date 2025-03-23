class SingleExamHistoryModel {
  final dynamic answerPaper;
  final String? subjectName;
  final String? teacherName;
  final String? orgCode;
  final String? batch;
  final String? userId;
  final String? questionId;
  final DateTime? startTime;
  final DateTime? endTime;

  SingleExamHistoryModel({
    this.answerPaper,
    this.subjectName,
    this.teacherName,
    this.orgCode,
    this.batch,
    this.userId,
    this.questionId,
    this.startTime,
    this.endTime,
  });

  factory SingleExamHistoryModel.fromJson(Map<String, dynamic> json) =>
      SingleExamHistoryModel(
        answerPaper: json["answerPaper"] ?? '',
        subjectName: json["subjectName"] as String? ?? 'Unknown Subject',
        teacherName: json["teacherName"] as String? ?? 'Unknown Teacher',
        orgCode: json["orgCode"] as String? ?? 'N/A',
        batch: json["batch"] as String? ?? 'N/A',
        userId: json["userId"] as String? ?? 'N/A',
        questionId: json["questionId"] as String? ?? 'N/A',
        startTime: DateTime.tryParse(json["startTime"] ?? ''),
        endTime: DateTime.tryParse(json['endTime'] ?? ''),
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
      };

  @override
  String toString() {
    return 'SingleExamHistoryModel(answerPaper: $answerPaper, subjectName: $subjectName, teacherName: $teacherName, orgCode: $orgCode, batch: $batch, userId: $userId, questionId: $questionId, startTime: $startTime, endTime: $endTime)';
  }

  bool isEmpty() {
    return answerPaper == null &&
        subjectName == null &&
        teacherName == null &&
        orgCode == null &&
        batch == null &&
        userId == null &&
        questionId == null &&
        startTime == null &&
        endTime == null;
  }

  SingleExamHistoryModel toEmpty() {
    return SingleExamHistoryModel(
      answerPaper: null,
      subjectName: null,
      teacherName: null,
      orgCode: null,
      batch: null,
      userId: null,
      questionId: null,
      startTime: null,
      endTime: null,
    );
  }
}
