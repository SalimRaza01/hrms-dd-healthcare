import 'package:flutter/material.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/model/models.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:hrms/presentation/screens/holiday_list.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HolidayWidget extends StatefulWidget {
  const HolidayWidget({super.key});

  @override
  State<HolidayWidget> createState() => _HolidayWidgetState();
}

class _HolidayWidgetState extends State<HolidayWidget> {
 late Future<List<HolidayModel>> holidayList;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
        holidayList = fetchHolidayList('HomeScreen');
  }


  @override
  Widget build(BuildContext context) {
             final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upcoming Holiday',
                            style: TextStyle(
                                fontSize: height * 0.015,
                                color: AppColor.mainTextColor,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          FutureBuilder<List<HolidayModel>>(
                            future: holidayList,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: LoadingAnimationWidget
                                        .threeArchedCircle(
                                  color: AppColor.mainTextColor2,
                                  size: height * 0.03,
                                ));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('No Holiday List Found'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                    child: Text('No Holiday available.'));
                              } else {
                                List<HolidayModel> items = snapshot.data!;

                                HolidayModel item = items[0];

                                final newDate =
                                    DateTime.parse(item.holidayDate);

                                return InkWell(
                                  onTap: () => showCupertinoModalBottomSheet(
                                    expand: true,
                                    context: context,
                                    barrierColor: AppColor.barrierColor,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => HolidayList(),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color:
                                                    AppColor.mainThemeColor,
                                                borderRadius:
                                                    BorderRadius.all(
                                                  Radius.circular(10),
                                                )),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 4,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    DateFormat('dd')
                                                        .format(newDate)
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: height * 0.02,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColor
                                                          .mainFGColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('EEE')
                                                        .format(newDate)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize:
                                                            height * 0.014,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor
                                                            .mainFGColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: width / 2,
                                                  child: Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    item.holidayName,
                                                    style: TextStyle(
                                                        fontSize:
                                                            height * 0.015,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColor
                                                            .mainTextColor),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: height * 0.005,
                                                ),
                                                Text(
                                                  DateFormat('MMMM')
                                                      .format(newDate)
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize:
                                                          height * 0.014,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColor
                                                          .mainTextColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppColor.mainTextColor,
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  );
  }
  }
