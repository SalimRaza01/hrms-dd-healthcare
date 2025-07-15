// ignore_for_file: sort_child_properties_last
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/api/api.dart';
import '../../core/model/models.dart';
import '../../core/provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../widgets/leave_balance_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'apply_leave.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class LeaveScreenManager extends StatefulWidget {
  final String empID;
  const LeaveScreenManager(this.empID);

  @override
  State<LeaveScreenManager> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreenManager>
    with SingleTickerProviderStateMixin {
  late String documentType;
  bool isDownloading = false;
  late String? empID;
  bool isLoading = true;
  bool switchMode = false;
  int touchedIndex = -1;
  String _selectedText = 'Pending';
  String _selectedCompoffText = 'Pending';
  Color? activeColor;
  Color? activeText;
  String updateUser = 'Leaves';
  late TabController _tabController;
  late Future<List<LeaveHistory>> _myLeaveHistory;
  late Future<List<LeaveRequests>> _teamLeaveRequest;
  late Future<List<CompOffRequest>> _teamCompOffRequest;
  late Future<List<CompOffRequest>> _myCompOffRequest;

  @override
  void initState() {
    _myLeaveHistory = fetchLeaveHistory(_selectedText);
    _teamCompOffRequest = fetchCompOffRequest(_selectedCompoffText);
    _teamLeaveRequest = fetchLeaveRequest(_selectedText);
    _myCompOffRequest = fetchOwnCompOffRequest(_selectedCompoffText);
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
          updateUser = switchMode ? 'Team Leave' : 'Leaves';
          _teamLeaveRequest = fetchLeaveRequest(_selectedText);
          _myLeaveHistory = fetchLeaveHistory(_selectedText);
          break;
        case 1:
          updateUser = switchMode ? 'Team Comp-off' : 'Comp-off';
          _teamCompOffRequest = fetchCompOffRequest(_selectedCompoffText);
          _myCompOffRequest = fetchOwnCompOffRequest(_selectedCompoffText);
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

    return switchMode ? teamSection(height, width) : selfSection(height, width);
  }

  selfSection(double height, double width) {
    return SafeArea(
      child: Consumer<LeaveApplied>(builder: (context, value, child) {
        if (value.leaveappied == true) {
          _myLeaveHistory = fetchLeaveHistory(_selectedText);
          _myCompOffRequest = fetchOwnCompOffRequest(_selectedCompoffText);
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
                          ),
                          Tab(
                            child: Text(
                              'Comp-Off Request',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: height * 0.015,
                    ),
                    Expanded(
                      child: TabBarView(controller: _tabController, children: [
                        Column(
                          children: [
                            LeaveBalanceWidget(),
                            SizedBox(
                              height: height * 0.012,
                            ),
                            Card(
                              color: AppColor.mainFGColor,
                              elevation: 0,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadowColor: AppColor.shadowColor,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                  future: _myLeaveHistory,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: LoadingAnimationWidget
                                            .threeArchedCircle(
                                          color: AppColor.mainTextColor2,
                                          size: height * 0.03,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('No History Found'),
                                        ),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('No History Found'),
                                        ),
                                      );
                                    } else {
                                      List<LeaveHistory> items = snapshot.data!;

                                      return ListView.separated(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: items.length,
                                        separatorBuilder: (context, index) =>
                                            SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final leave = items[index];
                                          final startDate = DateTime.parse(
                                              leave.leaveStartDate);
                                          final endDate = DateTime.parse(
                                              leave.leaveEndDate);
                                          final statusColor =
                                              leave.status == 'Pending'
                                                  ? Colors.amber
                                                  : leave.status == 'Approved'
                                                      ? Colors.green
                                                      : Colors.red;

                                          String getLeaveTitle(
                                              String type, String days) {
                                            final readableType = {
                                                  'earnedLeave': 'Earned',
                                                  'medicalLeave': 'Medical',
                                                  'casualLeave': 'Casual',
                                                  'compOffLeave': 'Comp-Off',
                                                  'paternityLeave': 'Paternity',
                                                  'maternityLeave': 'Maternity',
                                                  'regularized':
                                                      'Regularization',
                                                  'shortLeave': 'Short-Leave',
                                                }[type] ??
                                                type;

                                            if (type == 'regularized' ||
                                                type == 'shortLeave')
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
                                                borderRadius:
                                                    BorderRadius.circular(28)),
                                            shadowColor: AppColor.shadowColor,
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /// Leave Title + Date
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          /// Leave Type
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                getLeaveTitle(
                                                                    leave
                                                                        .leaveType,
                                                                    leave
                                                                        .totalDays),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.014,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: const Color(
                                                                      0xFF40738D),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                leave.totalDays ==
                                                                            '1' ||
                                                                        leave.totalDays ==
                                                                            '0.5'
                                                                    ? DateFormat(
                                                                            'EEE, dd MMM')
                                                                        .format(
                                                                            startDate)
                                                                    : '${DateFormat('EEE, dd MMM').format(startDate)} - ${DateFormat('EEE, dd MMM').format(endDate)}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.0135,
                                                                  color: AppColor
                                                                      .mainTextColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                          height:
                                                              height * 0.012),

                                                      /// Reason Box
                                                      Container(
                                                        width: width,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColor
                                                              .mainBGColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Text(
                                                          leave.reason,
                                                          style: TextStyle(
                                                            fontSize:
                                                                height * 0.014,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: AppColor
                                                                .mainTextColor2,
                                                          ),
                                                        ),
                                                      ),

                                                      /// Prescription File
                                                      if (leave.location
                                                              ?.isNotEmpty ==
                                                          true)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 12),
                                                          child: InkWell(
                                                            onTap: () =>
                                                                _downloadDocument(
                                                                    leave
                                                                        .location!),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: AppColor
                                                                        .mainBGColor,
                                                                    width: 2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: AppColor
                                                                    .mainFGColor,
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .file_copy_rounded,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: height *
                                                                          0.016),
                                                                  const SizedBox(
                                                                      width:
                                                                          10),
                                                                  Text(
                                                                    'View Prescription',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          height *
                                                                              0.013,
                                                                      color: AppColor
                                                                          .mainTextColor2,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                      /// Remarks if not pending
                                                      if (leave.status !=
                                                          "Pending")
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 12),
                                                          child: Text(
                                                            leave.remarks,
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.013,
                                                              color: Colors
                                                                  .blueGrey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),

                                                      /// Delete Request if pending
                                                      if (leave.status ==
                                                          'Pending')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 14),
                                                          child: Center(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () =>
                                                                  _confirmDelete(
                                                                      context,
                                                                      leave.id,
                                                                      height),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              28),
                                                                  color: Colors
                                                                      .redAccent,
                                                                ),
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        width *
                                                                            0.2,
                                                                    vertical:
                                                                        8),
                                                                child: Text(
                                                                  'Delete Request',
                                                                  style:
                                                                      TextStyle(
                                                                    color: AppColor
                                                                        .mainFGColor,
                                                                    fontSize:
                                                                        height *
                                                                            0.013,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
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
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(16),
                                                      bottomLeft:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  child: Text(
                                                    leave.status,
                                                    style: TextStyle(
                                                      fontSize: height * 0.012,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: leave.status ==
                                                              'Pending'
                                                          ? Colors.black
                                                          : AppColor
                                                              .mainFGColor,
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
                        ),
                        Column(
                          children: [
                            Card(
                              color: AppColor.mainFGColor,
                              elevation: 0,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadowColor: AppColor.shadowColor,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _compoffSelectedButton(
                                          'Pending', height, width),
                                      _compoffSelectedButton(
                                          'Approved', height, width),
                                      _compoffSelectedButton(
                                          'Rejected', height, width),
                                    ]),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            Expanded(
                              child: FutureBuilder<List<CompOffRequest>>(
                                  future: _myCompOffRequest,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: LoadingAnimationWidget
                                            .threeArchedCircle(
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
                                            style: TextStyle(
                                                fontSize: height * 0.014),
                                          ),
                                        ),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'No Comp-Off Request Found',
                                            style: TextStyle(
                                                fontSize: height * 0.014),
                                          ),
                                        ),
                                      );
                                    } else {
                                      List<CompOffRequest> items =
                                          snapshot.data!;

                                      return ListView.separated(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: items.length,
                                        separatorBuilder: (context, index) =>
                                            SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final leave = items[index];
                                          final statusColor =
                                              leave.status == 'Pending'
                                                  ? Colors.amber
                                                  : leave.status == 'Approved'
                                                      ? Colors.green
                                                      : Colors.red;

                                          return Card(
                                            color: AppColor.mainFGColor,
                                            elevation: 6,
                                            margin: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(28)),
                                            shadowColor: AppColor.shadowColor,
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      /// Title & Date
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          /// Comp-Off Type + Date
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Comp-Off Request (${leave.totalDays})',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.014,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: const Color(
                                                                      0xFF40738D),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                leave
                                                                    .compOffDate,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.0135,
                                                                  color: AppColor
                                                                      .mainTextColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                          height:
                                                              height * 0.012),

                                                      /// Reason
                                                      Container(
                                                        width: width,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColor
                                                              .mainBGColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Text(
                                                          leave.reason,
                                                          style: TextStyle(
                                                            fontSize:
                                                                height * 0.014,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: AppColor
                                                                .mainTextColor2,
                                                          ),
                                                        ),
                                                      ),

                                                      /// Comments (if approved/rejected)
                                                      if (leave.status !=
                                                          "Pending")
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 12),
                                                          child: Text(
                                                            leave.comments,
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.013,
                                                              color: Colors
                                                                  .blueGrey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),

                                                      /// Delete Button (only if pending)
                                                      if (leave.status ==
                                                          'Pending')
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 14),
                                                          child: Center(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                _confirmCompOffDelete(
                                                                    context,
                                                                    leave.id,
                                                                    height);
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              28),
                                                                  color: Colors
                                                                      .redAccent,
                                                                ),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                      width *
                                                                          0.2,
                                                                  vertical: 8,
                                                                ),
                                                                child: Text(
                                                                  'Delete Request',
                                                                  style:
                                                                      TextStyle(
                                                                    color: AppColor
                                                                        .mainFGColor,
                                                                    fontSize:
                                                                        height *
                                                                            0.013,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
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
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(16),
                                                      bottomLeft:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  child: Text(
                                                    leave.status,
                                                    style: TextStyle(
                                                      fontSize: height * 0.012,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: leave.status ==
                                                              'Pending'
                                                          ? Colors.black
                                                          : AppColor
                                                              .mainFGColor,
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
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    icon: Icon(
                      CupertinoIcons.group_solid,
                      color: AppColor.mainFGColor,
                    ),
                    heroTag: 'btn1',
                    backgroundColor: Colors.black,
                    onPressed: () {
                      setState(() {
                        switchMode = !switchMode;
                        _teamLeaveRequest = fetchLeaveRequest(_selectedText);
                        _teamCompOffRequest =
                            fetchCompOffRequest(_selectedCompoffText);
                      });
                    },
                    label: Text(
                      'Team',
                      style: TextStyle(color: AppColor.mainFGColor),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'btn2',
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
                ],
              ),
            ));
      }),
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
                  _myCompOffRequest = fetchOwnCompOffRequest('');
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
                  _myLeaveHistory = fetchLeaveHistory(_selectedText);
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

  teamSection(double height, double width) {
    return SafeArea(
      child: Consumer<LeaveApplied>(builder: (context, value, child) {
        if (value.leaveappied == true) {
          _teamLeaveRequest = fetchLeaveRequest(_selectedText);
          _teamCompOffRequest = fetchCompOffRequest(_selectedCompoffText);
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
                              'Team Leave',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // text: 'Leave Request',
                          ),
                          Tab(
                            child: Text(
                              'Team Comp-Off',
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
                        Column(
                          children: [
                            Card(
                              color: AppColor.mainFGColor,
                              elevation: 0,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadowColor: AppColor.shadowColor,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _leaveFilterBTNTeam(
                                          'Pending', height, width),
                                      _leaveFilterBTNTeam(
                                          'Approved', height, width),
                                      _leaveFilterBTNTeam(
                                          'Rejected', height, width),
                                    ]),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            Expanded(
                                child: FutureBuilder<List<LeaveRequests>>(
                                    future: _teamLeaveRequest,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: LoadingAnimationWidget
                                              .threeArchedCircle(
                                            color: AppColor.mainTextColor2,
                                            size: height * 0.03,
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child:
                                                Text('No Leave Request Found'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Center(
                                            child:
                                                Text('No Leave Request Found'));
                                      } else {
                                        List<LeaveRequests> items =
                                            snapshot.data!;

                                        return ListView.separated(
                                          physics: BouncingScrollPhysics(),
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            final leave = items[index];
                                            final startDate = DateTime.parse(
                                                leave.leaveStartDate);
                                            final endDate = DateTime.parse(
                                                leave.leaveEndDate);
                                            print(leave.location);
                                            return Card(
                                              color: AppColor.mainFGColor,
                                              elevation: 0,
                                              margin: EdgeInsets.all(0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                              ),
                                              shadowColor: AppColor.shadowColor,
                                              child: Stack(
                                                alignment:
                                                    AlignmentDirectional.topEnd,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14,
                                                        vertical: 8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  leave
                                                                      .employeeName,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        height *
                                                                            0.016,
                                                                    color: AppColor
                                                                        .mainTextColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  leave.leaveType ==
                                                                          'earnedLeave'
                                                                      ? leave.totalDays ==
                                                                              '1'
                                                                          ? 'Earned - Full Day'
                                                                          : leave.totalDays ==
                                                                                  '0.5'
                                                                              ? 'Earned - Half-Day'
                                                                              : 'Earned - ${leave.totalDays} Days'
                                                                      : leave.leaveType ==
                                                                              'medicalLeave'
                                                                          ? leave.totalDays == '1'
                                                                              ? 'Medical - Full Day'
                                                                              : leave.totalDays == '0.5'
                                                                                  ? 'Medical - Half-Day'
                                                                                  : 'Medical - ${leave.totalDays} Days'
                                                                          : leave.leaveType == 'casualLeave'
                                                                              ? leave.totalDays == '1'
                                                                                  ? 'Casual - Full Day'
                                                                                  : leave.totalDays == '0.5'
                                                                                      ? 'Casual - Half-Day'
                                                                                      : 'Casual - ${leave.totalDays} Days'
                                                                              : leave.leaveType == 'compOffLeave'
                                                                                  ? leave.totalDays == '1'
                                                                                      ? 'Comp-Off - Full Day'
                                                                                      : leave.totalDays == '0.5'
                                                                                          ? 'Comp-Off - Half-Day'
                                                                                          : 'Comp-Off - ${leave.totalDays} Days'
                                                                                  : leave.leaveType == 'paternityLeave'
                                                                                      ? leave.totalDays == '1'
                                                                                          ? 'Paternity - Full Day'
                                                                                          : leave.totalDays == '0.5'
                                                                                              ? 'Paternity - Half-Day'
                                                                                              : 'Paternity - ${leave.totalDays} Days'
                                                                                      : leave.leaveType == 'maternityLeave'
                                                                                          ? leave.totalDays == '1'
                                                                                              ? 'Maternity - Full Day'
                                                                                              : leave.totalDays == '0.5'
                                                                                                  ? 'Maternity - Half-Day'
                                                                                                  : 'Maternity - ${leave.totalDays} Days'
                                                                                          : leave.leaveType == 'regularized'
                                                                                              ? 'Regularization'
                                                                                              : leave.leaveType == 'shortLeave'
                                                                                                  ? 'Short-Leave'
                                                                                                  : leave.leaveType,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        height *
                                                                            0.012,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColor
                                                                        .mainThemeColor,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  leave.totalDays ==
                                                                              '1' ||
                                                                          leave.totalDays ==
                                                                              '0.5'
                                                                      ? DateFormat(
                                                                              'EEE, dd MMM')
                                                                          .format(
                                                                              startDate)
                                                                      : '${DateFormat('EEE, dd MMM').format(startDate)} - ${DateFormat('EEE, dd MMM').format(endDate)}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        height *
                                                                            0.012,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: AppColor
                                                                        .mainTextColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.015),
                                                        Container(
                                                          width: width,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColor
                                                                .mainBGColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            // boxShadow: [
                                                            //   BoxShadow(
                                                            //     color: Colors.black12,
                                                            //     blurRadius: 4,
                                                            //     offset: Offset(0, 2),
                                                            //   ),
                                                            // ],
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            child: Text(
                                                              leave.reason,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    height *
                                                                        0.014,
                                                                color: AppColor
                                                                    .mainTextColor2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: leave
                                                              .location
                                                              .isNotEmpty,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 12),
                                                            child: InkWell(
                                                              onTap: () {
                                                                _downloadDocument(
                                                                    leave
                                                                        .location);
                                                              },
                                                              child: Container(
                                                                width: width,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: AppColor
                                                                          .mainBGColor,
                                                                      width: 2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                  color: AppColor
                                                                      .mainFGColor,
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .file_copy_rounded,
                                                                        color: Colors
                                                                            .blue,
                                                                        size: height *
                                                                            0.013,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              width * 0.03),
                                                                      Text(
                                                                        'View Prescription',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              AppColor.mainTextColor2,
                                                                          fontSize:
                                                                              height * 0.012,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              leave.status ==
                                                                  'Pending',
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 18),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                // Accept Button
                                                                Expanded(
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      print(leave
                                                                          .id);
                                                                      await leaveAction(
                                                                          context,
                                                                          'Approved',
                                                                          leave
                                                                              .id);
                                                                      setState(
                                                                          () {
                                                                        _teamLeaveRequest =
                                                                            fetchLeaveRequest(_selectedText);
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(28),
                                                                        color: const Color
                                                                            .fromARGB(
                                                                            126,
                                                                            20,
                                                                            183,
                                                                            25),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal: width /
                                                                                9,
                                                                            vertical:
                                                                                8),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Accept',
                                                                            style:
                                                                                TextStyle(
                                                                              color: AppColor.mainTextColor,
                                                                              fontSize: height * 0.012,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: width *
                                                                      0.05,
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      await leaveAction(
                                                                          context,
                                                                          'Rejected',
                                                                          leave
                                                                              .id);
                                                                      setState(
                                                                          () {
                                                                        _teamLeaveRequest =
                                                                            fetchLeaveRequest(_selectedText);
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              28),
                                                                          color:
                                                                              AppColor.mainBGColor),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal: width /
                                                                                9,
                                                                            vertical:
                                                                                8),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Decline',
                                                                            style:
                                                                                TextStyle(
                                                                              color: AppColor.mainTextColor,
                                                                              fontSize: height * 0.012,
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
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                height * 0.005),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: leave.status ==
                                                                'Pending'
                                                            ? Colors.amber
                                                            : leave.status ==
                                                                    'Approved'
                                                                ? Colors.green
                                                                : Colors.red,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        28),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        28))),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0,
                                                          horizontal: 20),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(7.0),
                                                        child: Text(
                                                          leave.status,
                                                          style: TextStyle(
                                                              fontSize: height *
                                                                  0.012,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: leave.status ==
                                                                      'Pending'
                                                                  ? Colors.black
                                                                  : AppColor
                                                                      .mainFGColor),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              SizedBox(height: 10),
                                        );
                                      }
                                    })),
                          ],
                        ),
                        Column(
                          children: [
                            Card(
                              color: AppColor.mainFGColor,
                              elevation: 0,
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadowColor: AppColor.shadowColor,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _compoffFilterBTNTeam(
                                          'Pending', height, width),
                                      _compoffFilterBTNTeam(
                                          'Approved', height, width),
                                      _compoffFilterBTNTeam(
                                          'Rejected', height, width),
                                    ]),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            Expanded(
                              child: FutureBuilder<List<CompOffRequest>>(
                                  future: _teamCompOffRequest,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: LoadingAnimationWidget
                                            .threeArchedCircle(
                                          color: AppColor.mainTextColor2,
                                          size: height * 0.03,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              Text('No Comp-Off Request Found'),
                                        ),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                          child: Text(
                                              'No Comp-Off Request Found'));
                                    } else {
                                      List<CompOffRequest> items =
                                          snapshot.data!;

                                      return ListView.separated(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: items.length,
                                        itemBuilder: (context, index) {
                                          final leave = items[index];
                                          // final startDate = DateTime.parse(leave.appliedDate);

                                          return Card(
                                            color: AppColor.mainFGColor,
                                            elevation: 0,
                                            margin: EdgeInsets.all(0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                            ),
                                            shadowColor: AppColor.shadowColor,
                                            child: Stack(
                                              alignment:
                                                  AlignmentDirectional.topEnd,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                leave
                                                                    .employeeName,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.016,
                                                                  color: AppColor
                                                                      .mainTextColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Comp-Off Request (${leave.totalDays})',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.012,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppColor
                                                                      .mainThemeColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                leave
                                                                    .compOffDate,

                                                                // leave.totalDays == '1' ||
                                                                //         leave.totalDays == '0.5'
                                                                //     ? DateFormat('EEE, dd MMM')
                                                                //         .format(startDate)
                                                                //     : '${DateFormat('EEE, dd MMM').format(startDate)} - ${DateFormat('EEE, dd MMM').format(endDate)}',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.012,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: AppColor
                                                                      .mainTextColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.015),
                                                      Container(
                                                        width: width,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColor
                                                              .mainBGColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          // boxShadow: [
                                                          //   BoxShadow(
                                                          //     color: Colors.black12,
                                                          //     blurRadius: 4,
                                                          //     offset: Offset(0, 2),
                                                          //   ),
                                                          // ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          child: Text(
                                                            leave.reason,
                                                            style: TextStyle(
                                                              fontSize: height *
                                                                  0.014,
                                                              color: AppColor
                                                                  .mainTextColor2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Visibility(
                                                      //   visible: leave.location.isNotEmpty,
                                                      //   child: Padding(
                                                      //     padding: const EdgeInsets.only(top: 12),
                                                      //     child: Container(
                                                      //       width: width,
                                                      //       decoration: BoxDecoration(
                                                      //         border: Border.all(
                                                      //             color: AppColor.mainBGColor,
                                                      //             width: 2),
                                                      //         borderRadius:
                                                      //             BorderRadius.circular(12),
                                                      //         color: AppColor.mainFGColor,
                                                      //       ),
                                                      //       child: Padding(
                                                      //         padding: const EdgeInsets.all(8.0),
                                                      //         child: Row(
                                                      //           children: [
                                                      //             Icon(
                                                      //               Icons.file_copy_rounded,
                                                      //               color: Colors.blue,
                                                      //               size: height * 0.013,
                                                      //             ),
                                                      //             SizedBox(width: width * 0.03),
                                                      //             Text(
                                                      //               'IMG_45544871.JPG',
                                                      //               style: TextStyle(
                                                      //                 color:
                                                      //                     AppColor.mainTextColor2,
                                                      //                 fontSize: height * 0.012,
                                                      //                 fontWeight: FontWeight.w500,
                                                      //               ),
                                                      //             ),
                                                      //           ],
                                                      //         ),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      Visibility(
                                                        visible: leave.status ==
                                                            'Pending',
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 18),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              // Accept Button
                                                              Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await compOffActionPut(
                                                                        context,
                                                                        'Approved',
                                                                        leave
                                                                            .id);
                                                                    setState(
                                                                        () {
                                                                      _teamCompOffRequest =
                                                                          fetchCompOffRequest(
                                                                              _selectedCompoffText);
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              28),
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          126,
                                                                          20,
                                                                          183,
                                                                          25),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: width /
                                                                              9,
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Approve',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AppColor.mainTextColor,
                                                                            fontSize:
                                                                                height * 0.012,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: width *
                                                                    0.05,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await compOffActionPut(
                                                                        context,
                                                                        'Rejected',
                                                                        leave
                                                                            .id);
                                                                    setState(
                                                                        () {
                                                                      _teamCompOffRequest =
                                                                          fetchCompOffRequest(
                                                                              _selectedCompoffText);
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                28),
                                                                        color: AppColor
                                                                            .mainBGColor),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: width /
                                                                              9,
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Reject',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AppColor.mainTextColor,
                                                                            fontSize:
                                                                                height * 0.012,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              height * 0.005),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: leave.status ==
                                                              'Pending'
                                                          ? Colors.amber
                                                          : leave.status ==
                                                                  'Approved'
                                                              ? Colors.green
                                                              : Colors.red,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(28),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      28))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 0,
                                                        horizontal: 20),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              7.0),
                                                      child: Text(
                                                        leave.status,
                                                        style: TextStyle(
                                                            fontSize:
                                                                height * 0.012,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: leave.status ==
                                                                    'Pending'
                                                                ? Colors.black
                                                                : AppColor
                                                                    .mainFGColor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            SizedBox(height: 10),
                                      );
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    icon: Icon(
                      CupertinoIcons.person_fill,
                      color: AppColor.mainFGColor,
                    ),
                    heroTag: 'btn1',
                    backgroundColor: Colors.black,
                    onPressed: () {
                      setState(() {
                        switchMode = !switchMode;

                        _myLeaveHistory = fetchLeaveHistory(_selectedText);
                        _myCompOffRequest =
                            fetchOwnCompOffRequest(_selectedCompoffText);
                      });
                    },
                    label: Text(
                      'Self',
                      style: TextStyle(color: AppColor.mainFGColor),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'btn2',
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
                ],
              ),
            ));
      }),
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
      activeText = AppColor.mainTextColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCompoffText = text;
          _myCompOffRequest = fetchOwnCompOffRequest(_selectedCompoffText);
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

  Widget _selectButton(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedText == text) {
      activeColor = const Color(0xFF40738D);
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = AppColor.mainTextColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          _myLeaveHistory = fetchLeaveHistory(_selectedText);
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

  Widget _compoffFilterBTNTeam(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedCompoffText == text) {
      activeColor = const Color(0xFF40738D);
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = AppColor.mainTextColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCompoffText = text;
          _teamCompOffRequest = fetchCompOffRequest(_selectedCompoffText);
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

  Widget _leaveFilterBTNTeam(String text, double height, double width) {
    Color activeColor;
    Color activeText;

    if (_selectedText == text) {
      activeColor = const Color(0xFF40738D);
      activeText = AppColor.mainFGColor;
    } else {
      activeColor = Colors.transparent;
      activeText = AppColor.mainTextColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedText = text;
          _teamLeaveRequest = fetchLeaveRequest(_selectedText);
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
