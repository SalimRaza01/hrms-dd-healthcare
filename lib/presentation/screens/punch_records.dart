import 'dart:math';
import 'package:flutter/services.dart';
import '../../core/api/api.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PunchRecordScreen extends StatefulWidget {
  final String? punchRecords;
  final String? regularizationDate;
  final int lateMinutes;

  const PunchRecordScreen({
    super.key,
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
  String _selectedLeaveType = 'Regularization';
  String _selectedDuration = '1';

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
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    List<String> punches =
        (widget.punchRecords?.split(',') ?? []).toSet().toList();

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD8E1E7),
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
                      date != null && date!.month != DateTime.now().month
                          ? 'Generate Comp-Off'
                          : 'Punch Records',
                      style: TextStyle(
                        fontSize: height * 0.018,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const CircleAvatar(
                        backgroundColor: Colors.white, radius: 18),
                  ],
                ),
              ),
              Column(
                children: [
                  Visibility(
                    visible: date != null &&
                        date!.month == DateTime.now().month &&
                        date!.year == DateTime.now().year,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.mainFGColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _selectLeaveButton('Regularization', height, width),
                            _selectLeaveButton(
                                'Generate Comp-Off', height, width),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Visibility(
                    visible: _selectedLeaveType == 'Generate Comp-Off' ||
                        date != null && date!.month != DateTime.now().month,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Card(
                        color: AppColor.mainFGColor,
                        elevation: 4,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        shadowColor: AppColor.shadowColor,
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Select Duration',
                                    style: TextStyle(
                                      fontSize: height * 0.015,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.mainTextColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: width * 0.02),
                                _selectDurationButton('1', height, width),
                                _selectDurationButton('0.5', height, width),
                              ]),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.mainFGColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                            color: AppColor.mainTextColor,
                          ),
                          decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            enabledBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            focusedBorder:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            label: Text('Describe Reason'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Visibility(
                    visible: _selectedLeaveType == 'Regularization' &&
                        date != null &&
                        date!.month == DateTime.now().month,
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
                      } else if (_selectedLeaveType == 'Regularization' && date != null &&
                          date!.month == DateTime.now().month ) {
                        if (widget.lateMinutes > 0 &&
                            widget.lateMinutes <= 15) {
                          await applyRegularize(
                            context,
                            widget.regularizationDate!,
                            reasonController.text,
                          );
                        } else {
                          showSnackBar(
                            'Regularization can only be applied if late before ${_authBox.get('lateby') == '9:00' ? '09:30 AM' : _authBox.get('lateby') == '10:00' ? '10:30 AM' : _authBox.get('lateby') == '8:30' ? '09:00 AM' : ''}',
                          );
                        }
                      } else if (_selectedLeaveType == 'Generate Comp-Off') {
                        await applyCompoff(context, widget.regularizationDate!,
                            reasonController.text, _selectedDuration);
                      } else if (date != null &&
                          date!.month != DateTime.now().month && _selectedLeaveType == 'Regularization') {
                        await applyCompoff(context, widget.regularizationDate!,
                            reasonController.text, _selectedDuration);
                      }
                    },
                    child: Center(
                      child: Container(
                        width: width / 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF40738D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Center(
                            child: Text(
                              'SUBMIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.016),
              Expanded(
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
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
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: AppColor.shadowColor,
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
                    return const SizedBox(height: 10);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectDurationButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedDuration == text) {
      activeColor = const Color(0xFF40738D);
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = Colors.black87;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = text;
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

  Widget _selectLeaveButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedLeaveType == text) {
      activeColor = const Color(0xFF40738D);
      activeText = Colors.white;
    } else {
      activeColor = Colors.transparent;
      activeText = AppColor.mainTextColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLeaveType = text;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
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
