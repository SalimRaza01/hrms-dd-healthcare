

import 'package:flutter/material.dart';

class TaskFlowScreen extends StatefulWidget {
  @override
  _TaskFlowScreenState createState() => _TaskFlowScreenState();
}

class _TaskFlowScreenState extends State<TaskFlowScreen> {
  int _currentStep = 0;

  final List<String> stages = [
    'Created',
    'In Progress',
    'On Hold',
    'Review',
    'Completed',
    'Running Late',
  ];

  final Map<String, Color> stageColors = {
    'Created': Colors.grey,
    'In Progress': Colors.blue,
    'On Hold': Colors.orange,
    'Review': Colors.purple,
    'Completed': Colors.green,
    'Running Late': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Stepper')),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              controlsBuilder: null,
              steps: List.generate(stages.length, (index) {
                return Step(
                  title: Text(stages[index]),
                  
                  content:  _activityCard(
            context,
            userName: 'Salim',
            timeAgo: '4 days ago',
            mainContent: 'Running Late → Review (Stage)',
            subContent: 'Submission Date: 10/01/2025 15:36:12',
          ),
                  isActive: index == _currentStep,
                  state: index <= _currentStep
                      ? StepState.complete
                      : StepState.indexed,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }



  Widget _activityCard(
    BuildContext context, {
    required String userName,
    required String timeAgo,
    required String mainContent,
    required String subContent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
  
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
       
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 4),
     
                Text(
                  mainContent,
                  style: TextStyle(fontSize: 14),
                ),
            
                if (subContent.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    subContent,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
