
import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';



class PunchCardWidget extends StatefulWidget {
  const PunchCardWidget({super.key});

  @override
  State<PunchCardWidget> createState() => _PunchCardWidgetState();
}

class _PunchCardWidgetState extends State<PunchCardWidget> {


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return FutureBuilder<PunchRecordModel>(
      future: fetchPunchRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return EmptyWidget(height: height, width: width);
        } else if (snapshot.hasData) {
          final record = snapshot.data!;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [AppColor.mainThemeColor, AppColor.primaryThemeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Punch In
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Punch in',
                          style: TextStyle(
                              fontSize: height * 0.015,
                              color: AppColor.mainFGColor),
                        ),
                        Text(
                          record.formatTime(record.inTime),
                          style: TextStyle(
                            fontSize: height * 0.020,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainFGColor,
                          ),
                        ),
                      ],
                    ),
                    // Punch Out
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Punch out',
                          style: TextStyle(
                              fontSize: height * 0.015,
                              color: AppColor.mainFGColor),
                        ),
                        Text(
                          record.formatTime(record.outTime),
                          style: TextStyle(
                            fontSize: height * 0.020,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainFGColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: height * 0.015, color: AppColor.mainFGColor),
                    SizedBox(width: width * 0.02),
                    Expanded(
                      child: Text(
                        record.location,
                        style: TextStyle(
                            fontSize: height * 0.015,
                            color: AppColor.mainFGColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return EmptyWidget(height: height, width: width);
        }
      },
    );
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [AppColor.mainThemeColor, AppColor.primaryThemeColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor,
            blurRadius: 10,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Punch In
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Punch in',
                    style: TextStyle(
                        fontSize: height * 0.015, color: AppColor.mainFGColor),
                  ),
                  Text(
                    '--/--',
                    style: TextStyle(
                      fontSize: height * 0.020,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainFGColor,
                    ),
                  ),
                ],
              ),
              // Punch Out
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Punch out',
                    style: TextStyle(
                        fontSize: height * 0.015, color: AppColor.mainFGColor),
                  ),
                  Text(
                    '--/--',
                    style: TextStyle(
                      fontSize: height * 0.020,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainFGColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: height * 0.02),
          Row(
            children: [
              Icon(Icons.location_on,
                  size: height * 0.015, color: AppColor.mainFGColor),
              SizedBox(width: width * 0.02),
              Expanded(
                child: Text(
                  'Not Fetched',
                  style: TextStyle(
                      fontSize: height * 0.015, color: AppColor.mainFGColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
