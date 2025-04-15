import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class QuizSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 80% of screen height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          // Add drag indicator
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  // buildToggleOption('Type', ['Questions', 'Quiz']),
                  buildToggleOption('Question Type', ['MCQ', 'T/F']),
                  buildToggleOption('From', ['Context', 'Topic']),
                  // buildOptionsSelector('No. of Options', ['A', 'B', 'C', 'D']),
                  buildOptionsSelector('Difficulty', ['Easy', 'Medium', 'Hard']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildToggleOption(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        Center(
          child: ToggleSwitch(
            minWidth: 140.0,
            minHeight: 45.0,
            cornerRadius: 20.0,
            activeBgColors: [
              [Colors.purple[300]!],
              [Colors.purple[300]!]
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey[200]!,
            inactiveFgColor: Colors.grey[800]!,
            initialLabelIndex: 0,
            totalSwitches: 2,
            labels: options,
            radiusStyle: true,
            onToggle: (index) {
              print('switched to: $index');
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget buildTextOption(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget buildOptionsSelector(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 12),
        Center(
          child: ToggleSwitch(
            minWidth: 80.0,
            minHeight: 45.0,
            cornerRadius: 20.0,
            activeBgColors: List.generate(
              options.length,
              (index) => [Colors.purple[300]!],
            ),
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey[200]!,
            inactiveFgColor: Colors.grey[800]!,
            initialLabelIndex: 0,
            totalSwitches: options.length,
            labels: options,
            radiusStyle: true,
            onToggle: (index) {
              print('switched to: $index');
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
