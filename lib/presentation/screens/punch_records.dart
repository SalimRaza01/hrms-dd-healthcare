import 'dart:math';
import 'package:flutter/services.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PunchRecordScreen extends StatefulWidget {
  final String? punchRecords;
  final String? regularizationDate;
  final int lateMinutes;

  PunchRecordScreen({
    required this.punchRecords,
    required this.regularizationDate,
    required this.lateMinutes,
  });

  @override
  State<PunchRecordScreen> createState() => _PunchRecordScreenState();
}

class _PunchRecordScreenState extends State<PunchRecordScreen> {
  final Box _authBox = Hive.box('authBox');
  TextEditingController reasonController = TextEditingController();
  String? maxRegularization;
  DateTime? date;
  String _selectedText = 'Regularization';
  Color? activeColor;
  Color? activeText;

  @override
  void initState() {
    super.initState();
    date = DateTime.parse(widget.regularizationDate!);
    checkEmployeeId();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> checkEmployeeId() async {
    var box = await Hive.openBox('authBox');
    setState(() {
      maxRegularization = box.get('maxRegularization');
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    List<String> punches =
        (widget.punchRecords?.split(',') ?? []).toSet().toList();
    // ..sort();

    return Scaffold(
      backgroundColor: AppColor.mainBGColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Records',
          style: TextStyle(
            fontSize: height * 0.02,
            fontWeight: FontWeight.w500,
            color: AppColor.mainTextColor,
          ),
        ),
        backgroundColor: AppColor.mainBGColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: date!
                      .isAfter(DateTime.now().subtract(Duration(days: 8))) &&
                  date!.isBefore(DateTime.now().subtract(Duration(days: 1))),
              child: Column(
                children: [
                  Card(
                    color: AppColor.mainFGColor,
                    elevation: 4,
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _selectButton('Regularization', height, width),
                            _selectButton('Comp-Off', height, width),
                          ]),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Card(
                    color: AppColor.mainFGColor,
                    elevation: 4,
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: SizedBox(
                          height: height * 0.12,
                          width: width,
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.top,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            expands: true,
                            controller: reasonController,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            decoration: InputDecoration(
                              filled: false,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              label: Text('Describe Reason'),
                            ),
                          )),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Visibility(
                    visible: _selectedText == 'Regularization',
                    child: Center(
                      child: Text(
                        'Regularization Limit - $maxRegularization',
                        style: TextStyle(
                          fontSize: height * 0.015,
                          fontWeight: FontWeight.w400,
                          color: AppColor.mainTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  InkWell(
                    onTap: () async {
                      if (reasonController.text.isEmpty) {
                        showSnackBar('Please describe the reason');
                      } else if (_selectedText == 'Regularization') {
                        if (widget.lateMinutes > 1 &&
                            widget.lateMinutes <= 10) {
                          await applyRegularize(
                            context,
                            widget.regularizationDate!,
                            reasonController.text,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Regularization can only be applied if late before ${_authBox.get('lateby') == '9:00' ? '09:30 AM' : _authBox.get('lateby') == '10:00' ? '10:30 AM' : _authBox.get('lateby') == '8:30' ? '09:00 AM' : ''}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else if (_selectedText == 'Comp-Off') {
                        await applyCompoff(
                          context,
                          widget.regularizationDate!,
                          reasonController.text,
                        );
                      }
                    },
                    child: Center(
                      child: Container(
                        width: width / 2,
                        decoration: BoxDecoration(
                          color: AppColor.mainThemeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Center(
                            child: Text(
                              'SUBMIT',
                              style: TextStyle(
                                  color: AppColor.mainFGColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.03),
            Text(
              'Punch Records',
              style: TextStyle(
                fontSize: height * 0.018,
                fontWeight: FontWeight.w500,
                color: AppColor.mainTextColor,
              ),
            ),
            SizedBox(height: height * 0.016),
            Expanded(
              child: ListView.separated(
                itemCount: punches.length ~/ 2,
                itemBuilder: (context, index) {
                  String punchIn = punches[index * 2];
                  String punchOut = punches[index * 2 + 1];

                  String punchInTime =
                      punchIn.substring(0, min(5, punchIn.length));
                  String punchOutTime =
                      punchOut.substring(0, min(5, punchOut.length));

                  return Card(
                    color: AppColor.mainFGColor,
                    elevation: 4,
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Clock In',
                                  style: TextStyle(
                                    fontSize: height * 0.014,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                                SizedBox(height: height * 0.005),
                                Text(
                                  punchInTime.isNotEmpty
                                      ? punchInTime
                                      : '--/--',
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Clock Out',
                                  style: TextStyle(
                                    fontSize: height * 0.014,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                                SizedBox(height: height * 0.005),
                                Text(
                                  punchOutTime != '23:59'
                                      ? punchOutTime
                                      : '--/--',
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _selectButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedText == text) {
      activeColor = AppColor.mainThemeColor;
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = Colors.black87;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 9, vertical: 6),
          child: Text(
            text,
            style: TextStyle(
              color: activeText,
              fontSize: height * 0.015,
            ),
          ),
        ),
      ),
    );
  }
}
