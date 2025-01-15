// ignore_for_file: unused_import, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:hrms/core/api/api.dart';
import 'package:hrms/core/api/api_config.dart';
import 'package:hrms/core/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'leave_policy.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({super.key});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> with TickerProviderStateMixin {
  final Box _authBox = Hive.box('authBox');
  String _selectedText = 'Full Day';
  String? _selectedLeaveType;
  Color? activeColor;
  Color? activeText;
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  List<PlatformFile>? _paths;
  bool _isLoading = false;
  String? empID;
  List<Leave> leaveList = [];
  String? casualLeave;
  String? earnedLeave;
  String? medicalLeave;
  String? maternityLeave;
  String? paternityLeave;
  String? shortLeave;

  startDate(
      BuildContext context, String? _selectedLeaveType, String _selectedText) {
    return DatePicker.showDatePicker(context,
        dateFormat: 'dd MMMM yyyy',
        initialDateTime: DateTime.now(),
        minDateTime: _selectedLeaveType!.contains('Medical')
            ? DateTime.now().subtract(Duration(days: 6))
            : DateTime.now(),
        maxDateTime: _selectedLeaveType.contains('Medical')
            ? DateTime.now().subtract(Duration(days: 1))
            : DateTime(3000),
        onMonthChangeStartWithFirstDate: true,
        onConfirm: (dateTime, List<int> index) {
      setState(() {
        DateTime selectdate = dateTime;
        startDateController.clear();
        endDateController.clear();
        startDateController.text = DateFormat('yyyy-MM-dd').format(selectdate);
        print(startDateController.text);
        print(endDateController.text);
      });
    });
  }

  endDate(
      BuildContext context, String? _selectedLeaveType, String _selectedText) {
    return DatePicker.showDatePicker(
      context,
      dateFormat: 'dd MMMM yyyy',
      initialDateTime: DateTime.now(),
      minDateTime: _selectedLeaveType!.contains('Medical')
          ? DateTime.now().subtract(Duration(days: 6))
          : _selectedLeaveType.contains('Earned') ||
                  _selectedLeaveType.contains('Casual')
              ? DateTime.parse(startDateController.text)
              : null,
      maxDateTime: _selectedLeaveType.contains('Medical')
          ? DateTime.now().subtract(Duration(days: 1))
          : _selectedLeaveType.contains('Earned')
              ? DateTime.parse(startDateController.text).add(Duration(days: 6))
              : _selectedLeaveType.contains('Casual')
                  ? DateTime.parse(startDateController.text)
                      .add(Duration(days: 1))
                  : null,
      onMonthChangeStartWithFirstDate: true,
      onConfirm: (dateTime2, List<int> index) {
        setState(() {
          DateTime selectdate2 = dateTime2;
          endDateController.text = DateFormat('yyyy-MM-dd').format(selectdate2);
          print(startDateController.text);
          print(endDateController.text);
        });
      },
    );
  }

  void validation()  async {
    num? totalDays;

    Leave selectedLeave = leaveList.firstWhere(
      (leave) => leave.name == _selectedLeaveType,
      orElse: () => Leave('Unknown', '0'),
    );

    if (_selectedText != '1st Half' &&
        _selectedText != '2nd Half' &&
        _selectedLeaveType != 'Short-Leave') {
      if (startDateController.text.isEmpty) {
        showSnackBar('Please select start date');
        return;
      } else if (endDateController.text.isEmpty) {
        showSnackBar('Please select end date');
        return;
      }
    }

    if (_selectedText == '1st Half' || _selectedText == '2nd Half') {
      totalDays = 0.5;
    } else if (_selectedLeaveType!.contains('Medical')) {
      if (_paths == null) {
        showSnackBar('Please Upload Prescription First');
        return;
      }

      DateTime startDate = DateTime.parse(startDateController.text);
      DateTime endDate = DateTime.parse(endDateController.text);

      if (startDate.isBefore(DateTime.now().subtract(Duration(days: 6)))) {
        showSnackBar(
            'Medical leave can only be applied within the last 6 days');
        return;
      }

      if (endDate.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
        showSnackBar('Medical leave cannot extend beyond yesterday');
        return;
      }

      totalDays = endDate.difference(startDate).inDays + 1;
    } else if (_selectedLeaveType!.contains('Casual')) {
      DateTime startDate = DateTime.parse(startDateController.text);
      DateTime endDate = DateTime.parse(endDateController.text);

      int leaveDuration = endDate.difference(startDate).inDays + 1;
      if (leaveDuration < 1 || leaveDuration > 2) {
        showSnackBar('Casual leaves must be between 1 and 2 days');
        return;
      }

      totalDays = leaveDuration;
    } else if (_selectedLeaveType!.contains('Earned')) {
      DateTime startDate = DateTime.parse(startDateController.text);
      DateTime endDate = DateTime.parse(endDateController.text);

      int leaveDuration = endDate.difference(startDate).inDays + 1;
      if (leaveDuration < 1 || leaveDuration > 7) {
        showSnackBar('Earned leaves must be between 1 and 7 days');
        return;
      }

      totalDays = leaveDuration;
    }

    if (selectedLeave.balanceInt < totalDays!) {
      showSnackBar('Not enough leave balance for ${selectedLeave.name}');
      return;
    }

  await  applyLeave(
        context,
        _selectedLeaveType!,
        startDateController.text,
        endDateController.text,
        totalDays.toString(),
        reasonController.text,
        _selectedText);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> getleaveBalance() async {
    var authBox = await Hive.openBox('authBox');

    setState(() {
      casualLeave = authBox.get('casual');
      medicalLeave = authBox.get('medical');
      maternityLeave = authBox.get('maternity');
      earnedLeave = authBox.get('earned');
      paternityLeave = authBox.get('paternity');
      shortLeave = authBox.get('short');
      empID = authBox.get('employeeId');

      leaveList = [
        Leave('Casual Leave', casualLeave!),
        Leave('Medical Leave', medicalLeave!),
        Leave('Earned Leave', earnedLeave!),
        Leave('Short-Leave', shortLeave!),
        Leave('Maternity Leave', maternityLeave!),
        Leave('Paternity Leave', paternityLeave!),
      ];
    });
  }

  @override
  void initState() {
    getleaveBalance();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  String? get uploadURL => '$documentUpload/$empID';
  Future<void> uploadPrescription(List<PlatformFile> files) async {
    final dio = Dio();
    setState(() {
      _isLoading = true;
    });

    for (var file in files) {
      if (file.path != null) {
        try {
          var formData = FormData.fromMap({
            'file':
                await MultipartFile.fromFile(file.path!, filename: file.name),
          });

          Response response = await dio.post(uploadURL!, data: formData);

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Prescription Uploaded'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to Upload Prescription'),
                  backgroundColor: Colors.red),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } else {
        print("File path is null");
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    DateTime shiftendTime = DateTime.parse(
      DateFormat('yyyy-MM-dd').format(DateTime.now()) +
          ' ' +
          '0${_authBox.get('earlyby')}',
    );

    String shortLeaveDate = DateFormat('yyyy-MM-dd').format(shiftendTime);

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
                        height: height * 0.01,
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
                              _selectedText = 'Full Day';
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
                            Visibility(
                              visible: _selectedLeaveType == 'Casual Leave' ||
                                  _selectedLeaveType == 'Earned Leave',
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Card(
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
                            ),
                            Visibility(
                              visible: _selectedLeaveType == 'Short-Leave',
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Card(
                                      color: AppColor.mainFGColor,
                                      elevation: 4,
                                      margin: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      shadowColor:
                                          Colors.black.withOpacity(0.1),
                                      child: SizedBox(
                                          width: width / 2.5,
                                          height: height * 0.05,
                                          child: Center(
                                              child: Text(
                                                  'Date : $shortLeaveDate'))),
                                    ),
                                    Card(
                                      color: AppColor.mainFGColor,
                                      elevation: 4,
                                      margin: EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      shadowColor:
                                          Colors.black.withOpacity(0.1),
                                      child: SizedBox(
                                          width: width / 2.5,
                                          height: height * 0.05,
                                          child: Center(
                                              child: Text(
                                                  'Time : ${DateFormat('HH:mm').format(shiftendTime.subtract(Duration(hours: 1)))}'))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                                visible: _selectedLeaveType != 'Short-Leave',
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildDateSelection(
                                              startDateController
                                                      .text.isNotEmpty
                                                  ? startDateController.text
                                                  : 'Select Start Date',
                                              height,
                                              width),
                                          if (_selectedText == 'Full Day' ||
                                              _selectedLeaveType!
                                                  .contains('Medical'))
                                            _buildDateSelection2(
                                                endDateController
                                                        .text.isNotEmpty
                                                    ? endDateController.text
                                                    : 'Select End Date',
                                                height,
                                                width),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                            Card(
                              color: AppColor.mainFGColor,
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
                              height: height * 0.015,
                            ),
                            Visibility(
                              visible: _selectedLeaveType != null &&
                                  _selectedLeaveType!.contains('Medical'),
                              child: Builder(
                                builder: (BuildContext context) => _isLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : _paths == null
                                        ? SizedBox()
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: _paths?.length ?? 0,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final file = _paths![index];
                                              return Card(
                                                color: AppColor.mainFGColor,
                                                elevation: 5,
                                                margin: EdgeInsets.all(0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                shadowColor: Colors.black
                                                    .withOpacity(0.1),
                                                child: ListTile(
                                                  leading: Icon(
                                                    Icons.file_copy_rounded,
                                                    color: Colors.blue,
                                                  ),
                                                  title: Text(
                                                    file.name,
                                                    style: TextStyle(
                                                        color: AppColor
                                                            .mainTextColor2,
                                                        fontSize: 15),
                                                  ),
                                                  trailing: IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _paths!.removeAt(index);
                                                      });
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            Visibility(
                              visible: _selectedLeaveType != null &&
                                  _selectedLeaveType!.contains('Medical'),
                              child: InkWell(
                                onTap: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  if (result != null) {
                                    setState(() {
                                      _paths = result.files;
                                      uploadPrescription(result.files);
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 10),
                                  child: Text(
                                    "Upload Prescription",
                                    style: TextStyle(
                                        color: AppColor.mainFGColor,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.03,
                            ),
                            InkWell(
                              onTap: () async {
                                validation();
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
                                          color: AppColor.mainFGColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Column(
                              children: [
                                Text(
                                  "Leave Instructions",
                                  style: TextStyle(
                                    fontSize: height * 0.014,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.mainThemeColor,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.02,
                                ),
                                SizedBox(
                                    height: height * 0.2,
                                    child: _selectedLeaveType != null &&
                                            _selectedLeaveType!
                                                .contains('Casual')
                                        ? ListView(
                                            children: [
                                              _buildBulletPoint(
                                                  'Casual leaves can be applied for a minimum of 1 day and a maximum of 2 days at a time, including half-days'),
                                              _buildBulletPoint(
                                                  'Applying for past day is not allowed'),
                                              _buildBulletPoint(
                                                  'Uninformed leaves will automatically be deducted as Casual Leaves.'),
                                              _buildBulletPoint(
                                                  'Any unused Casual Leaves will lapse at the end of each quarter.'),
                                            ],
                                          )
                                        : _selectedLeaveType != null &&
                                                _selectedLeaveType!
                                                    .contains('Medical')
                                            ? ListView(
                                                children: [
                                                  _buildBulletPoint(
                                                      'Medical leaves can be applied only for past days'),
                                                  _buildBulletPoint(
                                                      'Medical leaves can be applied for a minimum of 1 day and a maximum of 6 days at a time.'),
                                                  _buildBulletPoint(
                                                      'A valid medical certificate or prescription is mandatory for availing Medical Leaves.'),
                                                  _buildBulletPoint(
                                                      'These leaves lapse after 6 months if unused.'),
                                                ],
                                              )
                                            : _selectedLeaveType != null &&
                                                    _selectedLeaveType!
                                                        .contains('Short')
                                                ? ListView(
                                                    children: [
                                                      _buildBulletPoint(
                                                          'Short leave can only be applied for today, before leaving the office.'),
                                                      _buildBulletPoint(
                                                          'The leave timing will be auto-selected for 1 hour before your shift end time.'),
                                                      _buildBulletPoint(
                                                          'Make sure to apply for short leave before your shift concludes.'),
                                                    ],
                                                  )
                                                : _selectedLeaveType != null &&
                                                        _selectedLeaveType!
                                                            .contains('Earned')
                                                    ? ListView(
                                                        children: [
                                                          _buildBulletPoint(
                                                              'Earned leave can be applied for a minimum of 1 day and a maximum of 7 days, depending on available leave balance.'),
                                                          _buildBulletPoint(
                                                              'Earned leave can also be taken as half days if required.'),
                                                          _buildBulletPoint(
                                                              'Make sure you have enough leave balance before applying for earned leave.'),
                                                        ],
                                                      )
                                                    : SizedBox())
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(Icons.circle, size: 8, color: AppColor.mainThemeColor),
          ),
          SizedBox(width: 8),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: AppColor.mainTextColor2),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDateSelection(
    String text,
    double height,
    double width,
  ) {
    return GestureDetector(
      onTap: () {
        startDate(context, _selectedLeaveType!, _selectedText);
      },
      child: Card(
        color: AppColor.mainFGColor,
        elevation: 4,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: SizedBox(
            width: width / 2.5,
            child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 128, 128, 128),
                      fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelection2(
    String text,
    double height,
    double width,
  ) {
    return GestureDetector(
      onTap: () {
        endDate(context, _selectedLeaveType!, _selectedText);
      },
      child: Card(
        color: AppColor.mainFGColor,
        elevation: 4,
        margin: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          child: SizedBox(
            width: width / 2.5,
            child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 128, 128, 128),
                      fontSize: 16)),
            ),
          ),
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
