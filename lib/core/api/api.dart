import 'package:database_app/core/api/api_config.dart';
import 'package:database_app/core/model/models.dart';
import 'package:database_app/presentation/authentication/create_new_pass.dart';
import 'package:database_app/presentation/authentication/login_screen.dart';
import 'package:database_app/presentation/authentication/otp_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../presentation/screens/bottom_navigation.dart';

final Box _authBox = Hive.box('authBox');
final Dio dio = Dio();

Future<List<Attendance>> fetchAttendence(String empID) async {
  final dateTo = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final dateFrom = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 365)));

  try {
    final response = await dio.get('$getAttendenceData/$empID',
        queryParameters: {"dateFrom": dateFrom, "dateTo": dateTo, "page": 1});

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

Future<LeaveBalance> fetchLeaves(String empID) async {
  try {
    final response = await dio.get('$getEmployeeData/$empID');

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

Future<ShiftTimeModel> fetchShiftTime(String empID) async {
  try {
    final response = await dio.get('$getEmployeeData/$empID');

    if (response.statusCode == 200) {
      String mgrId = response.data['data']['managerId'];
      await _authBox.put('managerId', mgrId);
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
        "email": emailController,
        "password": passController,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('Login Response $responseData');
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

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BottomNavigation()));

        print('successfull');
      } else {
        print('failed ${response.statusMessage}');
      }
    } catch (e) {
      print(e.toString());
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
) async {
  String mgrId = _authBox.get('managerId');
  String empID = _authBox.get('employeeId');
  String token = _authBox.get('token');
  print('managerId $mgrId');

  try {
    final response = await dio.post('$employeeApplyLeave/$empID',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }),
        data: {
          "leaveType": leaveType == 'Comp-off Leave'
              ? 'compOffLeave'
              : leaveType == 'Casual Leave'
                  ? 'casualLeave'
                  : leaveType == 'Medical Leave'
                      ? 'medicalLeave'
                      : leaveType == 'Earned Leave'
                          ? 'earnedLeave'
                          : null,
          "leaveStartDate": startDate,
          "leaveEndDate": endDate,
          "totalDays": totalDays,
          "reason": reason,
          "approvedBy": mgrId
        });
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    print('Dio Exception: ${e.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request failed: ${e.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<List<LeaveHistory>> fetchLeaveHistory(
    String status, String empID) async {
  String token = _authBox.get('token');
  print('status $token');
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

Future<EmployeeProfile> fetchEmployeeDetails(String empID) async {
  Dio dio = Dio();
  try {
    final response = await dio.get('$getEmployeeData/$empID');
    print(empID);
    return EmployeeProfile.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to load employee profile');
  }
}

Future<List<HolidayModel>> fetchHolidayList() async {
  try {
    final response = await dio.get(
      getHolidayList,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      // final List<dynamic> data = response.data['data'].where((date) => DateTime.parse(date['holidayDate']).day < DateTime.now().day)
      //     .toList();

      return data.map((item) => HolidayModel.fromJson(item)).toList();
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
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something Wrong : ${response.statusMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request failed: No regularization available'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<List<LeaveRequests>> fetchLeaveRequest() async {
  String token = _authBox.get('token');
  print('status $token');
  try {
    final response = await dio.get(getLeaveRequest,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }));

    if (response.statusCode == 200) {
      List<dynamic> data = response.data['data'];
      print("Team Leave Request Data $data");
      return data
          .map((leaveData) => LeaveRequests.fromJson(leaveData))
          .toList();
    } else {
      throw Exception('Failed to load leave history');
    }
  } catch (e) {
    throw Exception('Error fetching data: $e');
  }
}

Future<void> leaveAction(
  BuildContext context,
  String action,
  String id,
) async {
  try {
    final response =
        await dio.put('$leaveActionApi/$id', data: {"status": action});
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request Approved'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request Declined'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } on DioException catch (e) {
    print('Dio Exception: ${e.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('failed: ${e.message}'),
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
  BuildContext context,
  String email,
  String screen
) async {
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
    if(screen == 'LOGIN'){
 Future.delayed(Duration(seconds: 1), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OTPScren(email)));
    });
    }
   
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something Wrong ${response}'),
        backgroundColor: Colors.red,
      ),
    );
  }
  // } on DioException {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Failed to send OTP ${}'),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }
}

Future<void> verifyPasswordOTP(
    BuildContext context, String otp, String email) async {
  try {
    final response = await dio.post(verifyOTP, data: {
      "otp": otp,
    });
    if (response.statusCode == 200) {
      print(response.data);
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
  } on DioException {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something Went Wrong'),
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
      print(response.data);
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
  } on DioException {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something Went Wrong'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
