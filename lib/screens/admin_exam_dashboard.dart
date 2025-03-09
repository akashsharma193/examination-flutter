import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/repositories/exam_repo.dart';

class AdminExamDashboard extends StatefulWidget {
  @override
  _AdminExamDashboardState createState() => _AdminExamDashboardState();
}

class _AdminExamDashboardState extends State<AdminExamDashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _orgCodeController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  List<Map<String, dynamic>> _questions = [];

  int examDuration = 5;

  void _addQuestion() {
    setState(() {
      _questions.add({
        "question": "",
        "options": ["", "", "", ""],
        "correctAnswer": ""
      });
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _startTime != null &&
        _endTime != null) {
      Map<String, dynamic> examData = {
        "questionList": _questions,
        "examDuration": _durationController.text,
        "subjectName": _subjectController.text,
        "teacherName": _teacherController.text,
        "orgCode": _orgCodeController.text,
        "batch": _batchController.text,
        "startTime": _startTime!.toIso8601String(),
        "endTime": _endTime!.toIso8601String(),
      };
      ExamRepo examRepo = ExamRepo();
      examRepo.createExam(examData).then((v) {
        switch (v) {
          case AppSuccess():
            Get.snackbar("Success", "Exam created successfully",
                snackPosition: SnackPosition.BOTTOM);
            break;
          case AppFailure():
            Get.snackbar("Error", v.errorMessage,
                snackPosition: SnackPosition.BOTTOM);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Exam"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Subject Name", _subjectController),
                _buildTextField("Teacher Name", _teacherController),
                _buildTextField("Organization Code", _orgCodeController),
                _buildTextField("Batch", _batchController),
                // Dropdown for exam duration
                DropdownButtonFormField<int>(
                  decoration:
                      InputDecoration(labelText: "Exam Duration (minutes)"),
                  value: examDuration,
                  items: List.generate(36, (index) => (index + 1) * 5)
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text("$e minutes")))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => examDuration = value);
                    }
                  },
                ),
                SizedBox(height: 10),
                _buildDateTimePicker(
                    "Start Time",
                    (date) => setState(() => _startTime = date),
                    _startTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(_startTime!)
                        : "Select Date & Time"),
                _buildDateTimePicker(
                    "End Time",
                    (date) => setState(() => _endTime = date),
                    _endTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(_endTime!)
                        : "Select Date & Time"),
                SizedBox(height: 20),
                Text("Questions",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._questions
                    .asMap()
                    .entries
                    .map((entry) => _buildQuestionCard(entry.key)),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _addQuestion, child: Text("Add Question")),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                    onPressed: _submitForm,
                    child: Text("Submit Exam", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "This field is required" : null,
      ),
    );
  }

  Widget _buildDateTimePicker(
      String label, Function(DateTime) onPicked, String subTitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subTitle),
        // subtitle: Text(_startTime != null
        //     ? DateFormat('yyyy-MM-dd HH:mm').format(_startTime!)
        //     : "Select Date & Time"),
        trailing: Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            TimeOfDay? time = await showTimePicker(
                context: context, initialTime: TimeOfDay.now());
            if (time != null) {
              onPicked(DateTime(picked.year, picked.month, picked.day,
                  time.hour, time.minute));
            }
          }
        },
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "Question ${index + 1}",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => _questions[index]["question"] = val,
            ),
            const SizedBox(height: 12),
            const Text(
              "Options",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              "(Select one option for correct Answer)",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(4, (optionIndex) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Option ${optionIndex + 1}",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) =>
                        _questions[index]["options"][optionIndex] = val,
                  ),
                  leading: Radio<int>(
                    value: optionIndex,
                    groupValue: _questions[index]["correctAnswerIndex"],
                    onChanged: (val) {
                      setState(() {
                        _questions[index]["correctAnswerIndex"] = val;
                      });
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
