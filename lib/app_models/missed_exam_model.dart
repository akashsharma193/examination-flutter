class MissedExamModel {
  final String id;
  final List<MissedQuestionModel> questionList;
  final String subjectName;
  final String teacherName;
  final String orgCode;
  final String batch;
  final String? userId;
  final String questionId;
  final String examDuration;
  final String? minusMarks;
  final int? studentCount;
  final DateTime startTime;
  final DateTime endTime;

  MissedExamModel({
    required this.id,
    required this.questionList,
    required this.subjectName,
    required this.teacherName,
    required this.orgCode,
    required this.batch,
    this.userId,
    required this.questionId,
    required this.examDuration,
    this.minusMarks,
    this.studentCount,
    required this.startTime,
    required this.endTime,
  });

  factory MissedExamModel.fromJson(Map<String, dynamic> json) {
    return MissedExamModel(
      id: json['id']?.toString() ?? '',
      questionList: json['questionList'] != null
          ? (json['questionList'] as List)
              .map((q) => MissedQuestionModel.fromJson(q))
              .toList()
          : [],
      subjectName: json['subjectName']?.toString() ?? '',
      teacherName: json['teacherName']?.toString() ?? '',
      orgCode: json['orgCode']?.toString() ?? '',
      batch: json['batch']?.toString() ?? '',
      userId: json['userId']?.toString(),
      questionId: json['questionId']?.toString() ?? '',
      examDuration: json['examDuration']?.toString() ?? '0',
      minusMarks: json['minusMarks']?.toString(),
      studentCount: json['studentCount'] is int ? json['studentCount'] : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionList': questionList.map((q) => q.toJson()).toList(),
      'subjectName': subjectName,
      'teacherName': teacherName,
      'orgCode': orgCode,
      'batch': batch,
      'userId': userId,
      'questionId': questionId,
      'examDuration': examDuration,
      'minusMarks': minusMarks,
      'studentCount': studentCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  static MissedExamModel toEmpty() {
    return MissedExamModel(
      id: '',
      questionList: [],
      subjectName: '',
      teacherName: '',
      orgCode: '',
      batch: '',
      questionId: '',
      examDuration: '0',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );
  }
}

class MissedQuestionModel {
  final String? question;
  final String? questionImage;
  final List<String> options;
  final List<String>? optionsImage;
  final String correctAnswer;
  final String? userAnswer;
  final bool isImage;
  final String? color;
  final int? timeTaken;
  final String? catacategory;

  MissedQuestionModel({
    this.question,
    this.questionImage,
    required this.options,
    this.optionsImage,
    required this.correctAnswer,
    this.userAnswer,
    required this.isImage,
    this.color,
    this.timeTaken,
    this.catacategory,
  });

  factory MissedQuestionModel.fromJson(Map<String, dynamic> json) {
    return MissedQuestionModel(
      question: json['question']?.toString(),
      questionImage: json['questionImage']?.toString(),
      options: json['options'] != null
          ? List<String>.from(json['options'].map((e) => e?.toString() ?? ''))
          : [],
      optionsImage: json['optionsImage'] != null
          ? List<String>.from(
              json['optionsImage'].map((e) => e?.toString() ?? ''))
          : null,
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      userAnswer: json['userAnswer']?.toString(),
      isImage: json['isImage'] == true || json['isImage'] == 'true',
      color: json['color']?.toString(),
      timeTaken: json['timeTaken'] is int ? json['timeTaken'] : null,
      catacategory:
          json['category']?.toString() ?? json['catacategory']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'questionImage': questionImage,
      'options': options,
      'optionsImage': optionsImage,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isImage': isImage,
      'color': color,
      'timeTaken': timeTaken,
      'catacategory': catacategory,
    };
  }
}
