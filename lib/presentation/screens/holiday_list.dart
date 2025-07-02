import 'package:flutter/services.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import '../../core/theme/app_colors.dart';
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

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.newgredient1,
              const Color.fromARGB(52, 124, 157, 174),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD8E1E7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.chevron_left,
                            color: AppColor.mainTextColor,
                            size: height * 0.018,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Holiday List',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: height * 0.018,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<HolidayModel>>(
                  future: holidayList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColor.mainTextColor2,
                          size: height * 0.03,
                        ),
                      );
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No holiday records available.',
                          style: TextStyle(
                            fontSize: height * 0.017,
                            color: AppColor.mainTextColor,
                          ),
                        ),
                      );
                    } else {
                      List<HolidayModel> items = snapshot.data!;

                      return ListView.separated(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final newDate = DateTime.parse(item.holidayDate);

                          return Card(
                            color: AppColor.mainFGColor,
                            elevation: 0,
                            margin: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(38),
                            ),
                            shadowColor: AppColor.shadowColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: width * 0.14,
                                    height: height * 0.072,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8CD193),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            DateFormat('dd').format(newDate),
                                            style: TextStyle(
                                              fontSize: height * 0.02,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('EEE').format(newDate),
                                            style: TextStyle(
                                              fontSize: height * 0.014,
                                              color: const Color.fromARGB(
                                                  255, 58, 58, 58),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: width * 0.05),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: width * 0.6,
                                        child: Text(
                                          item.holidayName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: height * 0.017,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.mainTextColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: height * 0.005),
                                      Text(
                                        DateFormat('MMMM').format(newDate),
                                        style: TextStyle(
                                          fontSize: height * 0.013,
                                          color: AppColor.mainTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) =>
                            SizedBox(height: height * 0.01),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
