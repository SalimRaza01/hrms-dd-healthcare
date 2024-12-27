// ignore_for_file: unused_import

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:database_app/core/api/api.dart';
import 'package:database_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'leave_policy.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({super.key});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> with TickerProviderStateMixin {
  String _selectedText = 'Full Day';
  String? _selectedLeaveType;
  Color? activeColor;
  Color? activeText;
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController selectFromTime = TextEditingController();
  TextEditingController selectToTime = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedendDate = DateTime.now();
  DateTime? fromtime;
  DateTime? toTime;
  String? casualLeave;
  String? earnedLeave;
  String? medicalLeave;
  String? maternityLeave;
  String? paternityLeave;

  List<Leave> leaveList = [];

  Future<void> getleaveBalance() async {
    var box = await Hive.openBox('authBox');

    setState(() {
      casualLeave = box.get('casual');
      medicalLeave = box.get('medical');
      maternityLeave = box.get('maternity');
      earnedLeave = box.get('earned');
      paternityLeave = box.get('paternity');

      leaveList = [
        Leave('Casual Leave', casualLeave!),
        Leave('Medical Leave', medicalLeave!),
        Leave('Earned Leave', earnedLeave!),
        Leave('Maternity Leave', maternityLeave!),
        Leave('Paternity Leave', paternityLeave!),
      ];
    });
  }

  @override
  void initState() {
    getleaveBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
            backgroundColor: AppColor.mainBGColor,
            body: SingleChildScrollView(
              child: SizedBox(
                height: height,
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Apply Leave',
                        style: TextStyle(
                            fontSize: height * 0.02,
                            color: AppColor.mainTextColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomDropdown<Leave>(
                        hintText: 'Select Leave Type',
                        items: leaveList,
                        onChanged: (Leave? value) {
                          setState(() {
                            if (value != null) {
                              _selectedLeaveType = value.name;
                              startDateController.clear();
                              endDateController.clear();
                            }
                          });
                        },
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) {
                          return ListTile(
                            title: Text('${item.name} - ${item.balance}'),
                          );
                        },
                      ),
                      Visibility(
                        visible: _selectedLeaveType != null,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Visibility(
                              visible: _selectedLeaveType == 'Casual Leave' ||
                                  _selectedLeaveType == 'Comp-off Leave',
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                shadowColor: Colors.black.withOpacity(0.1),
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _selectButton(
                                            'Full Day', height, width),
                                        _selectButton(
                                            '1st Half', height, width),
                                        _selectButton(
                                            '2nd Half', height, width),
                                      ]),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _selectedLeaveType == 'Casual Leave', 
                     
                              child: SizedBox(
                                height: 15,
                              ),
                            ),
                            Visibility(
                                visible: _selectedLeaveType == 'Casual Leave',
                    
                                child: startDateLeave(height, width, context)),
                            Visibility(
                                visible: _selectedLeaveType != 'Casual Leave',
                                child: Column(
                                  children: [
                                    startDateLeave(height, width, context),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    endDateLeave(height, width, context)
                                  ],
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            Card(
                              color: Colors.white,
                              elevation: 4,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
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
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
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
                                        label: Text('Describe Leave Reason'),
                                      ),
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Visibility(
                              visible: _selectedLeaveType == 'Medical Leave',
                              child: InkWell(
                                onTap: () async {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.mainThemeColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 10),
                                    child: Text(
                                      "Upload Prescription",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            InkWell(
                              onTap: () async {
                                num? totalDays;
                                print(_selectedLeaveType!);

                                Leave selectedLeave = leaveList.firstWhere(
                                  (leave) => leave.name == _selectedLeaveType,
                                  orElse: () => Leave('Unknown', '0'),
                                );

                                if (_selectedLeaveType!.contains('Casual') ||
                                    _selectedLeaveType!.contains('Comp')) {
                                  if (_selectedText == 'Full Day') {
                                    setState(() {
                                      totalDays = 1;
                                    });
                                  } else if (_selectedText == '1st Half' ||
                                      _selectedText == '2nd Half') {
                                    setState(() {
                                      totalDays = 0.5;
                                    });
                                  } else {
                                    totalDays = 1;
                                  }
                                } else {
                                  totalDays = selectedendDate
                                      .difference(selectedStartDate)
                                      .inDays;
                                }

                                if (selectedLeave.balanceInt < totalDays!) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Not enough leave balance for ${selectedLeave.name}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                DateTime startDate =
                                    DateTime.parse(startDateController.text);
                                DateTime now = DateTime.now();

                                if (startDate.day == now.day && now.hour >= 9) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Leave must be applied before 9 AM for today.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (startDate.isAtSameMomentAs(now)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'leave must be applied for a future date.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (_selectedLeaveType!.contains('Casual') ||
                                    _selectedLeaveType!.contains('Comp')) {
                                  DateTime startDate =
                                      DateTime.parse(startDateController.text);
                                  DateTime now = DateTime.now();

                                  if (startDate.isAtSameMomentAs(now)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'leave must be applied for a future date.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (startDate.day == now.day &&
                                      now.hour >= 9) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'leave must be applied before 9 AM for today.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                }

                                if (_selectedLeaveType!.contains('Medical')) {
                                  DateTime startDate =
                                      DateTime.parse(startDateController.text);
                                  DateTime endDate =
                                      DateTime.parse(endDateController.text);
                                  int medicalLeaveDuration =
                                      endDate.difference(startDate).inDays;

                                  if (startDate.isAfter(DateTime.now())) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Medical leave can only be applied for past days.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (medicalLeaveDuration < 2 ||
                                      medicalLeaveDuration > 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Medical leave must be between 2 to 6 days.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                }
                              },
                              child: Container(
                                width: width / 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColor.primaryThemeColor,
                                        AppColor.secondaryThemeColor2,
                                      ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'SUBMIT',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: () => showCupertinoModalBottomSheet(
                                expand: true,
                                context: context,
                                barrierColor:
                                    const Color.fromARGB(130, 0, 0, 0),
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                builder: (context) => LeavePolicyScreen(),
                              ),
                          child: Text('See Leave Policy'))
                    ],
                  ),
                ),
              ),
            )));
  }

  Card endDateLeave(double height, double width, BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: height * 0.03,
              width: width / 1.2,
              child: TextField(
                textAlign: TextAlign.center,
                readOnly: true,
                controller: endDateController,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.all(0),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Select End Date',
                ),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Container(
                                height: height * 0.22,
                                child: CupertinoTheme(
                                  data: CupertinoThemeData(
                                    brightness: Brightness.light,
                                  ),
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    use24hFormat: false,
                                    minimumDate: DateTime.now(),
                                    onDateTimeChanged: (DateTime newDate) {
                                      selectedendDate = newDate;
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColor.mainBGColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'CANCEL',
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            endDateController.text =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(selectedendDate);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    AppColor.primaryThemeColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'SELECT',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card startDateLeave(double height, double width, BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: height * 0.03,
              width: width / 1.2,
              child: TextField(
                textAlign: TextAlign.center,
                readOnly: true,
                controller: startDateController,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.all(0),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: _selectedLeaveType == 'Casual Leave'
                      ? 'Select Date'
                      : 'Select Start Date',
                ),
                onTap: () {
                  DateTime minDate = DateTime.now();
                  if (_selectedLeaveType == 'Medical Leave') {
                    minDate = DateTime.now().subtract(Duration(days: 6));
                    print(minDate.day);
                  }

                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Container(
                                height: height * 0.22,
                                child: CupertinoTheme(
                                  data: CupertinoThemeData(
                                    brightness: Brightness.light,
                                  ),
                                  child: _selectedLeaveType!.contains('Medical')
                                      ? CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          use24hFormat: false,
                                          minimumDate: _selectedLeaveType!
                                                  .contains('Medical')
                                              ? DateTime.now()
                                                  .subtract(Duration(days: 5))
                                              : DateTime.now(),
                                          onDateTimeChanged:
                                              (DateTime newDate) {
                                            selectedStartDate = newDate;
                                          },
                                        )
                                      : CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          use24hFormat: false,
                                          minimumDate: DateTime.now(),
                                          onDateTimeChanged:
                                              (DateTime newDate) {
                                            selectedStartDate = newDate;
                                          },
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColor.mainBGColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'CANCEL',
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            startDateController.text =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(selectedStartDate);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    AppColor.primaryThemeColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'SELECT',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container forHalfDay(double height, double width, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: height * 0.03,
              width: width / 3,
              child: TextField(
                textAlign: TextAlign.center,
                readOnly: true,
                controller: selectFromTime,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.all(0),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Select Time',
                ),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Container(
                                height: height * 0.22,
                                child: CupertinoTheme(
                                  data: CupertinoThemeData(
                                    brightness: Brightness.light,
                                  ),
                                  child: CupertinoDatePicker(
                                      initialDateTime: DateTime.now(),
                                      mode: CupertinoDatePickerMode.time,
                                      use24hFormat: false,
                                      showDayOfWeek: true,
                                      minimumDate: DateTime.now(),
                                      onDateTimeChanged: (DateTime newDate) {
                                        fromtime = newDate;
                                      }),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColor.mainBGColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'CANCEL',
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectFromTime.text ==
                                                "${fromtime!.hour}:${fromtime!.minute}";
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    AppColor.primaryThemeColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'SELECT',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Text(
              'To',
              style: TextStyle(color: Colors.black87, fontSize: height * 0.016),
            ),
            SizedBox(
              height: height * 0.03,
              width: width / 3,
              child: TextField(
                textAlign: TextAlign.center,
                readOnly: true,
                controller: selectToTime,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.all(0),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Select Time',
                ),
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return Container(
                        height: height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Container(
                                height: height * 0.22,
                                child: CupertinoTheme(
                                  data: CupertinoThemeData(
                                    brightness: Brightness.light,
                                  ),
                                  child: CupertinoDatePicker(
                                      initialDateTime: DateTime.now(),
                                      mode: CupertinoDatePickerMode.time,
                                      use24hFormat: false,
                                      showDayOfWeek: true,
                                      minimumDate: DateTime.now(),
                                      onDateTimeChanged: (DateTime newDate) {
                                        toTime = newDate;
                                      }),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: AppColor.mainBGColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'CANCEL',
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectToTime.text ==
                                                "${toTime!.hour}:${toTime!.minute}";
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    AppColor.primaryThemeColor),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              child: Center(
                                                child: Text(
                                                  'SELECT',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: height * 0.016),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
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
      activeText = Colors.white;
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
          padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 6),
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

class Leave {
  final String name;
  final String balance;

  Leave(this.name, this.balance);

  @override
  String toString() {
    return name;
  }

  num get balanceInt => num.tryParse(balance) ?? 0;
}
