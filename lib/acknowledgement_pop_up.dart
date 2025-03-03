// import 'package:flutter/material.dart';

// class TestScreen extends StatefulWidget {
//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   void showAcknowledgementPopup(BuildContext context) {
//     bool isChecked = false;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text("Test Acknowledgement"),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // 5 Pointer Display
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(5, (index) {
//                       return Icon(Icons.star, color: Colors.amber, size: 32);
//                     }),
//                   ),
//                   SizedBox(height: 16),

//                   // Checkbox for Acknowledgement
//                   CheckboxListTile(
//                     title: Text("I acknowledge the instructions."),
//                     value: isChecked,
//                     onChanged: (value) {
//                       setState(() {
//                         isChecked = value!;
//                       });
//                     },
//                   ),

//                   SizedBox(height: 16),

//                   // Continue Button
//                   ElevatedButton(
//                     onPressed: isChecked
//                         ? () {
//                             Navigator.pop(context); // Close popup
//                             // Proceed to test
//                           }
//                         : null, // Disabled if checkbox is unchecked
//                     child: Text("Continue"),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Test Screen")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => showAcknowledgementPopup(context),
//           child: Text("Start Test"),
//         ),
//       ),
//     );
//   }
// }
