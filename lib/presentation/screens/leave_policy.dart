import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LeavePolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
              backgroundColor: Colors.white,
        title: Text("Leave Policy Instructions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSectionTitle('Casual & Comp-Off Leave:'),
            _buildBulletPoint(
                'Casual Leave and Comp Off can only be applied for future days within the current month.'),
            _buildBulletPoint(
                'If you are applying for leave on the same day (today), it must be submitted before 9 AM. The leave request will apply for both the 1st half and the 2nd half of the day.'),
            SizedBox(height: 20),
            _buildSectionTitle('Medical Leave:'),
            _buildBulletPoint(
                'Medical leave can only be applied for up to 6 past days, based on the available medical leave balance.'),
            _buildBulletPoint(
                'You cannot apply for medical leave for less than 2 days in the past.'),
            _buildBulletPoint(
                'Medical leave cannot be applied for future dates.'),
            _buildBulletPoint(
                'A prescription from a registered medical practitioner is required when applying for medical leave, especially for past days. The prescription should mention the duration of rest or treatment.'),
            SizedBox(height: 20),
            _buildSectionTitle('Earned Leave:'),
            _buildBulletPoint(
                'Earned leave can only be applied for future dates based on the available earned leave balance.'),
            _buildBulletPoint(
                'Earned leave is applicable only for full days; partial or half-day leave is not allowed.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColor.mainThemeColor),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(Icons.circle, size: 8, color: AppColor.mainThemeColor),
          ),
          SizedBox(width: 8),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          )),
        ],
      ),
    );
  }
}
