import 'dart:math';
import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PunchRecordScreen extends StatefulWidget {
  final String? punchRecords;
  final String? regularizationDate;

  PunchRecordScreen(
      {required this.punchRecords, required this.regularizationDate});

  @override
  State<PunchRecordScreen> createState() => _PunchRecordScreenState();
}

class _PunchRecordScreenState extends State<PunchRecordScreen> {
  TextEditingController reasonController = TextEditingController();
  String? maxRegularization;

  @override
  void initState() {
    super.initState();
    checkEmployeeId();
  }

  Future<void> checkEmployeeId() async {
    var box = await Hive.openBox('authBox');
    setState(() {
      maxRegularization = box.get('maxRegularization');
    });

    print('Stored maxRegularization Count: $maxRegularization');
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
          'Apply Regularization',
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
            Card(
              color: Colors.white,
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
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        label: Text('Describe Reason'),
                      ),
                    )),
              ),
            ),
            SizedBox(height: height * 0.03),
            Center(
              child: Text(
                'Regularization Limit - $maxRegularization',
                style: TextStyle(
                  fontSize: height * 0.015,
                  fontWeight: FontWeight.w400,
                  color: AppColor.mainTextColor,
                ),
              ),
            ),
            SizedBox(height: height * 0.01),
            InkWell(
              onTap: () async {
                if (reasonController.text.isNotEmpty) {
                  print('sign in button');
                  await applyRegularize(context, widget.regularizationDate!,
                      reasonController.text);
                } else {
                  // setState(() {
                  //   showError = true;
                  // });
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
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
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
                    color: Colors.white,
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
                                  punchOutTime.isNotEmpty
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
}
