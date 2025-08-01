import 'dart:convert';
import 'dart:typed_data';

import 'api_config.dart';
import '../model/models.dart';
import '../provider/provider.dart';
import '../../presentation/authentication/create_new_pass.dart';
import '../../presentation/authentication/login_screen.dart';
import '../../presentation/authentication/otp_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../presentation/screens/bottom_navigation.dart';

final Box _authBox = Hive.box('authBox');
final Dio dio = Dio();

Future<List<Attendance>> fetchAttendence(
    String empID, String selectedMonth) async {
  DateTime monthDate = DateFormat("MMMM yyyy").parse(selectedMonth);

  final dateFrom = DateFormat('yyyy-MM-dd')
      .format(DateTime(monthDate.year, monthDate.month, 1));

  final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);

  final dateTo = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

  DateTime currentMonth = DateTime.now();
  DateTime formattedCurrentMonth = DateFormat("MMMM yyyy")
      .parse(DateFormat("MMMM yyyy").format(currentMonth));
  try {
    final response =
        await dio.get('$getAttendenceData/$empID', queryParameters: {
      "dateFrom": dateFrom,
      "dateTo": monthDate == formattedCurrentMonth
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : dateTo,
      "limit": 31,
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((item) => Attendance.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load attendance data');
    }
  } catch (e) {
    throw Exception('Error fetching data: $e');
  }
}

Future<LeaveBalance> fetchLeaves() async {
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');
  try {
    final response = await dio.get('$getEmployeeData/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    if (response.statusCode == 200) {
      String maxRegularization = response.data['data']['maxRegularization'];
      await _authBox.put('maxRegularization', maxRegularization);
      return LeaveBalance.fromJson(response.data['data']['leaveBalance']);
    } else {
      throw Exception('Failed to load leave data');
    }
  } catch (e) {
    throw Exception('Failed to load leave data: $e');
  }
}

Future<ShiftTimeModel> fetchShiftTime() async {
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');
  try {
    final response = await dio.get('$getEmployeeData/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    if (response.statusCode == 200) {
      await _authBox.put(
          'casual', response.data['data']['leaveBalance']['casualLeave']);
      await _authBox.put(
          'compOff', response.data['data']['leaveBalance']['compOffLeave']);
      await _authBox.put(
          'medical', response.data['data']['leaveBalance']['medicalLeave']);
      await _authBox.put(
          'earned', response.data['data']['leaveBalance']['earnedLeave']);
      await _authBox.put(
          'optional', response.data['data']['leaveBalance']['optionalLeave']);

      await _authBox.put('photo', response.data['data']['employeePhoto']);

      await _authBox.put('short', response.data['data']['maxShortLeave']);

      await _authBox.put('managerId', response.data['data']['managerId']);

      await _authBox.put('lateby',
          response.data['data']['shiftTime']['startAt'].replaceAll(' ', ''));

      await _authBox.put(
          'earlyby', response.data['data']['shiftTime']['endAt']);

      return ShiftTimeModel.fromJson(response.data['data']['shiftTime']);
    } else {
      throw Exception('Failed to load shift time data');
    }
  } catch (e) {
    throw Exception('Failed to load shift time data: $e');
  }
}

class AuthProvider with ChangeNotifier {
  Future<void> login(String emailController, String passController,
      BuildContext context) async {
    try {
      final response = await dio.post(employeeLogin, data: {
        "email": emailController.toLowerCase(),
        "password": passController,
      });

      print(response.data);
      if (response.statusCode == 200) {
        final responseData = response.data;

        final token = responseData['token'];
        final employeeId = responseData['data']['employeeId'];
        final employeeName = responseData['data']['employeeName'];
        final employeeDesign = responseData['data']['designation'];
        final email = responseData['data']['email'];
        final gender = responseData['data']['gender'];
        final role = responseData['data']['role'];

        // Save the token in Hive
        await _authBox.put('token', token);
        await _authBox.put('employeeId', employeeId.toString());
        await _authBox.put('employeeName', employeeName);
        await _authBox.put('employeeDesign', employeeDesign);
        await _authBox.put('email', email);
        await _authBox.put('gender', gender);
        await _authBox.put('role', role);
        print(responseData['token']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomNavigation()));
      } else {}
    } on DioException catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response!.data['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> applyLeave(
    BuildContext context,
    String leaveType,
    String startDate,
    String endDate,
    String totalDays,
    String reason,
    String _selectedText) async {
  String mgrId = _authBox.get('managerId');
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');

  try {
    final response = await dio.post('$employeeApplyLeave/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "leaveType": leaveType == 'Casual Leave'
              ? 'casualLeave'
              : leaveType == 'Medical Leave'
                  ? 'medicalLeave'
                  : leaveType == 'Earned Leave'
                      ? 'earnedLeave'
                      : leaveType == 'Short-Leave'
                          ? 'shortLeave'
                          : leaveType == 'Comp-Off Leave'
                              ? 'compOffLeave'
                              : leaveType == 'Vendor Meeting'
                                  ? 'vendor-meeting'
                                  : null,
          "leaveStartDate": startDate,
          "leaveEndDate": _selectedText.contains('1st Half') ||
                  _selectedText.contains('2nd Half')
              ? " "
              : endDate,
          "totalDays": totalDays,
          "reason": reason,
          "approvedBy": mgrId,
          "shift": leaveType == 'Casual Leave' ||
                  leaveType == 'Earned Leave' ||
                  leaveType == 'Comp-Off Leave' ||
                  leaveType == 'Vendor Meeting'
              ? _selectedText
              : "",
          "location": leaveType == 'Medical Leave' ? _authBox.get('file') : ''
        });
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Provider.of<LeaveApplied>(context, listen: false).leaveappiedStatus(true);
      Navigator.pop(context);
    }
  } on DioException catch (e) {
    print('backend error ${e.response!.data}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<EmployeeProfile> fetchEmployeeDetails(String empID) async {
  String token = _authBox.get('token');

  Dio dio = Dio();
  try {
    final response = await dio.get('$getEmployeeData/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    return EmployeeProfile.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to load employee profile');
  }
}

Future<List<HolidayModel>> fetchHolidayList(String screenName) async {
  try {
    final response = await dio.get(getHolidayList);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final upcomingHolidays = data.where((item) {
        String holidayDate = item['holidayDate'];
        return DateTime.parse(holidayDate).isAfter(DateTime.parse(todayDate));
      }).toList();

      return screenName == 'HomeScreen'
          ? upcomingHolidays.map((item) => HolidayModel.fromJson(item)).toList()
          : data.map((item) => HolidayModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Holiday data');
    }
  } catch (e) {
    throw Exception('Error fetching data: $e');
  }
}

Future<void> applyRegularize(
  BuildContext context,
  String startDate,
  String reason,
) async {
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');
  print('regularized-off');
  try {
    final response = await dio.post('$applyRegularization/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "leaveType": 'regularized',
          "leaveStartDate": startDate,
          "reason": reason,
        });
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> applyShortLeave(
  BuildContext context,
  String startDate,
  String reason,
) async {
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');

  try {
    final response = await dio.post('$applyRegularization/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "leaveType": 'shortLeave',
          "leaveStartDate": startDate,
          "reason": reason,
        });
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Provider.of<LeaveApplied>(context, listen: false).leaveappiedStatus(true);
      Navigator.pop(context);
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> applyVendorMeeting(
  BuildContext context,
  String startDate,
  String reason,
  String totalDays,
) async {
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');

  try {
    final response = await dio.post('$vendorMeetingApi/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "leaveType": "vendor-meeting",
          "leaveStartDate": startDate,
          "reason": reason,
          "duration": totalDays,
        });
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> applyCompoff(BuildContext context, String startDate, String reason,
    String totaldays) async {
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');

  try {
    final response = await dio.post('$generateCompoff/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "compOffDate": startDate,
          "totalDayss": totaldays,
          "reason": reason,
        });
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<List<LeaveRequests>> fetchLeaveRequest(String status) async {
  String token = _authBox.get('token');
  print(token);

  // try {
  final response = await dio.get(getLeaveRequest,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }),
      queryParameters: {
        "limit": 20,
      });

  if (response.statusCode == 200) {
    List<dynamic> data = response.data['data']
        .where((leave) => leave['status'] == status)
        .toList();

    return data.map((leaveData) => LeaveRequests.fromJson(leaveData)).toList();
  } else {
    return [];
  }
  // } catch (e) {
  //   throw Exception('Error fetching data: $e');
  // }
}

Future<void> leaveAction(
  BuildContext context,
  String action,
  String id,
) async {
  String token = _authBox.get('token');
  print(token);
  try {
    final response = await dio.put('$leaveActionApi/$id',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {"status": action});

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: action == "Approved" ? Colors.green : Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: action == "Approved" ? Colors.green : Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<List<EmployeeProfile>> fetchTeamList() async {
  String token = _authBox.get('token');
  Dio dio = Dio();
  try {
    final response = await dio.get(getTeamMemberList,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    List<EmployeeProfile> employeeList = [];
    for (var employee in response.data['data']) {
      employeeList.add(EmployeeProfile.fromJson(employee));
    }
    return employeeList;
  } catch (e) {
    throw Exception('Failed to load employee profiles');
  }
}

Future<void> sendPasswordOTP(
    BuildContext context, String email, String screen) async {
  try {
    final response = await dio.post(sentOTP, data: {
      "email": email,
    });

    if (response.statusCode == 200) {
      print(response.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      if (screen == 'LOGIN') {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => OTPScren(email)));
        });
      }
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> verifyPasswordOTP(
    BuildContext context, String otp, String email) async {
  try {
    final response = await dio.post(verifyOTP, data: {
      "otp": otp,
    });
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP Verified Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateNewPassword(email)));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have entered wrong OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> createNewPass(
    BuildContext context, String newPassword, String email) async {
  try {
    final response = await dio.put(setNewPass, data: {
      "email": email,
      "loginPassword": newPassword,
    });
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password Created Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something Went Wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<List<DocumentListModel>> fetchDocumentList(String documentType) async {
  String token = _authBox.get('token');
  String empID = _authBox.get('employeeId');

  final response = await dio.get(
      documentType == 'Public' ? documentList : '$documentList/$empID',
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }));

  if (response.statusCode == 200) {
    final List<dynamic> data = response.data['data'];
    return data.map((item) => DocumentListModel.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load Holiday data');
  }
}

Future<List<OdooUserModel>> fetchOddoUsers(int projectid) async {
  final response = await dio.get('$getodooUsers/$projectid');
  print(response);
  if (response.statusCode == 200) {
    final List<dynamic> data = response.data['users'];
    return data.map((item) => OdooUserModel.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load OdooUsers data');
  }
}

Future<List<OdooProjectList>> fetchOdooProjects() async {
  String email = _authBox.get('email');
  final response = await dio.get(getOdooProject);

  if (response.statusCode == 200) {
    final List<dynamic> projects = response.data['projects'];

    final List<dynamic> data = projects.where((project) {
      var assignedEmails = project['assignes_emails'];
      var creatorEmail = project['task_creator_email'];

      return assignedEmails is List && assignedEmails.contains(email) ||
          creatorEmail == email;
    }).toList();

    return data.map((item) => OdooProjectList.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load OdooProjects data');
  }
}

// Future<List<EmployeeOnLeave>> fetchEmployeeOnLeave() async {
//   try {
//     final response = await dio.get(getEmployeeOnLeave);

//     if (response.statusCode == 200) {
//       List<dynamic> data = response.data['data'];
//       print(data);

//       return data
//           .map((leaveData) => EmployeeOnLeave.fromJson(leaveData))
//           .toList();
//     } else {
//       throw Exception('Failed to load employee onleave');
//     }
//   } catch (e) {
//     throw Exception('Error fetching data: $e');
//   }
// }

Future<void> changeTaskStage(
  BuildContext context,
  int taskID,
  String stageName,
  String comment,
) async {
  try {
    final response = await dio.put('$putTaskStage/$taskID', data: {
      "stage_name": stageName,
      "comments": comment,
    });
    if (response.data['result']['status'] == 'success') {
      print(response);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status Updated'),
          backgroundColor: Colors.green,
        ),
      );
      Provider.of<TaskProvider>(context, listen: false).taskupdatedStatus(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request Failed $response'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<List<LeaveHistory>> fetchLeaveHistory(
  String status,
) async {
  String token = _authBox.get('token');
  String empID = _authBox.get('employeeId');

  try {
    final response = await dio.get('$getLeaveHistory/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['data']
          .where((leave) => leave['status'] == status)
          .toList();

      return data.map((leaveData) => LeaveHistory.fromJson(leaveData)).toList();
    } else {
      throw Exception('Failed to load leave history');
    }
  } catch (e) {
    throw Exception('Error fetching data: $e');
  }
}

Future<List<CompOffRequest>> fetchCompOffRequest(String status) async {
  String token = _authBox.get('token');

  // try {
  final response = await dio.get(compOffRequestList,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }));

  if (response.statusCode == 200) {
    List<dynamic> data = response.data['data']
        .where((leave) => leave['status'] == status)
        .toList();

    return data.map((leaveData) => CompOffRequest.fromJson(leaveData)).toList();
  } else {
    return [];
  }
  // } catch (e) {
  //   throw Exception('Error fetching data: $e');
  // }
}

Future<List<CompOffRequest>> fetchOwnCompOffRequest(String status) async {
  String token = _authBox.get('token');

  // try {
  final response = await dio.get(ownCompOffList,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }));

  if (response.statusCode == 200) {
    List<dynamic> data = response.data['data']
        .where((leave) => leave['status'] == status)
        .toList();

    return data.map((leaveData) => CompOffRequest.fromJson(leaveData)).toList();
  } else {
    return [];
  }
  // } catch (e) {
  //   throw Exception('Error fetching data: $e');
  // }
}

Future<void> compOffActionPut(
  BuildContext context,
  String action,
  String id,
) async {
  String token = _authBox.get('token');
  print(id);
  try {
    final response = await dio.put('$compOffActon/$id',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {"status": action});
    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: action == "Approved" ? Colors.green : Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: action == "Approved" ? Colors.green : Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> ownCompOffActionDelete(
  BuildContext context,
  String id,
) async {
  print(id);
  try {
    String token = _authBox.get('token');
    final response = await dio.delete('$ownCompOffActon/$id',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> ownLeaveActionDelete(
  BuildContext context,
  String id,
) async {
  print(id);
  try {
    String token = _authBox.get('token');
    final response = await dio.delete('$ownLeaveAction/$id',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> manualPunchIn(
  BuildContext context,
  String location,
  String imageUrl64,
) async {
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');

  try {
    final response = await dio.post(punchinAction,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "employeeId": empID,
          "location": location,
          "imageUrl": imageUrl64
        });
    if (response.statusCode == 201 || response.statusCode == 200) {
      _authBox.put('punchedIn', 'yes');

      await _authBox.put('Punch-In-id', response.data['data']['_id']);
      final punchProvider = Provider.of<PunchedIN>(context, listen: false);
      await punchProvider.fetchAndSetPunchRecord();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Punch-In Success'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } on DioException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.response!.data['message']),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> manualPunchOut(
    BuildContext context, String punchInId, String location) async {
  String token = _authBox.get('token');

  try {
    final response = await dio.post('$punchOutAction/$punchInId',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "location": location,
        });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Punch-Out Success'),
          backgroundColor: Colors.green,
        ),
      );

      final punchProvider = Provider.of<PunchedIN>(context, listen: false);
      await punchProvider.fetchAndSetPunchRecord();
      _authBox.put('punchedIn', null);
    }
  } on DioException catch (e) {
    final errorMessage = e.response?.data['message'] ?? 'Something went wrong';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> updateLocation(
    BuildContext context, String id, String location) async {
  try {
    final response = await dio.put('$updatePunchLocation/$id', data: {
      "location": location,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location Updated Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      final punchProvider = Provider.of<PunchedIN>(context, listen: false);
      await punchProvider.fetchAndSetPunchRecord();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something Went Wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    print(e);
  }
}

Future<PunchRecordModel> fetchPunchRecord() async {
  final String token = _authBox.get('token');

  final response = await dio.get(
    '$getPunchAttendence/${_authBox.get('employeeId')}',
    options: Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print(response.data);
    final Map<String, dynamic> data = response.data['data'][0];

    // _authBox.put(
    //     'selfie', decodeBase64Image(response.data['data'][0]['imageUrl']));
    return PunchRecordModel.fromJson(data);
  } else {
    throw Exception("Failed to fetch punch data");
  }
}

Future<List<PunchHistoryModel>> fetchPunchHistory() async {
  final String token = _authBox.get('token');

  final response = await dio.get(
    '$getPunchAttendence/${_authBox.get('employeeId')}',
    options: Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final List dataList = response.data['data'];
    print(response.data);

    return dataList.map((json) => PunchHistoryModel.fromJson(json)).toList();
  } else {
    throw Exception("Failed to fetch punch history");
  }
}

Uint8List decodeBase64Image(String base64String) {
  final RegExp regex = RegExp(r'data:image/[^;]+;base64,');
  base64String = base64String.replaceAll(regex, '');

  return base64Decode(base64String);
}
