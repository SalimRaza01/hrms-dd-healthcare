class ShiftTimeModel {
  final String startTime;
  final String endTime;

  ShiftTimeModel({required this.startTime, required this.endTime});

  factory ShiftTimeModel.fromJson(Map<String, dynamic> json) {
    return ShiftTimeModel(
      startTime: json['startAt'],
      endTime: json['endAt'],
    );
  }
}

class LeaveBalance {
  final String casualLeave;
  final String medicalLeave;
  final String earnedLeave;
  final String paternityLeave;
  final String maternityLeave;

  LeaveBalance({
    required this.casualLeave,
    required this.medicalLeave,
    required this.earnedLeave,
    required this.paternityLeave,
    required this.maternityLeave,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      casualLeave: json['casualLeave'],
      medicalLeave: json['medicalLeave'],
      earnedLeave: json['earnedLeave'],
      paternityLeave: json['paternityLeave'],
      maternityLeave: json['maternityLeave'],
    );
  }
}

class Attendance {
  final String employeeName;
  final String employeeCode;
  final String gender;
  final String employmentType;
  final String attendanceDate;
  final String inTime;
  final String outTime;
  final String status;
  final int duration;
  final String punchRecords;
  final int lateby;
  final int earlyBy;
  final int weekOff;
  final int isHoliday;
  final String leaveType;
  final bool isLeaveTaken;
  final num absent;

  Attendance(
      {required this.employeeName,
      required this.employeeCode,
      required this.gender,
      required this.employmentType,
      required this.attendanceDate,
      required this.inTime,
      required this.outTime,
      required this.status,
      required this.duration,
      required this.punchRecords,
      required this.lateby,
      required this.earlyBy,
      required this.weekOff,
      required this.isHoliday,
      required this.leaveType,
      required this.isLeaveTaken,
      required this.absent});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
        employeeName: json['EmployeeName'] ?? '',
        employeeCode: json['EmployeeCode'] ?? '',
        gender: json['Gender'] ?? '',
        employmentType: json['EmployementType'] ?? '',
        attendanceDate: json['AttendanceDate'] ?? '',
        inTime: json['InTime'] ?? '',
        outTime: json['OutTime'] ?? '',
        status: json['Status'] ?? '',
        duration: json['Duration'] ?? 0,
        punchRecords: json['PunchRecords'] ?? '',
        lateby: json['LateBy'] ?? 0,
        earlyBy: json['EarlyBy'] ?? 0,
        weekOff: json['WeeklyOff'] ?? '',
        isHoliday: json['Holiday'] ?? 0,
        leaveType: json['leaveType'] ?? '',
        isLeaveTaken: json['isLeaveTaken'] ?? false,
        absent: json['Absent'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'EmployeeName': employeeName,
      'EmployeeCode': employeeCode,
      'Gender': gender,
      'EmployementType': employmentType,
      'AttendanceDate': attendanceDate,
      'InTime': inTime,
      'OutTime': outTime,
      'Status': status,
      'Duration': duration,
      'PunchRecords': punchRecords,
      'LateBy': lateby,
      'EarlyBy': earlyBy,
      'WeeklyOff': weekOff,
      'Holiday': isHoliday,
      'leaveType': leaveType,
      'isLeaveTaken': isLeaveTaken,
      'Absent': absent,
    };
  }
}

class LeaveHistory {
  final String id;
  final String leaveType;
  final String leaveStartDate;
  final String leaveEndDate;
  final String totalDays;
  final String reason;
  final String status;
  final String approvedBy;
  final String dateTime;
  final String remarks;
  final String? location;

  LeaveHistory(
      {required this.id,
      required this.leaveType,
      required this.leaveStartDate,
      required this.leaveEndDate,
      required this.totalDays,
      required this.reason,
      required this.status,
      required this.approvedBy,
      required this.dateTime,
      required this.remarks,
      this.location});

