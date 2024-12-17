import 'dart:math';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class PunchRecordScreen extends StatelessWidget {
  final String? punchRecords;

  PunchRecordScreen({required this.punchRecords});

  @override
  Widget build(BuildContext context) {

    List<String> punches = punchRecords?.split(',') ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Punch Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColor.mainTextColor,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: punches.length - 1,
                itemBuilder: (context, index) {
                  String punch = punches[index];

                  bool isPunchIn = punch.contains('in');
                  Color textColor = isPunchIn ? Colors.green : Colors.red;
                  String timeString = punch.substring(0, min(5, punch.length));

                  return Container(
                    decoration: BoxDecoration(
                        // color: AppColor.mainBGColor,
                        border: Border.all(color: AppColor.mainBGColor, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPunchIn ? 'Punched In' : 'Punched Out',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: textColor,
                            ),
                          ),
                          Text(
                            timeString,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



