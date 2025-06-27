
import 'package:flutter/material.dart';
import 'package:hrms/core/theme/app_colors.dart';

class NoTaskWidget extends StatelessWidget {
  const NoTaskWidget({
    super.key,

  });



  @override
  Widget build(BuildContext context) {
     final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                'Today Task',
                style: TextStyle(
                    fontSize: height * 0.015,
                    color: AppColor.mainTextColor,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: height * 0.005,
              ),
              Text(
                'The tasks assigned to you for today',
                style: TextStyle(
                  fontSize: height * 0.012,
                  color: AppColor.mainTextColor2,
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        'assets/image/Frame.png',
                        height: height * 0.08,
                      )),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Center(
                child: Text(
                  'No Tasks Assigned',
                  style: TextStyle(
                      fontSize: height * 0.015,
                      color: AppColor.mainTextColor,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Text(
                'It looks like you don’t have any tasks assigned to you right now. Don’t worry, this space will be updated as new tasks become available.',
                style: TextStyle(
                  fontSize: height * 0.012,
                  color: AppColor.mainTextColor2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}