import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/theme/app_colors.dart';

class PunchRecordModel {
  final String inTime;
  final String outTime;
  final String location;

  PunchRecordModel({
    required this.inTime,
    required this.outTime,
    required this.location,
  });

  factory PunchRecordModel.fromJson(Map<String, dynamic> json) {
    return PunchRecordModel(
      inTime: json['InTime'] ?? '',
      outTime: json['OutTime'] ?? '',
      location: json['location'] ?? 'Not Available',
    );
  }

  String formatTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '--/--';
    }
  }
}

class PunchCardWidget extends StatefulWidget {
  const PunchCardWidget({super.key});

  @override
  State<PunchCardWidget> createState() => _PunchCardWidgetState();
}

class _PunchCardWidgetState extends State<PunchCardWidget> {
  final Dio dio = Dio();
  final Box _authBox = Hive.box('authBox');

  Future<PunchRecordModel> fetchPunchRecord() async {
    final String token = _authBox.get('token');

    final response = await dio.get(
      '$getPunchAttendence/${_authBox.get('employeeId')}',
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.data);
      final Map<String, dynamic> data = response.data['data'][0];
      return PunchRecordModel.fromJson(data);
    } else {
      throw Exception("Failed to fetch punch data");
    }
  }

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
