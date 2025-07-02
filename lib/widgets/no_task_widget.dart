import 'package:flutter/material.dart';

class NoTaskWidget extends StatelessWidget {
  const NoTaskWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            'Today Task',
            style: TextStyle(
              fontSize: height * 0.016,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
           SizedBox(height: height * 0.004),
          Text(
            'The tasks assigned to you for today',
            style: TextStyle(
              fontSize: height * 0.013,
              color: Colors.grey.shade600,
            ),
          ),

           SizedBox(height: height * 0.016),

          // Image section
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/image/Frame.png',
                height: height * 0.08,
              ),
            ),
          ),

            SizedBox(height: height * 0.016),

          // No tasks message
          Center(
            child: Text(
              'No Tasks Assigned',
              style: TextStyle(
                fontSize: height * 0.016,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

           SizedBox(height: height * 0.016),

          Text(
            'It looks like you don’t have any tasks assigned to you right now. Don’t worry, this space will be updated as new tasks become available.',
            style: TextStyle(
              fontSize: height * 0.013,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
