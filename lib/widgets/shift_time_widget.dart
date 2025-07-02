import 'package:flutter/material.dart';
import '../core/api/api.dart';
import '../core/model/models.dart';
import '../core/theme/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ShiftTImeWidget extends StatelessWidget {
  const ShiftTImeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder<ShiftTimeModel>(
      future: fetchShiftTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColor.appsubtext,
              size: height * 0.035,
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
                  child: Text(
                    'No Data Found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: height * 0.014,
                    ),
                  ),
                ),
          );
        } else {
          final shift = snapshot.data!;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shift Time',
                  style: TextStyle(
                    fontSize: height * 0.016,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${shift.startTime} AM',
                      style: TextStyle(
                        fontSize: height * 0.016,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '-',
                      style: TextStyle(
                        fontSize: height * 0.016,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${shift.endTime} PM',
                      style: TextStyle(
                        fontSize: height * 0.016,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
