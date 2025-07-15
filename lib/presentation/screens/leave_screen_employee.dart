// ignore_for_file: sort_child_properties_last
import 'dart:io';
import '../../widgets/leave_balance_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import '../../core/provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'apply_leave.dart';

class LeaveScreenEmployee extends StatefulWidget {
  final String empID;
  const LeaveScreenEmployee(this.empID, {super.key});

  @override
  State<LeaveScreenEmployee> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreenEmployee>
    with SingleTickerProviderStateMixin {
  late String documentType;
  bool isDownloading = false;
  late String? empID;
  bool isLoading = true;
  int touchedIndex = -1;
  String _selectedText = 'Pending';
  String _selectedCompoffText = 'Pending';
  Color? activeColor;
  Color? activeText;
  String updateUser = 'Leave Request';
  late TabController _tabController;
  late Future<List<LeaveHistory>> _leaveHistory;
  late Future<List<CompOffRequest>> _compOffRequest;

  @override
  void initState() {
    _compOffRequest = fetchOwnCompOffRequest(_selectedText);
    _leaveHistory = fetchLeaveHistory(_selectedText);
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabSelection);
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          updateUser = 'Leave Request';
          _leaveHistory = fetchLeaveHistory(_selectedText);
          break;
        case 1:
          updateUser = 'Comp-Off Request';
          _compOffRequest = fetchOwnCompOffRequest(_selectedCompoffText);

          break;
      }
    });
  }

  Future<void> _downloadDocument(String url) async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    final status = android.version.sdkInt < 33
        ? await Permission.manageExternalStorage.request()
        : PermissionStatus.granted;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Storage permission is required to download the document'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      isDownloading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading Document'),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final directory = await getExternalStorageDirectory();
      final fileName = url.split('/').last;
      final filePath = '${directory!.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(response.data);

      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Downloaded to $filePath'),
        backgroundColor: Colors.green,
      ));

      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to open the file'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print(e);
      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to download the document $e'),
        backgroundColor: Colors.red,
      ));
    }
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

    return SafeArea(
      child: Consumer<LeaveApplied>(builder: (context, value, child) {
        if (value.leaveappied == true) {
          _compOffRequest = fetchOwnCompOffRequest(_selectedText);
          _leaveHistory = fetchLeaveHistory(_selectedText);
          Future.delayed(Duration(milliseconds: 1500), () {
            Provider.of<LeaveApplied>(context, listen: false)
                .leaveappiedStatus(false);
          });
        }
        return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: AppColor.mainBGColor,
            body: Container(
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
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                        dividerColor: Colors.transparent,
                        controller: _tabController,
                        indicatorColor: AppColor.mainTextColor,
                        labelColor: AppColor.mainTextColor,
                        unselectedLabelColor: AppColor.unselectedColor,
                        tabs: [
                          Tab(
                            child: Text(
                              'Leave Request',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // text: 'Leave Request',
                          ),
                          Tab(
                            child: Text(
                              'Comp-Off Request',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // text: 'Leave Request',
                          ),
                        ]),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Expanded(
                      child: TabBarView(controller: _tabController, children: [
                        leaveSection(height, width),
                        compOffSection(height, width),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.black,
                onPressed: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  barrierColor: AppColor.barrierColor,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ApplyLeave(),
                ),
                label: Text(
                  'Apply Leave',
                  style: TextStyle(color: AppColor.mainFGColor),
                ),
              ),
            ));
      }),
    );
  }

  leaveSection(double height, double width) {
    return Column(
      children: [
        LeaveBalanceWidget(),
        SizedBox(
          height: height * 0.012,
        ),
        Card(
          color: AppColor.mainFGColor,
          elevation: 4,
          margin: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          shadowColor: AppColor.shadowColor,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _selectButton('Pending', height, width),
                  _selectButton('Approved', height, width),
                  _selectButton('Rejected', height, width),
                ]),
          ),
        ),
        SizedBox(
          height: height * 0.015,
        ),
        Expanded(
          child: FutureBuilder<List<LeaveHistory>>(
              future: _leaveHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColor.mainTextColor2,
                      size: height * 0.03,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No Leave Request Found',
                        style: TextStyle(fontSize: height * 0.014),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No Leave Request Found',
                        style: TextStyle(fontSize: height * 0.014),
                      ),
                    ),
                  );
                } else {
                  List<LeaveHistory> items = snapshot.data!;

                  return ListView.separated(
                         physics:BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final leave = items[index];
                      final startDate = DateTime.parse(leave.leaveStartDate);
                      final endDate = DateTime.parse(leave.leaveEndDate);
                      final statusColor = leave.status == 'Pending'
                          ? Colors.amber
                          : leave.status == 'Approved'
                              ? Colors.green
                              : Colors.red;

                      String getLeaveTitle(String type, String days) {
                        final readableType = {
                              'earnedLeave': 'Earned',
                              'medicalLeave': 'Medical',
                              'casualLeave': 'Casual',
                               'compOffLeave': 'Comp-Off',
                              'paternityLeave': 'Paternity',
                              'maternityLeave': 'Maternity',
                              'regularized': 'Regularization',
                              'shortLeave': 'Short-Leave',
                            }[type] ??
                            type;

                        if (type == 'regularized' || type == 'shortLeave')
                          return readableType;

                        return days == '1'
                            ? '$readableType - Full Day'
                            : days == '0.5'
                                ? '$readableType - Half-Day'
                                : '$readableType - $days Days';
                      }

                      return Card(
                        color: AppColor.mainFGColor,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        shadowColor: AppColor.shadowColor,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Leave Title + Date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// Leave Type
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getLeaveTitle(leave.leaveType,
                                                leave.totalDays),
                                            style: TextStyle(
                                              fontSize: height * 0.014,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF40738D),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            leave.totalDays == '1' ||
                                                    leave.totalDays == '0.5'
                                                ? DateFormat('EEE, dd MMM')
                                                    .format(startDate)
                                                : '${DateFormat('EEE, dd MMM').format(startDate)} - ${DateFormat('EEE, dd MMM').format(endDate)}',
                                            style: TextStyle(
                                              fontSize: height * 0.0135,
                                              color: AppColor.mainTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: height * 0.012),

                                  /// Reason Box
                                  Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      color: AppColor.mainBGColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      leave.reason,
                                      style: TextStyle(
                                        fontSize: height * 0.014,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.mainTextColor2,
                                      ),
                                    ),
                                  ),

                                  /// Prescription File
                                  if (leave.location?.isNotEmpty == true)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: InkWell(
                                        onTap: () =>
                                            _downloadDocument(leave.location!),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColor.mainBGColor,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: AppColor.mainFGColor,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.file_copy_rounded,
                                                  color: Colors.blue,
                                                  size: height * 0.016),
                                              const SizedBox(width: 10),
                                              Text(
                                                'View Prescription',
                                                style: TextStyle(
                                                  fontSize: height * 0.013,
                                                  color:
                                                      AppColor.mainTextColor2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  /// Remarks if not pending
                                  if (leave.status != "Pending")
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        leave.remarks,
                                        style: TextStyle(
                                          fontSize: height * 0.013,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),

                                  /// Delete Request if pending
                                  if (leave.status == 'Pending')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () => _confirmDelete(
                                              context, leave.id, height),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                              color: Colors.redAccent,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.2,
                                                vertical: 8),
                                            child: Text(
                                              'Delete Request',
                                              style: TextStyle(
                                                color: AppColor.mainFGColor,
                                                fontSize: height * 0.013,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            /// Status Badge (Top Right)
                            Container(
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text(
                                leave.status,
                                style: TextStyle(
                                  fontSize: height * 0.012,
                                  fontWeight: FontWeight.w500,
                                  color: leave.status == 'Pending'
                                      ? Colors.black
                                      : AppColor.mainFGColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              }),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String id, double height) {
    showDialog(
      barrierColor: AppColor.barrierColor,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.mainFGColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Confirm Action',
            style: TextStyle(
                fontSize: height * 0.02,
                fontWeight: FontWeight.bold,
                color: AppColor.mainTextColor),
          ),
          content: Text(
            'Are you sure you want to delete leave request?',
            style: TextStyle(
                fontSize: height * 0.012, color: AppColor.mainTextColor2),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              onPressed: () async {
                await ownLeaveActionDelete(context, id);
                setState(() {
                  _leaveHistory = fetchLeaveHistory(_selectedText);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                elevation: 0,
              ),
              child: Text("Yes",
                  style: TextStyle(
                      color: AppColor.mainFGColor,
                      fontWeight: FontWeight.bold)),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.borderColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              ),
              child: Text("No",
                  style: TextStyle(
                      color: AppColor.mainTextColor,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }

  compOffSection(double height, double width) {
    return Column(
      children: [
        Card(
          color: AppColor.mainFGColor,
          elevation: 4,
          margin: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          shadowColor: AppColor.shadowColor,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _compoffSelectedButton('Pending', height, width),
                  _compoffSelectedButton('Approved', height, width),
                  _compoffSelectedButton('Rejected', height, width),
                ]),
          ),
        ),
        SizedBox(
          height: height * 0.015,
        ),
        Expanded(
          child: FutureBuilder<List<CompOffRequest>>(
              future: _compOffRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: AppColor.mainTextColor2,
                      size: height * 0.03,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No Comp-Off Request Found',
                        style: TextStyle(fontSize: height * 0.014),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No Comp-Off Request Found',
                        style: TextStyle(fontSize: height * 0.014),
                      ),
                    ),
                  );
                } else {
                  List<CompOffRequest> items = snapshot.data!;

                  return ListView.separated(
                         physics:BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final leave = items[index];
                      final statusColor = leave.status == 'Pending'
                          ? Colors.amber
                          : leave.status == 'Approved'
                              ? Colors.green
                              : Colors.red;

                      return Card(
                        color: AppColor.mainFGColor,
                        elevation: 6,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        shadowColor: AppColor.shadowColor,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Title & Date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// Comp-Off Type + Date
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Comp-Off Request (${leave.totalDays})',
                                            style: TextStyle(
                                              fontSize: height * 0.014,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF40738D),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            leave.compOffDate,
                                            style: TextStyle(
                                              fontSize: height * 0.0135,
                                              color: AppColor.mainTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: height * 0.012),

                                  /// Reason
                                  Container(
                                    width: width,
                                    decoration: BoxDecoration(
                                      color: AppColor.mainBGColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      leave.reason,
                                      style: TextStyle(
                                        fontSize: height * 0.014,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.mainTextColor2,
                                      ),
                                    ),
                                  ),

                                  /// Comments (if approved/rejected)
                                  if (leave.status != "Pending")
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        leave.comments,
                                        style: TextStyle(
                                          fontSize: height * 0.013,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),

                                  /// Delete Button (only if pending)
                                  if (leave.status == 'Pending')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            _confirmCompOffDelete(
                                                context, leave.id, height);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                              color: Colors.redAccent,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: width * 0.2,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              'Delete Request',
                                              style: TextStyle(
                                                color: AppColor.mainFGColor,
                                                fontSize: height * 0.013,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            /// Status Badge
                            Container(
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text(
                                leave.status,
                                style: TextStyle(
                                  fontSize: height * 0.012,
                                  fontWeight: FontWeight.w500,
                                  color: leave.status == 'Pending'
                                      ? Colors.black
                                      : AppColor.mainFGColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              }),
        ),
      ],
    );
  }

  Future<void> _confirmCompOffDelete(
      BuildContext context, String id, double height) async {
    return showDialog<void>(
      barrierColor: AppColor.barrierColor,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.mainFGColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(
              fontSize: height * 0.02,
              fontWeight: FontWeight.bold,
              color: AppColor.mainTextColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this comp-off request?',
            style: TextStyle(
              fontSize: height * 0.012,
              color: AppColor.mainTextColor2,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              onPressed: () async {
                await ownCompOffActionDelete(context, id);
                setState(() {
                  _compOffRequest = fetchOwnCompOffRequest('');
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              ),
              child: Text("Yes",
                  style: TextStyle(
                      color: AppColor.mainFGColor,
                      fontWeight: FontWeight.bold)),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColor.borderColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              ),
              child: Text("No",
                  style: TextStyle(
                      color: AppColor.mainTextColor,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }

  Widget _selectButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedText == text) {
      activeColor = const Color(0xFF40738D);
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = AppColor.mainTextColor2;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          _leaveHistory = fetchLeaveHistory(_selectedText);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 12),
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

  Widget _compoffSelectedButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedCompoffText == text) {
      activeColor = const Color(0xFF40738D);
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = AppColor.mainTextColor2;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCompoffText = text;
          _compOffRequest = fetchOwnCompOffRequest(_selectedCompoffText);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: activeColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 12),
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
