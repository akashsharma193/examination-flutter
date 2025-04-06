import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDropdownMenuStateful extends StatefulWidget {
  final List<String> batches;
  final Function(String?) onSelect;

  const MyDropdownMenuStateful({
    super.key,
    required this.batches,
    required this.onSelect,
  });

  @override
  State<MyDropdownMenuStateful> createState() => _MyDropdownMenuStatefulState();
}

class _MyDropdownMenuStatefulState extends State<MyDropdownMenuStateful> {
  String? selectedBatch;

  @override
  Widget build(BuildContext context) {
    print("dropdown batches Lsit : ${widget.batches}");
    return DropdownMenu<String>(
      width: 250, // Adjust width as needed
      menuHeight: MediaQuery.of(context).size.height * 0.3,
      initialSelection: selectedBatch,
      onSelected: (String? value) {
        setState(() {
          selectedBatch = value;
        });
        widget.onSelect(value);
      },
      dropdownMenuEntries:
          widget.batches.map<DropdownMenuEntry<String>>((String batch) {
        return DropdownMenuEntry<String>(
          value: batch,
          label: batch,
        );
      }).toList(),
      hintText: 'Select Batch',
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
