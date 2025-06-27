import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ShiftTImeWidget extends StatelessWidget {
  const ShiftTImeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder<ShiftTimeModel>(
        future: fetchShiftTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: AppColor.mainTextColor2,
                size: height * 0.03,
              ),
            );
          } else if (snapshot.hasError) {
            return Card(
              color: AppColor.mainFGColor,
              elevation: 4,
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: AppColor.shadowColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  'No Data Found',
                  style: TextStyle(color: AppColor.mainTextColor2),
                )),
              ),
            );
          } else if (snapshot.hasData) {
            final shift = snapshot.data!;

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shift Time',
                        style: TextStyle(
                            fontSize: height * 0.015,
                            color: AppColor.mainTextColor,
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Text(
                            '${shift.startTime} AM ',
                            style: TextStyle(
                                fontSize: height * 0.015,
                                color: AppColor.mainTextColor),
                          ),
                          Text(
                            '- ',
                            style: TextStyle(
                                fontSize: height * 0.015,
                                color: AppColor.mainTextColor),
                          ),
                          Text(
                            '${shift.endTime} PM',
                            style: TextStyle(
                                fontSize: height * 0.015,
                                color: AppColor.mainTextColor),
                          ),
                        ],
                      )
                    ],
                  ),
                ));
          } else {
            return Text('No data Found');
          }
        });
  }
}
