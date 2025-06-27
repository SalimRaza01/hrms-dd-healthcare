import 'package:flutter/material.dart';
import 'package:hrms/core/provider/provider.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' show Consumer, Provider;

class PunchCardWidget extends StatefulWidget {
  const PunchCardWidget({super.key});

  @override
  State<PunchCardWidget> createState() => _PunchCardWidgetState();
}

class _PunchCardWidgetState extends State<PunchCardWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<PunchedIN>(context, listen: false).fetchAndSetPunchRecord();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Consumer<PunchedIN>(
      builder: (context, punchProvider, _) {
        final record = punchProvider.record;

        if (record == null) {
          return EmptyWidget(height: height, width: width);
        }

        final now = DateTime.now();
        final times = record.getLastPunchTimes();
        final lastLocation = record.getLastLocation();

        if (!DateUtils.isSameDay(now, record.createdAt)) {
          return EmptyWidget(height: height, width: width);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
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
                offset: const Offset(2, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                'Last Updated - ${DateFormat('hh:mm - dd-MM-yyyy').format(DateTime.parse(record.outTime))}',
                style: TextStyle(
                  fontSize: height * 0.014,
                  color: AppColor.mainFGColor,
                ),
              ),
              SizedBox(height: height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Punch in',
                          style: TextStyle(
                              fontSize: height * 0.015,
                              color: AppColor.mainFGColor)),
                      Text('${times['lastIn']}',
                          style: TextStyle(
                            fontSize: height * 0.020,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainFGColor,
                          )),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Punch out',
                          style: TextStyle(
                              fontSize: height * 0.015,
                              color: AppColor.mainFGColor)),
                      Text('${times['lastOut']}',
                          style: TextStyle(
                            fontSize: height * 0.020,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainFGColor,
                          )),
                    ],
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: height * 0.015, color: AppColor.mainFGColor),
                  SizedBox(width: width * 0.02),
                  Expanded(
                    child: Text(lastLocation.replaceFirst('(OUT)', '').trim(),
                        style: TextStyle(
                            fontSize: height * 0.015,
                            color: AppColor.mainFGColor)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
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
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Punch In
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Punch in',
                    style: TextStyle(
                        fontSize: height * 0.015, color: AppColor.mainFGColor),
                  ),
                  Text(
                    '--/--',
                    style: TextStyle(
                      fontSize: height * 0.020,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainFGColor,
                    ),
                  ),
                ],
              ),
              // Punch Out
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Punch out',
                    style: TextStyle(
                        fontSize: height * 0.015, color: AppColor.mainFGColor),
                  ),
                  Text(
                    '--/--',
                    style: TextStyle(
                      fontSize: height * 0.020,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainFGColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: height * 0.02),
          Row(
            children: [
              Icon(Icons.location_on,
                  size: height * 0.015, color: AppColor.mainFGColor),
              SizedBox(width: width * 0.02),
              Expanded(
                child: Text(
                  'Not Fetched',
                  style: TextStyle(
                      fontSize: height * 0.015, color: AppColor.mainFGColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
