
import 'package:flutter/material.dart';
import '../api/api.dart';
import '../model/models.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';


class TaskProvider extends ChangeNotifier {
  bool taskupdated = false;
  bool get updateStatus => taskupdated;

  void taskupdatedStatus(bool updateStatus) {
    taskupdated = updateStatus;
    notifyListeners();
  }
}

class ProjectProvider extends ChangeNotifier {
  bool projectUpdated = false;
  bool get updateStatus => projectUpdated;

  void projectUpdatedStatus(bool updateStatus) {
    projectUpdated = updateStatus;
    notifyListeners();
  }
}

class StageProvider extends ChangeNotifier {
  bool stageManage = false;
  bool get updateStage => stageManage;

  void stageManageStatus(bool updateStage) {
    stageManage = updateStage;
    notifyListeners();
  }
}

class LeaveApplied extends ChangeNotifier {
  bool leaveappied = false;
  bool get updateLeaveApplied => leaveappied;

  void leaveappiedStatus(bool updateLeaveApplied) {
    leaveappied = updateLeaveApplied;
    notifyListeners();
  }
}

class PostTrackData extends ChangeNotifier {
  bool trackdataStatus = false;
  bool get updatePostTrackData => trackdataStatus;

  void trackdataStatusStatus(bool updatePostTrackData) {
    trackdataStatus = updatePostTrackData;
    notifyListeners();
  }
}

class PunchedIN extends ChangeNotifier {
  PunchRecordModel? _record;
  PunchRecordModel? get record => _record;

  Future<void> fetchAndSetPunchRecord() async {
    try {
      final data = await fetchPunchRecord();
      _record = data;
      notifyListeners();
    } catch (e) {
      _record = null;
      notifyListeners();
    }
  }
}

class PunchHistoryProvider with ChangeNotifier {
  List<PunchHistoryModel> _records = [];
  bool _isLoading = false;
  String? _error;

  List<PunchHistoryModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await fetchPunchHistory();
      _records = data;
    } catch (e) {
      _error = "Failed to fetch history.";
      _records = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}





