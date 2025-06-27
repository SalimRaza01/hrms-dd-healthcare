// import 'package:flutter/material.dart';
// import 'package:hrms/core/model/models.dart';
// import 'package:hrms/core/provider/provider.dart';
// import 'package:provider/provider.dart';
// import 'package:hrms/core/theme/app_colors.dart';

// class PunchHistoryScreen extends StatefulWidget {
//   const PunchHistoryScreen({super.key});

//   @override
//   State<PunchHistoryScreen> createState() => _PunchHistoryScreenState();
// }

// class _PunchHistoryScreenState extends State<PunchHistoryScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Provider.of<PunchHistoryProvider>(context, listen: false).fetchHistory();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<PunchHistoryProvider>(context);
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: AppColor.mainBGColor,
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error != null
//               ? Center(child: Text(provider.error!))
//               : provider.records.isEmpty
//                   ? const Center(child: Text("No history available."))
//                   : RefreshIndicator(
//                       onRefresh: () async {
//                         await provider.fetchHistory();
//                       },
//                       child: ListView.builder(
//                         itemCount: provider.records.length,
//                         padding: const EdgeInsets.all(10),
//                         itemBuilder: (context, index) {
//                           final item = provider.records[index];
//                           return _buildPunchCard(context, item, height, width);
//                         },
//                       ),
//                     ),
//     );
//   }

//   Widget _buildPunchCard(BuildContext context, PunchHistoryModel item,
//       double height, double width) {
//     final date = item.date;
//     final weekday = _getWeekday(date.weekday);
//     final month = _getMonth(date.month);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Date & Weekday
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${date.day.toString().padLeft(2, '0')} $weekday',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: height * 0.018,
//                         color: AppColor.mainTextColor,
//                       ),
//                     ),
//                     Text(
//                       month,
//                       style: TextStyle(
//                         fontSize: height * 0.014,
//                         color: AppColor.mainTextColor2,
//                       ),
//                     ),
//                   ],
//                 ),
//                 // Clock-In & Clock-Out
//                 Row(
//                   children: [
//                     _punchTile(height, "Clock-In", item.inTimeFormatted),
//                     SizedBox(width: width * 0.08),
//                     _punchTile(height, "Clock-Out", item.outTimeFormatted),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Punch entries vertically
//           if (item.punchRecords.isNotEmpty) ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: item.punchRecords.map((entry) {
//                   return Container(
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: entry.type == 'IN'
//                           ? Colors.green.shade50
//                           : Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: entry.type == 'IN' ? Colors.green : Colors.red,
//                         width: 0.8,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           entry.type == 'IN' ? Icons.login : Icons.logout,
//                           size: 18,
//                           color: entry.type == 'IN' ? Colors.green : Colors.red,
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           '${entry.time} ${entry.type}',
//                           style: TextStyle(
//                             fontSize: height * 0.015,
//                             fontWeight: FontWeight.w500,
//                             color: entry.type == 'IN'
//                                 ? Colors.green.shade800
//                                 : Colors.red.shade800,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],

//           // Location strip
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.blueGrey,
//               borderRadius: const BorderRadius.vertical(
//                 bottom: Radius.circular(12),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 "Location : ${item.location}",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: height * 0.014,
//                   color: AppColor.mainFGColor,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _punchTile(double height, String label, String time) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(
//           time,
//           style: TextStyle(
//             fontSize: height * 0.017,
//             fontWeight: FontWeight.bold,
//             color: AppColor.mainTextColor,
//           ),
//         ),
//         SizedBox(height: height * 0.01),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: height * 0.013,
//             color: AppColor.mainTextColor2,
//           ),
//         ),
//       ],
//     );
//   }

//   String _getWeekday(int weekday) {
//     const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return weekdays[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'JAN',
//       'FEB',
//       'MAR',
//       'APR',
//       'MAY',
//       'JUN',
//       'JUL',
//       'AUG',
//       'SEP',
//       'OCT',
//       'NOV',
//       'DEC'
//     ];
//     return months[month - 1];
//   }
// }


import 'package:flutter/material.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:hrms/core/theme/app_colors.dart';

class PunchHistoryScreen extends StatefulWidget {
  const PunchHistoryScreen({super.key});

  @override
  State<PunchHistoryScreen> createState() => _PunchHistoryScreenState();
}

class _PunchHistoryScreenState extends State<PunchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PunchHistoryProvider>(context, listen: false).fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PunchHistoryProvider>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.records.isEmpty
                  ? const Center(child: Text("No history available."))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await provider.fetchHistory();
                      },
                      child: ListView.builder(
                        itemCount: provider.records.length,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (context, index) {
                          final item = provider.records[index];
                          return _buildPunchCard(context, item, height, width);
                        },
                      ),
                    ),
    );
  }

  Widget _buildPunchCard(
      BuildContext context, PunchHistoryModel item, double height, double width) {
    final date = item.date;
    final weekday = _getWeekday(date.weekday);
    final month = _getMonth(date.month);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section with date and clock-in/out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date & Weekday
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day.toString().padLeft(2, '0')} $weekday',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: height * 0.018,
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
                // Clock-In & Clock-Out
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

          if (item.punchRecords.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.punchRecords.map((entry) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: entry.type == 'IN' ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              entry.type == 'IN' ? Icons.login : Icons.logout,
                              size: height * 0.02,
                              color: entry.type == 'IN' ? Colors.green : Colors.red,
                            ),
                             SizedBox(width: width * 0.02),
                            Text(
                              '${entry.time} ${entry.type}',
                              style: TextStyle(
                                fontSize: height * 0.015,
                                fontWeight: FontWeight.w600,
                                color: entry.type == 'IN'
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                         SizedBox(height: height * 0.01),
                        Text(
                          'Location : ${entry.location}',
                          style: TextStyle(
                            fontSize: height * 0.013,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
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
        SizedBox(height: height * 0.01),
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
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }
}
