import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
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
                    child: Card(
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
                              'Leave Balance',
                              style: TextStyle(
                                  fontSize: height * 0.015,
                                  color: AppColor.mainTextColor,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: height * 0.01,
                            ),
                            FutureBuilder<LeaveBalance>(
                                future: fetchLeaves(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: LoadingAnimationWidget
                                          .threeArchedCircle(
                                        color: AppColor.mainTextColor2,
                                        size: height * 0.03,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text('No Data Found'));
                                  } else if (snapshot.hasData) {
                                    final leave = snapshot.data!;

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        leaveWidget(height, width, 'Casual',
                                            leave.casualLeave),
                                        leaveWidget(height, width, 'Medical',
                                            leave.medicalLeave),
                                        leaveWidget(height, width, 'Earned',
                                            leave.earnedLeave),
                                      ],
                                    );
                                  } else {
                                    return Text('No data Found');
                                  }
                                }),
                          ],
                        ),
                      ),
                    ),
                  );
  }


  SizedBox leaveWidget(
      double height, double width, String leave, String leaveCount) {
    return SizedBox(
      width: width * 0.27,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColor.borderColor),
            color: AppColor.mainBGColor,
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            children: [
              Text(
                leave,
                style: TextStyle(color: AppColor.mainTextColor2),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                leaveCount,
                style: TextStyle(
                    color: AppColor.mainTextColor2, fontSize: height * 0.022),
              ),
            ],
          ),
        ),
      ),
    );
  }
}