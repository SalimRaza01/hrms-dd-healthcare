import 'dart:math';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TeamPunchrecords extends StatefulWidget {
  final String? punchRecords;

  const TeamPunchrecords({super.key, required this.punchRecords});

  @override
  State<TeamPunchrecords> createState() => _TeamPunchrecordsState();
}

class _TeamPunchrecordsState extends State<TeamPunchrecords> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    List<String> punches =
        (widget.punchRecords?.split(',') ?? []).toSet().toList();
    // ..sort();

    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Punch Records',
          style: TextStyle(
            fontSize: height * 0.02,
            fontWeight: FontWeight.w500,
            color: AppColor.mainTextColor,
          ),
        ),
        backgroundColor: AppColor.mainBGColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: punches.length ~/ 2,
                itemBuilder: (context, index) {
                  String punchIn = punches[index * 2];
                  String punchOut = punches[index * 2 + 1];

                  String punchInTime =
                      punchIn.substring(0, min(5, punchIn.length));
                  String punchOutTime =
                      punchOut.substring(0, min(5, punchOut.length));

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
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Clock In',
                                  style: TextStyle(
                                    fontSize: height * 0.014,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                                SizedBox(height: height * 0.005),
                                Text(
                                  punchInTime.isNotEmpty
                                      ? punchInTime
                                      : '--/--',
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Clock Out',
                                  style: TextStyle(
                                    fontSize: height * 0.014,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                                SizedBox(height: height * 0.005),
                                Text(
                                punchOutTime != '23:59'
                                      ? punchOutTime
                                      : '--/--',
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
