import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as i_o;
import 'package:offline_test_app/app_models/exam_model.dart';

T getController<T extends GetxController>(T Function() controller) {
  return Get.isRegistered<T>() ? Get.find<T>() : Get.put<T>(controller());
}

Future<List<QuestionModel>> importQuestionsFromExcel() async {
  List<QuestionModel> questions = [];

  // Pick an Excel file
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result == null) {
    print("❌ No file selected.");
    return questions;
  }

  var fileBytes;

  if (kIsWeb) {
    fileBytes = result.files.first.bytes;
    if (fileBytes == null) {
      print(
          "❌ Failed to read file bytes on Web. Make sure you selected a valid .xlsx file.");
      return questions;
    }
  } else {
    try {
      fileBytes = i_o.File(result.files.single.path!).readAsBytesSync();
    } catch (e) {
      print("❌ Failed to read file on Mobile/Desktop: $e");
      return questions;
    }
  }

  if (fileBytes.isEmpty) {
    print("❌ The file is empty.");
    return questions;
  }

  try {
    var excel = Excel.decodeBytes(fileBytes);
    print("✅ Excel file successfully read!");

    // List all sheet names
    print("Sheets found: ${excel.tables.keys}");

    if (excel.tables.keys.isEmpty) {
      print("❌ The Excel file has no sheets.");
      return questions;
    }

    // Access the first sheet
    String firstSheetName = excel.tables.keys.first;
    var sheet = excel.tables[firstSheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      print("❌ The first sheet is empty.");
      return questions;
    }

    print(
        "✅ First sheet '${firstSheetName}' contains ${sheet.rows.length} rows.");

    bool headerFound = false;
    int headerRowIndex = 0;
    int questionColumnIndex = -1;
    int optionsColumnIndex = -1;
    int correctAnswerColumnIndex = -1;
    int colorColumnIndex = -1;

    // 🔍 Search for the header row (Question, Options, Correct Answer, Color)
    for (int rowIndex = 0; rowIndex < sheet.rows.length; rowIndex++) {
      var row = sheet.rows[rowIndex];

      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        var cell = row[colIndex];
        if (cell != null &&
            cell.value.toString().trim().toLowerCase() == "question") {
          headerFound = true;
          headerRowIndex = rowIndex;

          for (int i = colIndex; i < row.length; i++) {
            var header = row[i]?.value.toString().trim().toLowerCase();
            if (header == "question") questionColumnIndex = i;
            if (header == "options (comma-separated)") optionsColumnIndex = i;
            if (header == "correct answer") correctAnswerColumnIndex = i;
            if (header == "color") colorColumnIndex = i;
          }
          break;
        }
      }
      if (headerFound) break;
    }

    if (!headerFound) {
      print(
          "❌ No header row found. Make sure your Excel file contains headers like 'Question', 'Options (comma-separated)', 'Correct Answer', 'Color'.");
      return questions;
    }

    // ✅ Read rows starting after the header row
    for (int rowIndex = headerRowIndex + 1;
        rowIndex < sheet.rows.length;
        rowIndex++) {
      var row = sheet.rows[rowIndex];

      if (row.isEmpty ||
          row.every(
              (cell) => cell == null || cell.value.toString().trim().isEmpty)) {
        continue; // Skip empty rows
      }

      String question =
          questionColumnIndex >= 0 && row.length > questionColumnIndex
              ? row[questionColumnIndex]?.value.toString() ?? ''
              : '';

      List<String> options =
          optionsColumnIndex >= 0 && row.length > optionsColumnIndex
              ? row[optionsColumnIndex]?.value.toString().split(',') ?? []
              : [];

      String correctAnswer =
          correctAnswerColumnIndex >= 0 && row.length > correctAnswerColumnIndex
              ? row[correctAnswerColumnIndex]?.value.toString() ?? ''
              : '';

      String? color = colorColumnIndex >= 0 && row.length > colorColumnIndex
          ? row[colorColumnIndex]?.value.toString()
          : null;

      if (question.isNotEmpty &&
          options.isNotEmpty &&
          correctAnswer.isNotEmpty) {
        questions.add(QuestionModel(
          question: question,
          options: options,
          correctAnswer: correctAnswer,
          color: color,
        ));
      }
    }

    print("✅ Successfully imported ${questions.length} questions.");
  } catch (e) {
    print("❌ Error decoding Excel file: $e");
  }

  return questions;
}
