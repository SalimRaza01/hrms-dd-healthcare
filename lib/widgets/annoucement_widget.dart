
import 'package:flutter/material.dart';
import 'package:hrms/core/theme/app_colors.dart';

class AnnoucememtWidget extends StatelessWidget {
  const AnnoucememtWidget({
    super.key,

  });

  @override
  Widget build(BuildContext context) {
         final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Card(
      color: AppColor.mainFGColor,
      elevation: 4,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: AppColor.shadowColor,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Announcement',
              style: TextStyle(
                  fontSize: height * 0.015,
                  color: AppColor.mainTextColor,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: height * 0.005,
            ),
            Image.asset(
                fit: BoxFit.fitWidth,
                width: width,
                'assets/image/annoucementImage.png'),
            SizedBox(
              height: height * 0.005,
            ),
            Text(
              'No announcements have been published yet. Keep an eye out for future updates.',
              style: TextStyle(
                fontSize: height * 0.012,
                color: AppColor.mainTextColor2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}