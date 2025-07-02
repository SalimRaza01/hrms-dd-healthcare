import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/model/models.dart';
import '../../core/provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';

class PunchHistoryScreen extends StatefulWidget {
  const PunchHistoryScreen({super.key});

  @override
  State<PunchHistoryScreen> createState() => _PunchHistoryScreenState();
}

class _PunchHistoryScreenState extends State<PunchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Provider.of<PunchHistoryProvider>(context, listen: false).fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PunchHistoryProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: provider.isLoading
          ? Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: AppColor.mainFGColor,
                size: height * 0.05,
              ),
            )
          : provider.error != null
              ? Center(
                  child: Text(
                    'Unable to fetch history.',
                    style: TextStyle(
                      fontSize: height * 0.017,
                      color:  Colors.white
                    ),
                  ),
                )
              : provider.records.isEmpty
                  ? const Center(
                      child: Text(
                      "No history available.",
                      style: TextStyle(color: Colors.white),
                    ))
                  : Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColor.newgredient1,
                            const Color.fromARGB(52, 124, 157, 174),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFD8E1E7),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.chevron_left,
                                          color: AppColor.mainTextColor,
                                          size: height * 0.018,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Punch History',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: height * 0.018,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                        size: height * 0.018,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.016,
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                itemCount: provider.records.length,
                                itemBuilder: (context, index) {
                                  final item = provider.records[index];
                                  return _buildPunchCard(
                                      context, item, height, width);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildPunchCard(BuildContext context, PunchHistoryModel item,
      double height, double width) {
    final date = item.date;
    final weekday = _getWeekday(date.weekday);
    final month = _getMonth(date.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Date & Day
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${date.day.toString().padLeft(2, '0')} $weekday',
                    style: TextStyle(
                      fontSize: height * 0.018,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainTextColor,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: height * 0.014,
                      color: AppColor.mainTextColor2,
                    ),
                  ),
                ],
              ),

              /// Clock-In / Clock-Out
              Row(
                children: [
                  _punchTile(height, "Clock-In", item.inTimeFormatted),
                  SizedBox(width: width * 0.08),
                  _punchTile(height, "Clock-Out", item.outTimeFormatted),
                ],
              ),
            ],
          ),
        ),

        /// Divider
        if (item.punchRecords.isNotEmpty) const SizedBox(height: 14),

        /// Punch Entries
        if (item.punchRecords.isNotEmpty)
          Column(
            children: item.punchRecords.map((entry) {
              final isIn = entry.type == 'IN';
              final bgColor = isIn ? Colors.green.shade50 : Colors.red.shade50;
              final iconColor = isIn ? Colors.green : Colors.red;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isIn ? Icons.login : Icons.logout,
                        size: height * 0.022,
                        color: iconColor,
                      ),
                      SizedBox(width: width * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.time} ${entry.type}',
                              style: TextStyle(
                                fontSize: height * 0.016,
                                fontWeight: FontWeight.w600,
                                color: iconColor,
                              ),
                            ),
                            SizedBox(height: height * 0.005),
                            Text(
                              'Location: ${entry.location}',
                              style: TextStyle(
                                fontSize: height * 0.013,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _punchTile(double height, String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: height * 0.017,
            fontWeight: FontWeight.bold,
            color: AppColor.mainTextColor,
          ),
        ),
        SizedBox(height: height * 0.008),
        Text(
          label,
          style: TextStyle(
            fontSize: height * 0.013,
            color: AppColor.mainTextColor2,
          ),
        ),
      ],
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}
