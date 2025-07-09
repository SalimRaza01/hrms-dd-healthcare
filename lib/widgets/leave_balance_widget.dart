import 'package:flutter/material.dart';
import '../core/api/api.dart';
import '../core/model/models.dart';
import '../core/theme/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LeaveBalanceWidget extends StatefulWidget {
  const LeaveBalanceWidget({super.key});

  @override
  State<LeaveBalanceWidget> createState() => _LeaveBalanceWidgetState();
}

class _LeaveBalanceWidgetState extends State<LeaveBalanceWidget> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: Container(
 padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(30),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12.withOpacity(0.05),
          //     blurRadius: 20,
          //     offset: const Offset(0, 8),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              'Leave Balance',
              style: TextStyle(
                fontSize: height * 0.018,
                fontWeight: FontWeight.w600,
                color: AppColor.mainTextColor,
              ),
            ),
            SizedBox(height: height * 0.02),

            /// Data
            FutureBuilder<LeaveBalance>(
              future: fetchLeaves(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColor.mainTextColor2,
                      size: height * 0.035,
                    ),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(
                  child: Text(
                    'No Data Found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: height * 0.014,
                    ),
                  ),
                );
                } else {
                  final leave = snapshot.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildLeaveTile(height, width, 'Casual',
                          leave.casualLeave, const Color(0xFF27AE60)), // green
                                 SizedBox(width: width * 0.02),
                      buildLeaveTile(height, width, 'Medical',
                          leave.medicalLeave, const Color(0xFF2D9CDB)), // blue
                                  SizedBox(width: width * 0.02),
                      buildLeaveTile(height, width, 'Earned',
                          leave.earnedLeave, const Color(0xFFF2C94C)), // yellow
                             SizedBox(width: width * 0.02),
                                        buildLeaveTile(height, width, 'Comp-Off',
                          leave.compOffLeave, const Color.fromARGB(255, 242, 90, 76)), // redAcent
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLeaveTile(double height, double width, String title,
      String count, Color indicatorColor) {
    return Expanded(
      child: Container(
      
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.newgredient2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: indicatorColor.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Count
            Text(
              count,
              style: TextStyle(
                fontSize: height * 0.024,
                fontWeight: FontWeight.bold,
                color: indicatorColor,
              ),
            ),
            const SizedBox(height: 6),

            /// Label
            Text(
              title,
              style: TextStyle(
                fontSize: height * 0.015,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
