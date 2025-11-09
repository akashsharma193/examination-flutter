import 'package:crackitx/app_models/missed_exam_model.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/app_models/test_result_detail_model.dart';

class MissedExamConverter {
  static SingleExamHistoryModel toSingleExamHistoryModel(
      MissedExamModel missedExam) {
    return SingleExamHistoryModel(
      id: missedExam.id,
      subjectName: missedExam.subjectName,
      teacherName: missedExam.teacherName,
      orgCode: missedExam.orgCode,
      batch: missedExam.batch,
      userId: missedExam.userId,
      questionId: missedExam.questionId,
      startTime: missedExam.startTime,
      endTime: missedExam.endTime,
      examDuration: int.tryParse(missedExam.examDuration),
      minusMarks: missedExam.minusMarks,
      studentCount: missedExam.studentCount,
      totalMarks: 0,
      totalQuestion: missedExam.questionList.length,
      questionList: [],
      showResult: true,
    );
  }

  static bool _isValidBase64(String? data) {
    if (data == null || data.isEmpty || data.length < 50) return false;
    return true;
  }

  static TestResultDetailModel toTestResultDetailModel(
      MissedExamModel missedExam) {
    int correctCount = 0;
    int incorrectCount = 0;
    int unattemptedCount = 0;

    List<FinalResult> finalResults = missedExam.questionList.map((q) {
      bool isAttempted = q.userAnswer != null && q.userAnswer!.isNotEmpty;
      bool isCorrect = isAttempted && q.userAnswer == q.correctAnswer;

      if (isAttempted) {
        if (isCorrect) {
          correctCount++;
        } else {
          incorrectCount++;
        }
      } else {
        unattemptedCount++;
      }

      String questionText = '';
      String? questionImageData;
      List<String> optionsList = [];
      List<String>? optionsImageList;

      bool hasValidQuestionImage = _isValidBase64(q.questionImage);
      bool hasValidQuestion = q.question != null && q.question!.isNotEmpty;

      if (hasValidQuestion) {
        questionText = q.question!;
      }

      if (hasValidQuestionImage) {
        questionImageData = q.questionImage;
      }

      bool hasValidOptionsImages = q.optionsImage != null &&
          q.optionsImage!.isNotEmpty &&
          q.optionsImage!.any((img) => _isValidBase64(img));

      bool hasValidOptions =
          q.options.isNotEmpty && q.options.any((opt) => opt.isNotEmpty);

      if (hasValidOptions) {
        optionsList = q.options;
      }

      if (hasValidOptionsImages) {
        optionsImageList = q.optionsImage;
      }

      return FinalResult(
        question: questionText,
        questionImage: questionImageData,
        option: optionsList,
        optionsImage: optionsImageList,
        correctAnswer: q.correctAnswer,
        userAnswer: q.userAnswer ?? '',
        isImage: hasValidQuestionImage || hasValidOptionsImages,
        color: q.color,
        timeTaken: q.timeTaken ?? 0,
        category: q.catacategory ?? 'Uncategorized',
      );
    }).toList();

    return TestResultDetailModel(
      id: missedExam.id,
      finalResult: finalResults,
      subjectName: missedExam.subjectName,
      teacherName: missedExam.teacherName,
      orgCode: missedExam.orgCode,
      batch: missedExam.batch,
      questionId: missedExam.questionId,
      userId: missedExam.userId ?? '',
      startTime: missedExam.startTime.toIso8601String(),
      endTime: missedExam.endTime.toIso8601String(),
      totalQuestion: missedExam.questionList.length,
      correctAnswer: correctCount,
      incorrectAnswer: incorrectCount,
      totalMarks: correctCount,
      unAttemptedCount: unattemptedCount,
    );
  }
}
