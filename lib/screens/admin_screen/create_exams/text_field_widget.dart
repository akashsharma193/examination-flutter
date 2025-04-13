import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  bool readOnly;
  String text;
  final TextEditingController? controller;

  TextFieldWidget(
      {super.key,
      required this.label,
      this.controller,
      this.readOnly = false,
      this.text = ''});

  @override
  Widget build(BuildContext context) {
    final thisController = controller ?? TextEditingController(text: text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: thisController,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "This field is required" : null,
      ),
    );
  }
}
