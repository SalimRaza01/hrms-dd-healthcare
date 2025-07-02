import 'package:flutter/material.dart';
import '../core/api/api.dart';
import '../core/model/models.dart';
import '../presentation/screens/holiday_list.dart';
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
    super.initState();
    holidayList = fetchHolidayList('HomeScreen');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // flat white background
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Holiday',
            style: TextStyle(
              fontSize: height * 0.016,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: height * 0.015),
          FutureBuilder<List<HolidayModel>>(
            future: holidayList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: Colors.grey.shade400,
                    size: height * 0.03,
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                  child: Text(
                    'No Data Found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: height * 0.014,
                    ),
                  ),
                );
              } else {
                final item = snapshot.data![0];
                final date = DateTime.parse(item.holidayDate);

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => showCupertinoModalBottomSheet(
                    expand: true,
                    context: context,
                    barrierColor: Colors.black26,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const HolidayList(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Date Box + Holiday Info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF1F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    fontSize: height * 0.014,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: width * 0.5,
                                child: Text(
                                  item.holidayName,
                                  style: TextStyle(
                                    fontSize: height * 0.016,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMMM').format(date),
                                style: TextStyle(
                                  fontSize: height * 0.014,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right: Arrow
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
