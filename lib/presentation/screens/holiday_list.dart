import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/model/models.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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

    holidayList = fetchHolidayList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No HolidayModel records available.'));
                  } else {
                    List<HolidayModel> items = snapshot.data!;
                      
                    return ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        HolidayModel item = items[index];
                      
                        print(item.holidayDate
                            .replaceAll(' ', '')
                            .substring(0, 2));
                      
                        return Card(
                          color: Colors.white,
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
                                        item.holidayDate
                                            .replaceAll(' ', '')
                                            .substring(0, 2),
                                        style: TextStyle(
                                          fontSize: height * 0.025,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        item.holidayDate
                                            .replaceAll(' ', '')
                                            .substring(2, 5),
                                        style: TextStyle(
                                          fontSize: height * 0.014,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.holidayName.replaceAll(
                                          new RegExp(r"[0-9]+"), ""),
                                      style: TextStyle(
                                          fontSize: height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.mainTextColor),
                                    ),
                                    SizedBox(
                                      height: height * 0.005,
                                    ),
                                    Text(
                                      item.holidayDescription.replaceAll(
                                          new RegExp(r"[0-9]+"), ""),
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
                          height: 10,
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
