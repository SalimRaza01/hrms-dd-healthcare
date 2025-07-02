import 'package:flutter/material.dart';
import '../core/provider/provider.dart';
import '../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PunchCardWidget extends StatefulWidget {
  const PunchCardWidget({super.key});

  @override
  State<PunchCardWidget> createState() => _PunchCardWidgetState();
}

class _PunchCardWidgetState extends State<PunchCardWidget> {
  @override
  void initState() {
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

        if (record == null ||
            !DateUtils.isSameDay(DateTime.now(), record.createdAt)) {
          return EmptyWidget(height: height, width: width);
        }

        final times = record.getLastPunchTimes();
        final lastLocation = record.getLastLocation();

        return Container(
          width: double.infinity,
           padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last updated
              Text(
                'Last Updated - ${DateFormat('hh:mm a · dd MMM yyyy').format(DateTime.parse(record.outTime))}',
                style: TextStyle(
                  fontSize: height * 0.014,
                  color: Colors.blueGrey,
                ),
              ),
        
             
        
              SizedBox(height: height * 0.016),
        
              // Location
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: Colors.deepPurple, size: height * 0.020),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lastLocation.replaceAll(RegExp(r'\(.*?\)'), '').trim(),
                      style: TextStyle(
                        fontSize: height * 0.015,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
               SizedBox(height: height * 0.016),
        
              // Punch times
              Container(
                decoration: BoxDecoration(
                  color: AppColor.newgredient2,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _punchTimeBlock(
                          height, 'Punch in', times['lastIn']!, Colors.green),
                      _punchTimeBlock(
                          height, 'Punch out', times['lastOut']!, Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _punchTimeBlock(
      double height, String title, String value, Color accentColor) {
    return Column(
      crossAxisAlignment: title == 'Punch in'
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: height * 0.014,
            color: Colors.black.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: height * 0.004),
        Text(
          value,
          style: TextStyle(
            fontSize: height * 0.021,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
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
   padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Location
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: Colors.deepPurple, size: height * 0.020),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location Not Fetched',
                      style: TextStyle(
                        fontSize: height * 0.015,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
               SizedBox(height: height * 0.016),

              // Punch times
              Container(
                decoration: BoxDecoration(
                  color: AppColor.newgredient2,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _emptyPunchTile(
                          height, 'Punch in', ),
                      _emptyPunchTile(
                          height, 'Punch out', ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Widget _emptyPunchTile(double height, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: height * 0.015,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '--/--',
          style: TextStyle(
            fontSize: height * 0.020,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
          ),
        ),
      ],
    );
  }
}
