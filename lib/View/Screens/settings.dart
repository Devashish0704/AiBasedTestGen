// import 'package:flutter/material.dart';
// import 'package:toggle_switch/toggle_switch.dart';
// import 'package:provider/provider.dart';
// import 'package:test_generator/Data/quiz_settings.dart';

// class QuizSettingsScreen extends StatefulWidget {
//   @override
//   _QuizSettingsScreenState createState() => _QuizSettingsScreenState();
// }

// class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     // Access the provider
//     final settingsProvider = Provider.of<QuizSettingsProvider>(context);
//     final settings = settingsProvider.settings;

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: EdgeInsets.symmetric(vertical: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Settings',
//                       style:
//                           TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 16),
//                   buildToggleOption(
//                     'Question Type',
//                     ['MCQ', 'T/F'],
//                     settings.questionType == 'MCQ' ? 0 : 1,
//                     (index) {
//                       if (index != null) {
//                         settingsProvider
//                             .updateQuestionType(index == 0 ? 'MCQ' : 'T/F');
//                       }
//                     },
//                   ),
//                   buildToggleOption(
//                     'From',
//                     ['Context', 'Topic'],
//                     settings.from == 'Context' ? 0 : 1,
//                     (index) {
//                       if (index != null) {
//                         settingsProvider
//                             .updateFrom(index == 0 ? 'Context' : 'Topic');
//                       }
//                     },
//                   ),
//                   buildOptionsSelector(
//                     'Difficulty',
//                     ['Easy', 'Medium', 'Hard'],
//                     ['Easy', 'Medium', 'Hard'].indexOf(settings.difficulty),
//                     (index) {
//                       if (index != null) {
//                         settingsProvider.updateDifficulty(
//                             ['Easy', 'Medium', 'Hard'][index]);
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildToggleOption(String title, List<String> options, int initialIndex,
//       void Function(int?) onToggle) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         SizedBox(height: 12),
//         Center(
//           child: ToggleSwitch(
//             minWidth: 140.0,
//             minHeight: 45.0,
//             cornerRadius: 20.0,
//             activeBgColors: [
//               [Colors.purple[300]!],
//               [Colors.purple[300]!]
//             ],
//             activeFgColor: Colors.white,
//             inactiveBgColor: Colors.grey[200]!,
//             inactiveFgColor: Colors.grey[800]!,
//             initialLabelIndex: initialIndex,
//             totalSwitches: 2,
//             labels: options,
//             radiusStyle: true,
//             onToggle: onToggle,
//           ),
//         ),
//         SizedBox(height: 24),
//       ],
//     );
//   }

//   Widget buildOptionsSelector(String title, List<String> options,
//       int initialIndex, void Function(int?) onToggle) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         SizedBox(height: 12),
//         Center(
//           child: ToggleSwitch(
//             minWidth: 80.0,
//             minHeight: 45.0,
//             cornerRadius: 20.0,
//             activeBgColors: List.generate(
//               options.length,
//               (index) => [Colors.purple[300]!],
//             ),
//             activeFgColor: Colors.white,
//             inactiveBgColor: Colors.grey[200]!,
//             inactiveFgColor: Colors.grey[800]!,
//             initialLabelIndex: initialIndex,
//             totalSwitches: options.length,
//             labels: options,
//             radiusStyle: true,
//             onToggle: onToggle,
//           ),
//         ),
//         SizedBox(height: 24),
//       ],
//     );
//   }
// }
