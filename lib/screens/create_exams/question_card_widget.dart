import 'package:flutter/material.dart';

class QuestionCardWidget extends StatefulWidget {
  final int index;
  final Map<String, dynamic> questionData;
  final VoidCallback onDelete;

  const QuestionCardWidget({
    super.key,
    required this.index,
    required this.questionData,
    required this.onDelete,
  });

  @override
  _QuestionCardWidgetState createState() => _QuestionCardWidgetState();
}

class _QuestionCardWidgetState extends State<QuestionCardWidget> {
  late TextEditingController _questionController;
  List<TextEditingController> _optionControllers = [];
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.questionData["question"]);

    List<String> options =
        List<String>.from(widget.questionData["options"] ?? []);
    _optionControllers = List.generate(4, (index) {
      return TextEditingController(
          text: options.length > index ? options[index] : "");
    });

    _selectedAnswerIndex = widget.questionData["correctAnswerIndex"];
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Question Field**
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: "Question ${widget.index + 1}",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => widget.questionData["question"] = val,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// **Options**
            const Text(
              "Options",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              "(Select one option as the correct answer)",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Column(
              children: List.generate(4, (optionIndex) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: TextFormField(
                    controller: _optionControllers[optionIndex],
                    decoration: InputDecoration(
                      labelText: "Option ${optionIndex + 1}",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      if (widget.questionData["options"].length <=
                          optionIndex) {
                        widget.questionData["options"].add(val);
                      } else {
                        widget.questionData["options"][optionIndex] = val;
                      }
                    },
                  ),
                  leading: Radio<int>(
                    value: optionIndex,
                    groupValue: _selectedAnswerIndex,
                    onChanged: (val) {
                      setState(() {
                        _selectedAnswerIndex = val;
                        widget.questionData["correctAnswerIndex"] = val;
                        widget.questionData["correctAnswer"] =
                            _optionControllers[val!].text;
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
