import 'package:flutter/material.dart';

class AnnoucememtWidget extends StatelessWidget {
  const AnnoucememtWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Flat white background
        borderRadius: BorderRadius.circular(28), // Smooth rounded edges
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            'Announcement',
            style: TextStyle(
              fontSize: height * 0.016,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),

          const SizedBox(height: 12),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/image/annoucementImage.png',
              fit: BoxFit.fitWidth,
              width: width,
            ),
          ),

          const SizedBox(height: 12),

          // Announcement message
          Text(
            'No announcements have been published yet. Keep an eye out for future updates.',
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