  factory LeaveHistory.fromJson(Map<String, dynamic> json) {
    return LeaveHistory(
      id: json['_id'] ?? '',
      leaveType: json['leaveType'] ?? '',
      leaveStartDate: json['leaveStartDate'] ?? '',
      leaveEndDate: json['leaveEndDate'] ?? '',
      totalDays: json['totalDays'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      approvedBy: json['approvedBy'] ?? '',
      dateTime: json['dateTime'] ?? '',
         remarks: json['remarks'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leaveType': leaveType,
      'leaveStartDate': leaveStartDate,
      'leaveEndDate': leaveEndDate,
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'approvedBy': approvedBy,
      'dateTime': dateTime,
       'remarks': remarks,
      'location': location
    };
  }
}

class EmployeeProfile {
  final String employeeId;
  final String employeeName;
  final String employeeCode;
  final String gender;
  final String departmentId;
  final String designation;
  final String doj;
  final String employeeCodeInDevice;
  final String employmentType;
  final String employeeStatus;
  final String accountStatus;
  final String fatherName;
  final String motherName;
  final String residentialAddress;
  final String permanentAddress;
  final String contactNo;
  final String email;
  final String dob;
  final String placeOfBirth;
  final String bloodGroup;
  final String workPlace;
  final String maritalStatus;
  final String nationality;
  final String overallExperience;
  final String qualifications;
  final String emergencyContact;
  final String managerId;
  final String teamLeadId;
  final String employeePhoto;
  bool isExpanded = false;

  EmployeeProfile({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.gender,
    required this.departmentId,
    required this.designation,
    required this.doj,
    required this.employeeCodeInDevice,
    required this.employmentType,
    required this.employeeStatus,
    required this.accountStatus,
    required this.fatherName,
    required this.motherName,
    required this.residentialAddress,
    required this.permanentAddress,
    required this.contactNo,
    required this.email,
    required this.dob,
    required this.placeOfBirth,
    required this.bloodGroup,
    required this.workPlace,
    required this.maritalStatus,
    required this.nationality,
    required this.overallExperience,
    required this.qualifications,
    required this.emergencyContact,
    required this.managerId,
    required this.teamLeadId,
    required this.employeePhoto,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      employeeId: json['employeeId'].toString(),
      employeeName: json['employeeName'],
      employeeCode: json['employeeCode'],
      gender: json['gender'],
      departmentId: json['departmentId'].toString(),
      designation: json['designation'],
      doj: json['doj'],
      employeeCodeInDevice: json['employeeCodeInDevice'],
      employmentType: json['employmentType'],
      employeeStatus: json['employeeStatus'],
      accountStatus: json['accountStatus'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      residentialAddress: json['residentialAddress'],
      permanentAddress: json['permanentAddress'],
      contactNo: json['contactNo'],
      email: json['email'],
      dob: json['dob'],
      placeOfBirth: json['placeOfBirth'],
      bloodGroup: json['bloodGroup'],
      workPlace: json['workPlace'],
      maritalStatus: json['maritalStatus'],
      nationality: json['nationality'],
      overallExperience: json['overallExperience'],
      qualifications: json['qualifications'],
      emergencyContact: json['emergencyContact'],
      managerId: json['managerId'],
      teamLeadId: json['teamLeadId'],
      employeePhoto: json['employeePhoto'],
    );
  }
}

class HolidayModel {
  final String holidayName;
  final String holidayDate;
  final String holidayDescription;

  HolidayModel({
    required this.holidayName,
    required this.holidayDate,
    required this.holidayDescription,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      holidayName: json['holidayName'],
      holidayDate: json['holidayDate'],
      holidayDescription: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holidayName': holidayName,
      'holidayDate': holidayDate,
      'description': holidayDescription,
    };
  }
}

class LeaveRequests {
  final String id;
  final String leaveType;
  final String leaveStartDate;
  final String leaveEndDate;
  final String totalDays;
  final String reason;
  final String status;
  final String approvedBy;
  final String dateTime;
  final String employeeName;
  final String location;

  LeaveRequests(
      {required this.id,
      required this.leaveType,
      required this.leaveStartDate,
      required this.leaveEndDate,
      required this.totalDays,
      required this.reason,
      required this.status,
      required this.approvedBy,
      required this.dateTime,
      required this.employeeName,
      required this.location});

  factory LeaveRequests.fromJson(Map<String, dynamic> json) {
    return LeaveRequests(
        id: json['_id'] ?? '',
        leaveType: json['leaveType'] ?? '',
        leaveStartDate: json['leaveStartDate'] ?? '',
        leaveEndDate: json['leaveEndDate'] ?? '',
        totalDays: json['totalDays'] ?? '',
        reason: json['reason'] ?? '',
        status: json['status'] ?? '',
        approvedBy: json['approvedBy'] ?? '',
        dateTime: json['dateTime'] ?? '',
        employeeName: json['employeeInfo']['employeeName'] ?? '',
        location: json['location']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leaveType': leaveType,
      'leaveStartDate': leaveStartDate,
      'leaveEndDate': leaveEndDate,
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'approvedBy': approvedBy,
      'dateTime': dateTime,
      'employeeName': employeeName,
      'location': location
    };
  }
}

class DocumentList {
  final String docType;
  final String documentName;
  final String employeeId;
  final String location;

  DocumentList({
    required this.docType,
    required this.documentName,
    required this.employeeId,
    required this.location,
  });

  factory DocumentList.fromJson(Map<String, dynamic> json) {
    return DocumentList(
      docType: json['docType'].toString(),
      documentName: json['documentName'],
      employeeId: json['employeeId'],
      location: json['location'],
    );
  }
}

class DocumentListModel {
  final String documentName;
  final String docType;
  final String location;

  DocumentListModel({
    required this.documentName,
    required this.docType,
    required this.location,
  });

  factory DocumentListModel.fromJson(Map<String, dynamic> json) {
    return DocumentListModel(
      documentName: json['documentName'],
      docType: json['docType'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentName': documentName,
      'docType': docType,
      'location': location,
    };
  }
}

class OdooUserModel {
  final int id;
  final String name;
  final String email;

  OdooUserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory OdooUserModel.fromJson(Map<String, dynamic> json) {
    return OdooUserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class OdooProjectList {
  final int id;
  final String name;
  final String create_date;
  final String task_creator_email;
  final List assignes_emails;

  OdooProjectList(
      {required this.id,
      required this.name,
      required this.create_date,
      required this.task_creator_email,
      required this.assignes_emails});

  factory OdooProjectList.fromJson(Map<String, dynamic> json) {
    return OdooProjectList(
        id: json['id'],
        name: json['name'],
        create_date: json['create_date'],
        task_creator_email: json['task_creator_email'],
        assignes_emails: json['assignes_emails']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'create_date': create_date,
      'task_creator_email': task_creator_email,
      'assignes_emails': assignes_emails,
    };
  }
}

class OdooTaskList {
  final int id;
  final String name;
  final int project_id;
  final String project_name;
  final String stage_name;
  final String start_date;
  final String deadline_date;
  final String description;

  OdooTaskList({
    required this.id,
    required this.name,
    required this.project_id,
    required this.project_name,
    required this.stage_name,
    required this.start_date,
    required this.deadline_date,
    required this.description,
  });

  factory OdooTaskList.fromJson(Map<String, dynamic> json) {
    return OdooTaskList(
      id: json['id'],
      name: json['name'],
      project_id: json['project_id'],
      project_name: json['project_name'],
      stage_name: json['stage_name'],
      start_date: json['start_date'],
      deadline_date: json['deadline_date'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'project_id': project_id,
      'project_name': project_name,
      'stage_name': stage_name,
      'start_date': start_date,
      'deadline_date': deadline_date,
      'description': description,
    };
  }
}

class EmployeeOnLeave {
  final String employeeName;
  final String gender;

  EmployeeOnLeave({
    required this.employeeName,
    required this.gender,
  });

  factory EmployeeOnLeave.fromJson(Map<String, dynamic> json) {
    return EmployeeOnLeave(
      employeeName: json['employeeName'].toString(),
      gender: json['gender'],
    );
  }
}

class CompOffRequest {
  final String id;
  final String compOffDate;
  final String appliedDate;
  final String totalDays;
  final String reason;
  final String status;
  final String comments;
  final String employeeName;

  CompOffRequest({
    required this.id,
    required this.compOffDate,
    required this.appliedDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.comments,
    required this.employeeName,
  });

  factory CompOffRequest.fromJson(Map<String, dynamic> json) {
    return CompOffRequest(
      id: json['_id'] ?? '',
      compOffDate: json['compOffDate'] ?? '',
      appliedDate: json['appliedDate'] ?? '',
      totalDays: json['totalDays'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      comments: json['comments'] ?? '',
      employeeName: json['employeeInfo']['employeeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'compOffDate': compOffDate,
      'appliedDate': appliedDate,
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'comments': comments,
      'employeeName': employeeName,
    };
  }
}
