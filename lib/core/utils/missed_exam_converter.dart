import 'package:crackitx/app_models/missed_exam_model.dart';
import 'package:crackitx/app_models/single_exam_history_model.dart';
import 'package:crackitx/app_models/exam_model.dart';
import 'package:crackitx/app_models/test_result_detail_model.dart';

class MissedExamConverter {
  static SingleExamHistoryModel toSingleExamHistoryModel(
      MissedExamModel missedExam) {
    List<QuestionModel> questionList =
        missedExam.questionList.map((missedQuestion) {
      return QuestionModel(
        question: missedQuestion.question,
        options: missedQuestion.options,
        correctAnswer: missedQuestion.correctAnswer,
        userAnswer: missedQuestion.userAnswer,
        color: missedQuestion.color,
        timeTaken: missedQuestion.timeTaken ?? 0,
      );
    }).toList();

    return SingleExamHistoryModel(
      id: missedExam.id,
      answerPaper: null,
      subjectName: missedExam.subjectName,
      teacherName: missedExam.teacherName,
      orgCode: missedExam.orgCode,
      batch: missedExam.batch,
      userId: missedExam.userId,
      questionId: missedExam.questionId,
      startTime: missedExam.startTime,
      endTime: missedExam.endTime,
      examDuration: int.tryParse(missedExam.examDuration) ?? 0,
      minusMarks: missedExam.minusMarks,
      studentCount: missedExam.studentCount,
      totalMarks: 0,
      questionList: questionList,
      totalQuestion: questionList.length,
    );
  }

  static TestResultDetailModel toTestResultDetailModel(
      MissedExamModel missedExam) {
    int correctCount = 0;
    int incorrectCount = 0;
    int unattemptedCount = 0;

    List<FinalResult> finalResults =
        missedExam.questionList.map((missedQuestion) {
      if (missedQuestion.userAnswer == null ||
          missedQuestion.userAnswer!.isEmpty) {
        unattemptedCount++;
      } else if (missedQuestion.userAnswer == missedQuestion.correctAnswer) {
        correctCount++;
      } else {
        incorrectCount++;
      }

      return FinalResult(
        question: missedQuestion.question,
        option: missedQuestion.options,
        correctAnswer: missedQuestion.correctAnswer,
        userAnswer: missedQuestion.userAnswer ?? '',
        isImage: missedQuestion.isImage,
        color: missedQuestion.color,
        timeTaken: missedQuestion.timeTaken ?? 0,
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
