import 'package:flutter/services.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<LeaveRequests>> _teamLeaveRequest;

  @override
  void initState() {
    super.initState();
    _teamLeaveRequest = fetchLeaveRequest('Pending');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

    @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
            child: Expanded(
                child: FutureBuilder<List<LeaveRequests>>(
                    future: _teamLeaveRequest,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.threeArchedCircle(
                            color: AppColor.mainTextColor2,
                            size: height * 0.03,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Card(
                            color: AppColor.mainFGColor,
                            elevation: 4,
                            margin: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('No Leave Request Found'),
                            ),
                            shadowColor: AppColor.shadowColor,
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Center(child: Text('No Leave Request Found'));
                      } else {
                        List<LeaveRequests> items = snapshot.data!;
            
                        return ListView.separated(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final leave = items[index];
                            final startDate =
                                DateTime.parse(leave.leaveStartDate);
                            final endDate =
                                DateTime.parse(leave.leaveEndDate);
                            print(leave.location);
                            return Card(
                              color: AppColor.mainFGColor,
                              elevation: 8,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: AppColor.shadowColor,
                              child: Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          leave.employeeName,
                                          style: TextStyle(
                                            fontSize: height * 0.015,
                                            color: AppColor
                                                .mainTextColor,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          leave.totalDays == '1' ||
                                                  leave.totalDays ==
                                                      '0.5'
                                              ? DateFormat(
                                                      'EEE, dd MMM')
                                                  .format(startDate)
                                              : '${DateFormat('EEE, dd MMM').format(startDate)} - ${DateFormat('EEE, dd MMM').format(endDate)}',
                                          style: TextStyle(
                                            fontSize: height * 0.012,
                                            // fontWeight:
                                            //     FontWeight.bold,
                                            color: AppColor
                                                .mainTextColor,
                                          ),
                                        ),
                                        SizedBox(height: height * 0.008),
                                        Container(
                                          width: width,
                                          decoration: BoxDecoration(
                                            color: AppColor.mainBGColor,
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.black12,
                                            //     blurRadius: 4,
                                            //     offset: Offset(0, 2),
                                            //   ),
                                            // ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              leave.reason,
                                              style: TextStyle(
                                                fontSize: height * 0.014,
                                                color: AppColor.mainTextColor2,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              // Accept Button
                                              GestureDetector(
                                                onTap: () async {
                                                  print(leave.id);
                                                  await leaveAction(context,
                                                      'Approved', leave.id);
                                                  setState(() {
                                                    _teamLeaveRequest =
                                                        fetchLeaveRequest(
                                                            'Pending');
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color:
                                                        const Color.fromARGB(
                                                            126, 20, 183, 25),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width / 9,
                                                            vertical: 7),
                                                    child: Text(
                                                      'Accept',
                                                      style: TextStyle(
                                                        color: AppColor
                                                            .mainTextColor,
                                                        fontSize:
                                                            height * 0.012,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      
                                              GestureDetector(
                                                onTap: () async {
                                                  await leaveAction(context,
                                                      'Rejected', leave.id);
                                                  setState(() {
                                                    _teamLeaveRequest =
                                                        fetchLeaveRequest(
                                                            'Pending');
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                      color: AppColor
                                                          .mainBGColor),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width / 9,
                                                            vertical: 7),
                                                    child: Text(
                                                      'Decline',
                                                      style: TextStyle(
                                                        color: AppColor
                                                            .mainTextColor,
                                                        fontSize:
                                                            height * 0.012,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: height * 0.005),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColor.mainThemeColor,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          leave.leaveType,
                                          style: TextStyle(
                                              fontSize: height * 0.012,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.mainFGColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10),
                        );
                      }
                    })),
          ),
        ),
      ),
    );
  }
}
