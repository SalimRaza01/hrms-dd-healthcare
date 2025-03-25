import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({super.key});
  @override
  State<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {
  late Future<List<HolidayModel>> holidayList;

  @override
  void initState() {
    super.initState();


 SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    holidayList = fetchHolidayList('MainScreen');
  }
@override
void dispose() {
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      backgroundColor: AppColor.mainBGColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
             SizedBox(
              height: height * 0.01,
            ),
            Text(
              "Holiday List",
              style: TextStyle(
                  fontSize: height * 0.02,
                  color: AppColor.mainTextColor,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Expanded(
              child: FutureBuilder<List<HolidayModel>>(
                future: holidayList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                                        child: LoadingAnimationWidget
                                            .threeArchedCircle(
                                          color: AppColor.mainTextColor2,
                                          size: height * 0.03,
                                        ),
                                      );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('No HolidayModel records available.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No HolidayModel records available.'));
                  } else {
                    List<HolidayModel> items = snapshot.data!;
                      
                    return ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        HolidayModel item = items[index];
                      
    final newDate = DateTime.parse(item.holidayDate);

                      
                        return Card(
                          color: AppColor.mainFGColor,
                          elevation: 4,
                          margin: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: AppColor.mainThemeColor,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        bottomLeft: Radius.circular(15))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                     Text(
                                                   DateFormat('dd').format(newDate).toString(),
                                                      style: TextStyle(
                                                        fontSize: height * 0.02,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor.mainFGColor,
                                                      ),
                                                    ),
                                                    Text(
                                                            DateFormat('EEE').format(newDate).toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.014,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColor.mainFGColor),
                                                    ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: width / 1.6,
                                      child: Text(
                                                                    overflow: TextOverflow.ellipsis,
                                        item.holidayName,
                                        style: TextStyle(
                                          
                                            fontSize: height * 0.018,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.mainTextColor),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.005,
                                    ),
                                    Text(
                                       DateFormat('MMMM').format(newDate).toString(),
                                      style: TextStyle(
                                          fontSize: height * 0.014,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.mainTextColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: height * 0.01,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
