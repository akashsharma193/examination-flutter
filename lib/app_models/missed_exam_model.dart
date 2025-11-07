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
      id: json['id'] ?? '',
      questionList: json['questionList'] != null
          ? (json['questionList'] as List)
              .map((q) => MissedQuestionModel.fromJson(q))
              .toList()
          : [],
      subjectName: json['subjectName'] ?? '',
      teacherName: json['teacherName'] ?? '',
      orgCode: json['orgCode'] ?? '',
      batch: json['batch'] ?? '',
      userId: json['userId'],
      questionId: json['questionId'] ?? '',
      examDuration: json['examDuration']?.toString() ?? '0',
      minusMarks: json['minusMarks']?.toString(),
      studentCount: json['studentCount'],
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
      question: json['question'],
      questionImage: json['questionImage'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : [],
      optionsImage: json['optionsImage'] != null
          ? List<String>.from(json['optionsImage'])
          : null,
      correctAnswer: json['correctAnswer'] ?? '',
      userAnswer: json['userAnswer'],
      isImage: json['isImage'] ?? false,
      color: json['color'],
      timeTaken: json['timeTaken'],
      catacategory: json['category'] ?? json['catacategory'],
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
