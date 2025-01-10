import 'package:flutter/services.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
     SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
          backgroundColor: AppColor.mainBGColor,
          appBar: AppBar(
    backgroundColor: AppColor.mainThemeColor,
    leading: InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Icon(
        Icons.arrow_back_ios,
        color: AppColor.mainFGColor,
      ),
    ),
    title: Text(
      'Notification',
      style: TextStyle(color: AppColor.mainFGColor),
    ),
    centerTitle: true,
          ),
          body: Container(
    height: height,
    width: width,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Card(
            color: AppColor.mainFGColor,
            elevation: 4,
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.black.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
               Image.asset('assets/image/notification.png', height: height * 0.05,),
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave Approval',
                        style: TextStyle(
                            fontSize: height * 0.017,
                            fontWeight: FontWeight.w400,
                            color: AppColor.mainTextColor2),
                      ),
                        SizedBox(
                        width: width / 1.4,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          'Your leave is approved by Nadeem Akhtar',
                          style: TextStyle(
                              fontSize: height * 0.013,
                              color: AppColor.mainTextColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: height * 0.01,),Card(
            color: AppColor.mainFGColor,
            elevation: 4,
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.black.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/image/notification.png', height: height * 0.05,),
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change in Diwali Holiday Dates',
                        style: TextStyle(
                            fontSize: height * 0.017,
                            fontWeight: FontWeight.w400,
                            color: AppColor.mainTextColor2),
                      ),
                      SizedBox(
                        width: width / 1.4,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          'Date will now be Thursday, 31st October 2024 & Friday, 1st November 2024',
                          style: TextStyle(
                              fontSize: height * 0.013,
                              color: AppColor.mainTextColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
          ),
        );
  }
}
