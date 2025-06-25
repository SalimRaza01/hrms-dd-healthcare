import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hrms/core/provider/provider.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class PunchCardWidget extends StatefulWidget {
  const PunchCardWidget({super.key});

  @override
  State<PunchCardWidget> createState() => _PunchCardWidgetState();
}

class _PunchCardWidgetState extends State<PunchCardWidget> {
  final Box _authBox = Hive.box('authBox');


  String displayInTime() {
    DateTime inTime = DateTime.parse(_authBox.get('Punch-InTime'));

    return  "${inTime.hour.toString().padLeft(2, '0')}:${inTime.minute.toString().padLeft(2, '0')}";
  }

  String displayOutTime() {
 

    return "${_authBox.get('Punch-OutTime').hour.toString().padLeft(2, '0')}:${_authBox.get('Punch-OutTime').minute.toString().padLeft(2, '0')}";
       
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Consumer<PunchedIN>(
  builder: (context, punchAction, child) {
    print('updated time ');
    
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
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
                offset: Offset(2, 2),
              )
            ],
          ),
          child: Column(
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT SIDE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Punch in',
                        style: TextStyle(
                            fontSize: height * 0.015, color: AppColor.mainFGColor),
                      ),
                      Text(
                 _authBox.get('Punch-InTime') != null ?  displayInTime() : '--/--',
                        style: TextStyle(
                            fontSize: height * 0.020,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainFGColor),
                      ),
                    ],
                  ),
        
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Punch out',
                        style: TextStyle(
                            fontSize: height * 0.015, color: AppColor.mainFGColor),
                      ),
                      Text(
                  _authBox.get('Punch-OutTime') != null ?  displayOutTime() : '--/--',
                        style: TextStyle(
                            fontSize: height * 0.020,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainFGColor),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: height * 0.015, color: AppColor.mainFGColor),
                  SizedBox(width: width * 0.02),
                  Text(
                    _authBox.get('punchLocation') ?? 'Not Fetched',
                    style: TextStyle(
                        fontSize: height * 0.015, color: AppColor.mainFGColor),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
