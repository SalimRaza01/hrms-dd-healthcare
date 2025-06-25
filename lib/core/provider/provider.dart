import 'package:flutter/material.dart';

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

class PunchedIN extends ChangeNotifier {
  bool punchin = false;
  bool get updatedpunchIn => punchin;

  void updatePunchInTime(bool updatedpunchIn) {
    punchin = updatedpunchIn;
    notifyListeners();
  }
}
